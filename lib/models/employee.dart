import 'package:hive/hive.dart';
part 'employee.g.dart';

@HiveType(typeId: 0)
class Employee extends HiveObject {
  @HiveField(0)
  final String firstName;

  @HiveField(1)
  final String lastName;

  Employee({required this.firstName, required this.lastName});
}