import 'package:bluetooth_app/clean/core/utils/id_generator.dart';
import 'package:hive/hive.dart';

part 'generated/employee.g.dart';

@HiveType(typeId: 0)
class Employee extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String fullName;

  Employee({String? id, required this.fullName})
      : id = id ?? IdGenerator.generate();

  Employee copyWith({
    String? id,
    String? fullName,
  }) {
    return Employee(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
    );
  }
}
