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
  @HiveField(7) // Новое поле для локального хранения
  int? backgroundColor;

  Product({
    String? id,
    required this.title,
    required this.subtitle,
    required this.characteristics,
    required this.category,
    required this.isHide,
    required this.allowFreeTime,
    this.backgroundColor, // Инициализация цвета
  }) : id = id ?? IdGenerator.generate();

  Product copyWith({
    String? id,
    String? title,
    String? subtitle,
    List<Characteristic>? characteristics,
    Category? category,
    bool? isHide,
    bool? allowFreeTime,
    int? backgroundColor, // Обновление цвета
  }) {
    return Product(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      characteristics: characteristics ?? this.characteristics,
      category: category ?? this.category,
      isHide: isHide ?? this.isHide,
      allowFreeTime: allowFreeTime ?? this.allowFreeTime,
      backgroundColor: backgroundColor ?? this.backgroundColor,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'characteristics': {"c": characteristics.map((c) => c.toJson()).toList()},
      'category': category.id,
      'isHide': isHide,
      'allowFreeMarking': allowFreeTime,
      // backgroundColor не добавляется в JSON для удаленной базы
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      title: json['title'],
      subtitle: json['subtitle'],
      characteristics: (json['characteristics']["c"] as List)
          .map((c) => Characteristic.fromJson(c))
          .toList(),
      category: Category.fromJson(json['category']),
      isHide: json['isHide'],
      allowFreeTime: json['allowFreeMarking'],
      // backgroundColor не загружается из JSON удаленной базы
    );
  }

  Product setColor(int color) {
    backgroundColor = color;
    return this;
  }
}