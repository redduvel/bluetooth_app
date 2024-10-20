import 'package:bluetooth_app/clean/core/utils/id_generator.dart';
import 'package:hive/hive.dart';

import 'category.dart';
import 'characteristic.dart';

part 'product.g.dart';

@HiveType(typeId: 2)
class Product extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final String subtitle;
  @HiveField(3)
  final List<Characteristic> characteristics;
  @HiveField(4)
  late final Category category;
  @HiveField(5)
  final bool isHide;
  @HiveField(6)
  final bool allowFreeTime;

  Product(
      {String? id,
      required this.title,
      required this.subtitle,
      required this.characteristics,
      required this.category,
      required this.isHide,
      required this.allowFreeTime})
      : id = id ?? IdGenerator.generate();

  // Метод для копирования объекта
  Product copyWith({
    String? id,
    String? title,
    String? subtitle,
    List<Characteristic>? characteristics,
    Category? category,
    bool? isHide,
    bool? allowFreeTime
  }) {
    return Product(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      characteristics: characteristics ?? this.characteristics,
      category: category ?? this.category,
      isHide: isHide ?? this.isHide,
      allowFreeTime: allowFreeTime ?? this.allowFreeTime
    );
  }

  // Метод для сериализации в JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'characteristics': characteristics.map((c) => c.toJson()).toList(),
      'category': category.toJson(),
      'isHide': isHide,
      'allowFreeMarking': allowFreeTime,
    };
  }

  // Метод для десериализации из JSON
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      title: json['title'],
      subtitle: json['subtitle'],
      characteristics: (json['characteristics']['c'] as List)
          .map((c) => Characteristic.fromJson(c))
          .toList(),
      category: Category.fromJson(json['category']),
      isHide: json['isHide'],
      allowFreeTime: json['allowFreeMarking'],
    );
  }
}
