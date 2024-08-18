import 'package:bluetooth_app/tools/id_generator.dart';
import 'package:hive/hive.dart';
part 'nomenclature.g.dart';

@HiveType(typeId: 1)
class Nomenclature extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final bool isHide;

  Nomenclature({String? id, required this.name, required this.isHide}) : id = id ?? IdGenerator.generate();

  Nomenclature copyWith({
    String? id,
    String? name,
    bool? isHide
  }) {
    return Nomenclature(
      id: id ?? this.id,
      name: name ?? this.name,
      isHide: isHide ?? this.isHide
    );
  }
}