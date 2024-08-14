import 'package:bluetooth_app/bloc/printer/printer.event.dart';
import 'package:bluetooth_app/bloc/printer/printer.state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';

class PrinterBloc extends Bloc<PrinterEvent, PrinterState> {
  final BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;

  PrinterBloc() : super(PrinterInitial()) {
    on<InitializePrinter>(_onInitializePrinter);
    on<ScanForDevices>(_onScanForDevices);
    on<ConnectToDevice>(_onConnectToDevice);
    on<DisconnectFromDevice>(_onDisconnectFromDevice);
    on<UpdateTsplCode>(_onUpdateTsplCode);
    on<PrintLabel>(_onPrintLabel);
  }

  Future<void> _onInitializePrinter(
      InitializePrinter event, Emitter<PrinterState> emit) async {
    emit(PrinterLoading());
    try {
      bool isConnected = await bluetooth.isConnected ?? false;
      if (isConnected) {
        await bluetooth.getBondedDevices().then((value) {
          emit(PrinterConnected(value.first));
        });
        
      } else {
        emit(PrinterDisconnected());
      }
    } catch (e) {
      emit(PrinterDisconnected());
    }
  }

Future<void> _onScanForDevices(
    ScanForDevices event, Emitter<PrinterState> emit) async {
  emit(PrinterLoading());
  try {
    final devices = await bluetooth.getBondedDevices();
    BluetoothDevice? connectedDevice;

    // Проверяем подключение для каждого устройства
    for (BluetoothDevice device in devices) {
      bool isConnected = await bluetooth.isConnected ?? false;
      if (isConnected) {
        connectedDevice = device;
        break;
      }
    }

    emit(DevicesLoaded(devices, connectedDevice));
  } catch (e) {
    emit(PrinterDisconnected());
  }
}



  Future<void> _onConnectToDevice(
      ConnectToDevice event, Emitter<PrinterState> emit) async {
    emit(PrinterLoading());
    try {
      await bluetooth.connect(event.device);
      emit(PrinterConnected(event.device));
    } catch (e) {
      emit(PrinterDisconnected());
    }
  }

  Future<void> _onDisconnectFromDevice(
      DisconnectFromDevice event, Emitter<PrinterState> emit) async {
    emit(PrinterLoading());
    try {
      await bluetooth.disconnect();
      emit(PrinterDisconnected());
    } catch (e) {
      emit(PrinterDisconnected());
    }
  }

  void _onUpdateTsplCode(UpdateTsplCode event, Emitter<PrinterState> emit) {
    emit(TsplUpdated(event.tsplCode));
  }

  void _onPrintLabel(PrintLabel event, Emitter<PrinterState> emit) {
    if (state is TsplUpdated && state is PrinterConnected) {
      final tsplCode = (state as TsplUpdated).tsplCode;
      bluetooth.write(tsplCode);
    }
  }
}
