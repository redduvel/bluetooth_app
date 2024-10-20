import 'package:bluetooth_app/clean/core/utils/id_generator.dart';
import 'package:hive/hive.dart';

part 'category.g.dart';

@HiveType(typeId: 0)
class Category extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;

  @HiveField(2)
  final int order;

  @HiveField(3)
  final bool isHide;

  Category(
      {String? id,
      required this.name,
      required this.order,
      required this.isHide,
      })
      : id = id ?? IdGenerator.generate();

  Category copyWith({String? id, int? order, String? name, bool? isHide}) {
    return Category(
        id: id ?? this.id,
        order: order ?? this.order,
        name: name ?? this.name,
        isHide: isHide ?? this.isHide);
  }

  // Метод для сериализации в JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order': order,
      'name': name,
      'isHide': isHide,
    };
  }

  // Метод для десериализации из JSON
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      order: json['order'],
      name: json['name'],
      isHide: json['isHide'],
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Category && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
