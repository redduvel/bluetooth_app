import 'package:bluetooth_app/clean/core/Domain/entities/category.dart';
import 'package:bluetooth_app/clean/core/Domain/entities/characteristic.dart';
import 'package:bluetooth_app/clean/core/utils/id_generator.dart';
import 'package:hive/hive.dart';

part 'generated/product.g.dart';

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
}