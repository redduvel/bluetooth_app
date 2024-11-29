import 'package:bluetooth_app/clean/core/Domain/entities/marking/characteristic.dart';
import 'package:bluetooth_app/clean/core/Domain/entities/marking/product.dart';
import 'package:bluetooth_app/clean/core/tools/id_generator.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'template.g.dart';

@HiveType(typeId: 8)
class Template extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final List<Product> listProducts;

  @HiveField(2)
  final List<Characteristic> listChars;

  @HiveField(3)
  final String title;

  Template(
      {String? id,
      required this.listProducts,
      required this.listChars,
      required this.title})
      : id = id ?? IdGenerator.generate();

  Template copyWith(
      {String? id,
      List<Product>? listProducts,
      List<Characteristic>? listChars,
      String? title}) {
    return Template(
        id: id ?? this.id,
        listProducts: listProducts ?? this.listProducts,
        listChars: listChars ?? this.listChars,
        title: title ?? this.title);
  }

  // Метод для сериализации в JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'listProducts': listProducts,
      'title': title,
    };
  }

  // Метод для десериализации из JSON
  factory Template.fromJson(Map<String, dynamic> json) {
    return Template(
      id: json['id'],
      listProducts: json['listProducts'],
      listChars: json['listChars'],
      title: json['title'],
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Template && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
