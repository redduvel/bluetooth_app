import 'package:bluetooth_app/clean/core/Domain/entities/marking/characteristic.dart';
import 'package:bluetooth_app/clean/core/Domain/entities/marking/product.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'template_entry.g.dart';

@HiveType(typeId: 8)
class TemplateEntry {
  @HiveField(0)
  final Product product;
@HiveField(1)
  final Characteristic? characteristic;
@HiveField(2)
  final int count;

  TemplateEntry(this.product, this.characteristic, this.count);
}
