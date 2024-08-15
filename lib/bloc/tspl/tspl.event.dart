import 'package:bluetooth_app/models/employee.dart';
import 'package:bluetooth_app/models/product.dart';
import 'package:equatable/equatable.dart';

abstract class TsplEvent extends Equatable {
  const TsplEvent();

  @override
  List<Object> get props => [];
}

class SetCurrentProduct extends TsplEvent {
  final Product product;

  const SetCurrentProduct(this.product);

  @override
  List<Object> get props => [product];
}

class SetCurrentEmployee extends TsplEvent {
  final Employee employee;

  const SetCurrentEmployee(this.employee);

  @override
  List<Object> get props => [employee];
}

class SetSelectedTime extends TsplEvent {
  final DateTime selectedTime;

  const SetSelectedTime(this.selectedTime);

  @override
  List<Object> get props => [selectedTime];
}

class SetTimeAdjustment extends TsplEvent {
  final String adjustmentType; // 'defrosting', 'closedTime', 'openedTime'

  const SetTimeAdjustment(this.adjustmentType);

  @override
  List<Object> get props => [adjustmentType];
}

class GenerateLabel extends TsplEvent {}
