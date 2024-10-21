import 'package:bluetooth_app/clean/core/Domain/entities/characteristic.dart';

class PrintingUsecase {
  static DateTime setAdjustmentTime(
      DateTime startTime, Characteristic characteristic) {
    switch (characteristic.unit) {
      case MeasurementUnit.hours:
        return startTime.add(Duration(hours: characteristic.value));
      case MeasurementUnit.minutes:
        return startTime.add(Duration(minutes: characteristic.value));
      case MeasurementUnit.days:
        return startTime.add(Duration(days: characteristic.value));
      default:
        throw ArgumentError('Unknown MeasurementUnit: ${characteristic.unit}');
    }
  }
}
