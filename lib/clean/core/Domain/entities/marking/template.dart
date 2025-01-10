import 'package:bluetooth_app/clean/core/Domain/entities/marking/template_entry.dart';
import 'package:bluetooth_app/clean/core/tools/id_generator.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'template.g.dart';

@HiveType(typeId: 7)
class Template extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final List<TemplateEntry> listProducts;

  @HiveField(2)
  final String title;

  Template({String? id, required this.listProducts, required this.title})
      : id = id ?? IdGenerator.generate();

  Template copyWith({String? id, List<TemplateEntry>? listProducts, String? title}) {
    return Template(
        id: id ?? this.id,
        listProducts: listProducts ?? this.listProducts,
        title: title ?? this.title);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Template && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
