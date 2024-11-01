import 'package:bluetooth_app/clean/core/Domain/entities/marking/product.dart';
import 'package:bluetooth_app/clean/core/Domain/entities/marking/user.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:equatable/equatable.dart';

abstract class PrinterEvent extends Equatable {
  const PrinterEvent();

  @override
  List<Object> get props => [];
}

class InitializePrinter extends PrinterEvent {}

class CheckConnection extends PrinterEvent {}

class ReconnectToDevice extends PrinterEvent {}

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

class SetSettings extends PrinterEvent {
  final String height;
  final String width;
  final String gap;

  const SetSettings({
    required this.height,
    required this.width,
    required this.gap
  });

  @override
  List<Object> get props => [height, width, gap];
}

class PrintLabel extends PrinterEvent {
  final Product product;
  final User employee;
  final DateTime startDate;
  final int characteristicIndex;
  final String count;

  const PrintLabel({
    required this.product,
    required this. employee,
    required this.startDate,
    required this.characteristicIndex,
    required this.count,
  });

  @override
  List<Object> get props => [product, employee, startDate, characteristicIndex, count];
}
