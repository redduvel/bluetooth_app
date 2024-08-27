
import 'package:hive/hive.dart';

part 'characteristic.g.dart';

@HiveType(typeId: 3)
enum MeasurementUnit {
  @HiveField(0)
  hours,

  @HiveField(1)
  minutes,

  @HiveField(2)
  days,
}

String getLocalizedMeasurementUnit(MeasurementUnit unit) {
  switch (unit) {
    case MeasurementUnit.hours:
      return 'час';
    case MeasurementUnit.minutes:
      return 'минута';
    case MeasurementUnit.days:
      return 'сутки';
  }
}


@HiveType(typeId: 4)
class Characteristic {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String shortName;

  @HiveField(2)
  final int value;

  @HiveField(3)
  final MeasurementUnit unit;

  Characteristic({
    required this.name,
    required this.value,
    required this.unit,
  }) : shortName = _generateShortName(name);

  static String _generateShortName(String name) {
    List<String> words = name.split(' ');

    if (words.length > 1) {
      return '${words.map((word) => word[0].toLowerCase()).join('.')}.';
    }

    return name.length <= 3 ? name.toLowerCase() : '${name.substring(0, 3).toLowerCase()}.';
  }

  @override
  String toString() {
    return '$shortName: $value ${getLocalizedMeasurementUnit(unit)}';
  }

}
