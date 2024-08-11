// printer.state.dart
import 'package:bluetooth_app/models/template_item.dart';
import 'package:equatable/equatable.dart';
import 'package:bluetooth_print/bluetooth_print_model.dart';

class BluetoothState extends Equatable {
  final List<TemplateItem> templateItems;

  const BluetoothState({this.templateItems = const []});

  BluetoothState copyWith({List<TemplateItem>? templateItems}) {
    return BluetoothState(
      templateItems: templateItems ?? this.templateItems,
    );
  }

  @override
  List<Object> get props => [templateItems];
}

class BluetoothInitial extends BluetoothState {}

class BluetoothScanning extends BluetoothState {}

class BluetoothConnected extends BluetoothState {
  final BluetoothDevice device;

  const BluetoothConnected(this.device);

  @override
  List<Object> get props => [device];
}

class BluetoothDisconnected extends BluetoothState {}

class BluetoothPrintSuccess extends BluetoothState {}

class BluetoothPrintFailure extends BluetoothState {
  final String message;

  const BluetoothPrintFailure(this.message);

  @override
  List<Object> get props => [message];
}
