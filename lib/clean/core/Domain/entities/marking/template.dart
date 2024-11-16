import 'package:bluetooth_app/clean/core/Domain/entities/marking/product.dart';
import 'package:bluetooth_app/clean/core/tools/id_generator.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'template.g.dart';

@HiveType(typeId: 7)
class Template extends HiveObject {
  @HiveField(0)
  String id;
  @HiveField(1)
  String name;
  @HiveField(2)
  List<Product> products;

  Template({
    String? id,
    required this.name,
    required this.products
  }) : id = id ?? IdGenerator.generate();


  Template copyWith({String? id, String? name, List<Product>? products}) {
    return Template(id: id ?? this.id, name: name ?? this.name, products: products ?? this.products);
  }
}