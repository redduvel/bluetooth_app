import 'package:bluetooth_app/models/characteristic.dart';
import 'package:bluetooth_app/models/nomenclature.dart';
import 'package:bluetooth_app/tools/id_generator.dart';
import 'package:hive/hive.dart';
part 'product.g.dart';

@HiveType(typeId: 2)
class Product extends HiveObject {
  @HiveField(0)
  final String title;

  @HiveField(1)
  final String subtitle;

  @HiveField(2)
  final List<Characteristic> characteristics;

  @HiveField(3)
  final Nomenclature category;

  @HiveField(4)
  final bool isHide;

  Product(
      {
      required this.title,
      required this.subtitle,
      required this.characteristics,
      required this.category,
      required this.isHide});

  
  Product copyWith({
    String? title,
    String? subtitle,
    List<Characteristic>? characteristics,
    Nomenclature? category,
    bool? isHide,
  }) {
    return Product(
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      characteristics: characteristics ?? this.characteristics,
      category: category ?? this.category,
      isHide: isHide ?? this.isHide,
    );
  }
}
