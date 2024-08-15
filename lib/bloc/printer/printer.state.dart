import 'package:equatable/equatable.dart';
import 'package:flutter_blue/flutter_blue.dart';

abstract class PrinterState extends Equatable {
  const PrinterState();

  @override
  List<Object> get props => [];
}

class PrinterInitial extends PrinterState {}

class PrinterLoading extends PrinterState {}

class PrinterConnected extends PrinterState {
  final BluetoothDevice device;
  final BluetoothCharacteristic characteristic;

  const PrinterConnected(this.device, this.characteristic);

  @override
  List<Object> get props => [device, characteristic];
}

class PrinterDisconnected extends PrinterState {}

class DevicesLoaded extends PrinterState {
  final List<BluetoothDevice> devices;
  final BluetoothDevice? connectedDevice;

  const DevicesLoaded(this.devices, [this.connectedDevice]);

  @override
  List<Object> get props => [devices, connectedDevice ?? ''];
}


class TsplUpdated extends PrinterState {
  final String tsplCode;

  const TsplUpdated(this.tsplCode);

  @override
  List<Object> get props => [tsplCode];
}
