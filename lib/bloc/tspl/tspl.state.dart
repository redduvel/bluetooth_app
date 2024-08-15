import 'package:bluetooth_app/models/employee.dart';
import 'package:bluetooth_app/models/product.dart';
import 'package:equatable/equatable.dart';

abstract class TsplState extends Equatable {
  const TsplState();

  @override
  List<Object> get props => [];
}

class LabelInitial extends TsplState {}

class LabelGenerated extends TsplState {
  final String labelContent;

  const LabelGenerated(this.labelContent);

  @override
  List<Object> get props => [labelContent];
}

class LabelSettingsUpdated extends TsplState {
  final Product currentProduct;
  final Employee currentEmployee;
  final DateTime selectedTime;
  final DateTime adjustmentTime;
  final String adjustmentType;

  const LabelSettingsUpdated({
    required this.currentProduct,
    required this.currentEmployee,
    required this.selectedTime,
    required this.adjustmentTime,
    required this.adjustmentType,
  });

  @override
  List<Object> get props =>
      [currentProduct, currentEmployee, selectedTime, adjustmentTime, adjustmentType];
}
