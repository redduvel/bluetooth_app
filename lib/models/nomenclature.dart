import 'package:hive/hive.dart';
part 'nomenclature.g.dart';

@HiveType(typeId: 1)
class Nomenclature extends HiveObject {
  @HiveField(0)
  late String name;

  Nomenclature({required this.name});
}