import 'package:bluetooth_app/tools/id_generator.dart';
import 'package:hive/hive.dart';
part 'employee.g.dart';

@HiveType(typeId: 0)
class Employee extends HiveObject {
  @HiveField(0)
  final String fullName;

  Employee({
    String? id,
    required this.fullName});


  Employee copyWith({
    String? fullName,
  }) {
    return Employee(
      fullName: fullName ?? this.fullName,

    );
  }
}