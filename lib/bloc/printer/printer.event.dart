import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:equatable/equatable.dart';

abstract class PrinterEvent extends Equatable {
  const PrinterEvent();

  @override
  List<Object> get props => [];
}

class InitializePrinter extends PrinterEvent {}

class ConnectToDevice extends PrinterEvent {
  final BluetoothDevice device;

  const ConnectToDevice(this.device);

  @override
  List<Object> get props => [device];
}

class DisconnectFromDevice extends PrinterEvent {}

class ScanForDevices extends PrinterEvent {}

class UpdateTsplCode extends PrinterEvent {
  final String tsplCode;

  const UpdateTsplCode(this.tsplCode);

  @override
  List<Object> get props => [tsplCode];
}

class PrintLabel extends PrinterEvent {}
