import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:translit/translit.dart';

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

  PrinterBloc() : super(PrinterInitial()) {
    on<InitializePrinter>(_onInitializePrinter);
    on<ConnectToDevice>(_onConnectToDevice);
    on<DisconnectFromDevice>(_onDisconnectFromDevice);
    on<UpdateTsplCode>(_onUpdateTsplCode);
    on<PrintLabel>(_onPrintLabel);
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

  void _onPrintLabel(PrintLabel event, Emitter<PrinterState> emit) {
    if (state is PrinterConnected) {
      if (characteristic != null) {
        final translit = Translit();
        String product = translit.toTranslit(source: event.product.subtitle);
        String name = translit.toTranslit(source: event.employee.fullName);
        DateTime endDate = DateTime.now();

        switch (event.adjustmentType) {
          case AdjustmentType.defrosting:
            endDate.add(Duration(hours: event.product.defrosting));
            break;
          case AdjustmentType.closed:
            endDate.add(Duration(hours: event.product.closedTime));
            break;
          case AdjustmentType.opened:
            endDate.add(Duration(hours: event.product.openedTime));
            break;
        }

        String tsplCommand = '''
          CLS
          SIZE 30 mm, 20 mm
          GAP 2 mm, 0 mm
          DIRECTION 1
          TEXT 30,15,"2",0,1,1, "$product"
          TEXT 10,55,"2",0,1,1, "${DateFormat('yyyy-MM-dd HH:mm').format(event.startDate)}"
          TEXT 15,95,"2",0,1,1, "${DateFormat('yyyy-MM-dd HH:mm').format(endDate)}"
          TEXT 30,135,"2",0,1,1, "$name"
          PRINT 1,1
        ''';

        print(tsplCommand);

        List<int> bytes = utf8.encode(tsplCommand);
        characteristic!.write(Uint8List.fromList(bytes), withoutResponse: true);
      }
    }
  }
}

enum AdjustmentType {
  defrosting,
  closed,
  opened
}
