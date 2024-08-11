// printer.event.dart
import 'package:bluetooth_app/models/template_item.dart';
import 'package:bluetooth_print/bluetooth_print_model.dart';
import 'package:equatable/equatable.dart';

abstract class BluetoothEvent extends Equatable {
  const BluetoothEvent();

  @override
  List<Object> get props => [];
}

class StartScan extends BluetoothEvent {}

class StopScan extends BluetoothEvent {}

class ConnectDevice extends BluetoothEvent {
  final BluetoothDevice device;

  const ConnectDevice(this.device);

  @override
  List<Object> get props => [device];
}

class DisconnectDevice extends BluetoothEvent {}

class PrintReceipt extends BluetoothEvent {}

class PrintLabel extends BluetoothEvent {}

class PrintTest extends BluetoothEvent {}

class AddTemplateItem extends BluetoothEvent {
  final TemplateItem item;

  const AddTemplateItem(this.item);

  @override
  List<Object> get props => [item];
}

class RemoveTemplateItem extends BluetoothEvent {
  final int index;

  const RemoveTemplateItem(this.index);

  @override
  List<Object> get props => [index];
}

class PrintTemplate extends BluetoothEvent {}