import 'package:bluetooth_app/bloc/printer/printer.bloc.dart';
import 'package:bluetooth_app/models/employee.dart';
import 'package:bluetooth_app/models/product.dart';
import 'package:flutter_blue/flutter_blue.dart';
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

class DisconnectFromDevice extends PrinterEvent {
  final BluetoothDevice device;

  const DisconnectFromDevice(this.device);

  @override
  List<Object> get props => [device];
}

class ScanForDevices extends PrinterEvent {}

class UpdateTsplCode extends PrinterEvent {
  final String tsplCode;

  const UpdateTsplCode(this.tsplCode);

  @override
  List<Object> get props => [tsplCode];
}

class PrintLabel extends PrinterEvent {
  final Product product;
  final Employee employee;
  final DateTime startDate;
  final AdjustmentType adjustmentType;

  const PrintLabel({
    required this.product,
    required this. employee,
    required this.startDate,
    required this.adjustmentType
  });

  @override
  List<Object> get props => [product, employee, startDate, adjustmentType];
}
