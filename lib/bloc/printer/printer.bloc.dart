import 'package:bluetooth_app/services/image_utils.dart';
import 'package:intl/intl.dart';
import 'package:bluetooth_app/bloc/printer/printer.event.dart';
import 'package:bluetooth_app/bloc/printer/printer.state.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue/flutter_blue.dart';

class PrinterBloc extends Bloc<PrinterEvent, PrinterState> {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  List<BluetoothDevice> devicesList = [];
  BluetoothDevice? connectedDevice;
  BluetoothCharacteristic? characteristic;

  // LABEL SETTINGS
  String labelHeigth = '20';
  String labelWidth = '30';
  String labelGap = '2';

  PrinterBloc() : super(PrinterInitial()) {
    on<InitializePrinter>(_onInitializePrinter);
    on<ConnectToDevice>(_onConnectToDevice);
    on<DisconnectFromDevice>(_onDisconnectFromDevice);
    on<UpdateTsplCode>(_onUpdateTsplCode);
    on<PrintLabel>(_onPrintLabel);
    on<SetSettings>(_onSetSettings);
  }

  Future<bool> _onSetSettings(SetSettings event, Emitter<PrinterState> emit) async {
    try {
      labelHeigth = event.height;
      labelWidth = event.width;
      labelGap = event.gap;

      return true;
    } catch (e) {
      throw Exception('Error set settings');
    }
  }

  Future<void> _onInitializePrinter(
      InitializePrinter event, Emitter<PrinterState> emit) async {
    emit(PrinterLoading());
    try {
      flutterBlue.startScan(timeout: const Duration(seconds: 4));

      flutterBlue.scanResults.listen((results) {
        for (ScanResult r in results) {
          if (!devicesList.contains(r.device)) {
            devicesList.add(r.device);
          }
        }
      });

      flutterBlue.stopScan();
      emit(DevicesLoaded(devicesList));
    } catch (e) {
      emit(PrinterDisconnected());
    }
  }

  Future<void> _onConnectToDevice(
      ConnectToDevice event, Emitter<PrinterState> emit) async {
    emit(PrinterLoading());
    try {
      await event.device.connect();
      connectedDevice = event.device;

      if (connectedDevice == null) return;

      List<BluetoothService> services =
          await connectedDevice!.discoverServices();
      for (var service in services) {
        for (var char in service.characteristics) {
          if (char.properties.write) {
            characteristic = char;
          }
        }
      }

      emit(PrinterConnected(event.device, characteristic!));
    } catch (e) {
      emit(PrinterDisconnected());
    }
  }

  Future<void> _onDisconnectFromDevice(
      DisconnectFromDevice event, Emitter<PrinterState> emit) async {
    emit(PrinterLoading());
    try {
      await event.device.disconnect();
      connectedDevice = null;
      characteristic = null;
      emit(PrinterDisconnected());
    } catch (e) {
      emit(PrinterDisconnected());
    }
  }

  void _onUpdateTsplCode(UpdateTsplCode event, Emitter<PrinterState> emit) {
    emit(TsplUpdated(event.tsplCode));
  }

  void _onPrintLabel(PrintLabel event, Emitter<PrinterState> emit) async {
    if (state is PrinterConnected) {
      if (characteristic != null) {
        String startTime =
            DateFormat('yyyy-MM-dd HH:mm').format(event.startDate);
        String endTime = '';
        String count = event.count;

        switch (event.adjustmentType) {
          case AdjustmentType.defrosting:
            endTime = DateFormat('yyyy-MM-dd HH:mm').format(
                event.startDate.add(Duration(hours: event.product.defrosting)));
            break;
          case AdjustmentType.closed:
            endTime = DateFormat('yyyy-MM-dd HH:mm').format(
                event.startDate.add(Duration(hours: event.product.closedTime)));
            break;
          case AdjustmentType.opened:
            endTime = DateFormat('yyyy-MM-dd HH:mm').format(
                event.startDate.add(Duration(hours: event.product.openedTime)));
            break;
          default:
        }

        final datat = await ImageUtils().createLabelWithText(
          event.product.subtitle,
          startTime,
          endTime,
          event.employee.fullName
          
          );
        final List<List<int>> data = datat['data'];
        final widthInBytes = data[0].length;
        final heightInDots = data.length;

        final buffer = Uint8List.fromList([
          ...'CLS\r\n'.codeUnits,
          ...'SIZE $labelWidth mm,$labelHeigth mm\r\n'.codeUnits,
          ...'GAP $labelGap mm, 0mm\r\n'.codeUnits,
          ...'CLS\r\n'.codeUnits,
          ...'BITMAP 0,0,$widthInBytes,$heightInDots,0,'.codeUnits,
          ...data.expand((row) => row),
          ...'PRINT $count\r\n'.codeUnits,
        ]);

        characteristic!
            .write(Uint8List.fromList(buffer), withoutResponse: true);
      }
    }
  }
}

enum AdjustmentType { defrosting, closed, opened }
