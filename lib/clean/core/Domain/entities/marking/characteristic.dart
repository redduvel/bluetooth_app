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
      return 'ч.';
    case MeasurementUnit.minutes:
      return 'мин.';
    case MeasurementUnit.days:
      return 'дн.';
  }
}

@HiveType(typeId: 4)
class Characteristic extends HiveObject {
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

  // Генерация короткого имени
  static String _generateShortName(String name) {
    List<String> words = name.split(' ');

    if (words.length > 1) {
      return '${words.map((word) => word[0].toLowerCase()).join('.')}.';
    }

    return name.length <= 3
        ? name.toLowerCase()
        : '${name.substring(0, 3).toLowerCase()}.';
  }

  // Сериализация в JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'value': value,
      'unit': unit
          .toString()
          .split('.')
          .last, // Преобразование MeasurementUnit в строку
    };
  }

  // Десериализация из JSON
  factory Characteristic.fromJson(Map<String, dynamic> json) {
    return Characteristic(
      name: json['name'],
      value: json['value'],
      unit: MeasurementUnit.values.firstWhere((e) => e.name == json['unit']),
    );
  }

  @override
  String toString() {
    return '$shortName: $value ${getLocalizedMeasurementUnit(unit)}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Characteristic &&
        other.name == name &&
        other.shortName == shortName &&
        other.value == value &&
        other.unit == unit;
  }

  @override
  int get hashCode => name.hashCode ^ shortName.hashCode ^ value.hashCode ^ unit.hashCode;
}
