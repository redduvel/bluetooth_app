import 'package:bluetooth_app/tools/id_generator.dart';
import 'package:hive/hive.dart';
part 'employee.g.dart';

@HiveType(typeId: 0)
class Employee extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String firstName;

  @HiveField(2)
  final String lastName;

  Employee({
    String? id,
    required this.firstName, 
    required this.lastName}): id = id ?? IdGenerator.generate(); 
}