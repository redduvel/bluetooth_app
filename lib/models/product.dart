import 'package:bluetooth_app/tools/id_generator.dart';
import 'package:hive/hive.dart';
part 'product.g.dart';

@HiveType(typeId: 2)
class Product extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String subtitle;

  @HiveField(3)
  final int defrosting;

  @HiveField(4)
  final int closedTime;

  @HiveField(5)
  final int openedTime;

  @HiveField(6)
  final String category;

  @HiveField(7)
  final bool isHide;

  Product(
      {String? id,
      required this.title,
      required this.subtitle,
      required this.defrosting,
      required this.closedTime,
      required this.openedTime,
      required this.category,
      required this.isHide})
      : id = id ?? IdGenerator.generate();

  
  Product copyWith({
    String? id,
    String? title,
    String? subtitle,
    int? defrosting,
    int? closedTime,
    int? openedTime,
    String? category,
    bool? isHide,
  }) {
    return Product(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      defrosting: defrosting ?? this.defrosting,
      closedTime: closedTime ?? this.closedTime,
      openedTime: openedTime ?? this.openedTime,
      category: category ?? this.category,
      isHide: isHide ?? this.isHide,
    );
  }
}
