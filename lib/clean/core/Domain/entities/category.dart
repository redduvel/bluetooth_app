import 'package:bluetooth_app/clean/core/utils/id_generator.dart';
import 'package:hive/hive.dart';

part 'generated/category.g.dart';

@HiveType(typeId: 1)
class Category extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final int order;

  @HiveField(2)
  final String name;

  @HiveField(3)
  final bool isHide;

  Category(
      {String? id,
      required this.order,
      required this.name,
      required this.isHide})
      : id = id ?? IdGenerator.generate();

  Category copyWith({String? id, int? order, String? name, bool? isHide}) {
    return Category(
        id: id ?? this.id,
        order: order ?? this.order,
        name: name ?? this.name,
        isHide: isHide ?? this.isHide);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Category && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
