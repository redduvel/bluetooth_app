import 'package:hive/hive.dart';
part 'product.g.dart';

@HiveType(typeId: 2)
class Product extends HiveObject {
  @HiveField(0)
  final String title;

  @HiveField(1)
  final String subtitle;

  @HiveField(2)
  final int defrosting;

  @HiveField(3)
  final int closedTime;

  @HiveField(4)
  final int openedTime;

  @HiveField(5)
  final String category;

  Product({required this.title, required this.subtitle, required this.defrosting, required this.closedTime, required this.openedTime, required this.category});
}