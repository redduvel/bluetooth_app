import 'dart:async'; // Добавляем для таймера
import 'package:hive/hive.dart';
import 'package:flutter/services.dart';
import 'package:bluetooth_app/services/image_utils.dart';
import 'package:bluetooth_app/tools/extra.dart';
import 'package:intl/intl.dart';
import 'package:bluetooth_app/bloc/printer/printer.event.dart';
import 'package:bluetooth_app/bloc/printer/printer.state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class PrinterBloc extends Bloc<PrinterEvent, PrinterState> {
  List<BluetoothDevice> devices = [];
  BluetoothDevice? connectedDevice;
  BluetoothCharacteristic? characteristic;

  // LABEL SETTINGS
  late String labelHeigth;
  late String labelWidth;
  late String labelGap;

  // HIVE SETTINGS
  final Box _settingsBox = Hive.box('settings');
  final String _lastDeviceKey = 'last_connected_device';

  Timer? _connectionCheckTimer;

  PrinterBloc() : super(PrinterInitial()) {
    on<InitializePrinter>(_onInitializePrinter);
    on<ConnectToDevice>(_onConnectToDevice);
    on<DisconnectFromDevice>(_onDisconnectFromDevice);
    on<PrintLabel>(_onPrintLabel);
    on<SetSettings>(_onSetSettings);
    on<CheckConnection>(_checkConnection);

    _startConnectionCheckTimer();


    labelHeigth = _settingsBox.get('label_height') ?? '20';
    labelWidth = _settingsBox.get('label_width') ?? '30';
    labelGap = _settingsBox.get('label_gap') ?? '3';
  }

  Future<void> _saveLastConnectedDevice(String address) async {
    await _settingsBox.put(_lastDeviceKey, address);
  }

  String? _loadLastConnectedDevice() {
    return _settingsBox.get(_lastDeviceKey);
  }

  void _startConnectionCheckTimer() {
    _connectionCheckTimer?.cancel();
    _connectionCheckTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      add(CheckConnection());
    });
  }

  @override
  Future<void> close() {
    _connectionCheckTimer?.cancel();
    return super.close();
  }

  Future<void> _attemptReconnectToSavedDevice() async {
    String? lastDeviceAddress = _loadLastConnectedDevice();
    if (lastDeviceAddress != null) {
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 2));
      FlutterBluePlus.scanResults.listen((results) async {
        for (ScanResult result in results) {
          if (result.device.remoteId.str == lastDeviceAddress) {
            add(ConnectToDevice(result.device));
            FlutterBluePlus.stopScan();
            break;
          }
        }
      });
    }
  }

  Future<void> _onInitializePrinter(
      InitializePrinter event, Emitter<PrinterState> emit) async {
    emit(PrinterLoading());
    try {
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 2));
      FlutterBluePlus.scanResults.listen((results) {
        for (ScanResult result in results) {
          if (!devices.contains(result.device)) {
            devices.add(result.device);
          }
        }
      });

      emit(DevicesLoaded(devices));
    } catch (e) {
      emit(PrinterDisconnected());
    }
  }

  Future<void> _onConnectToDevice(
      ConnectToDevice event, Emitter<PrinterState> emit) async {
    emit(PrinterLoading());
    try {
      await event.device.connectAndUpdateStream().catchError((e) {
        throw Exception(e);
      });
      connectedDevice = event.device;

      if (connectedDevice == null) return;

      await connectedDevice!.requestMtu(512);

      List<BluetoothService> services =
          await connectedDevice!.discoverServices();
      for (var service in services) {
        for (var char in service.characteristics) {
          if (char.properties.write) {
            characteristic = char;
          }
        }
      }

      await _saveLastConnectedDevice(event.device.remoteId.str);

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

      await _settingsBox.delete(_lastDeviceKey);

      emit(PrinterDisconnected());
    } catch (e) {
      emit(PrinterDisconnected());
    }
  }

  Future<bool> _onSetSettings(
      SetSettings event, Emitter<PrinterState> emit) async {
    try {
      labelHeigth = event.height;
      labelWidth = event.width;
      labelGap = event.gap;

      _settingsBox.put('label_height', labelHeigth);
      _settingsBox.put('label_width', labelWidth);
      _settingsBox.put('label_gap', labelGap);

      return true;
    } catch (e) {
      throw Exception('Error set settings');
    }
  }

  Future<bool> _checkConnection(
      CheckConnection event, Emitter<PrinterState> emit) async {
    try {
      if (connectedDevice == null && characteristic == null) {
        _attemptReconnectToSavedDevice();
        return false;
      } else {
        return true;
      }
    } catch (e) {
      throw Exception(e);
    }
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
            event.employee.fullName);
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
            .splitWritee(Uint8List.fromList(buffer), timeout: 15);
      }
    }
  }
}

enum AdjustmentType { defrosting, closed, opened }
