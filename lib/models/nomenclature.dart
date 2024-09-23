import 'package:bluetooth_app/tools/id_generator.dart';
import 'package:hive/hive.dart';
part 'nomenclature.g.dart';

@HiveType(typeId: 1)
class Nomenclature extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final int order;

  @HiveField(2)
  final String name;

  @HiveField(3)
  final bool isHide;

  Nomenclature({String? id, required this.order, required this.name, required this.isHide}) : id = id ?? IdGenerator.generate();

  Nomenclature copyWith({
    String? id,
    int? order,
    String? name,
    bool? isHide
  }) {
    return Nomenclature(
      id: id ?? this.id,
      order: order ?? this.order,
      name: name ?? this.name,
      isHide: isHide ?? this.isHide
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Nomenclature && other.id == id);

  @override
  int get hashCode => id.hashCode;
}

