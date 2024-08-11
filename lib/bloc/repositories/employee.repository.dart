import 'package:bluetooth_app/bloc/repository.dart';
import 'package:bluetooth_app/models/employee.dart';
import 'package:hive_flutter/hive_flutter.dart';

class EmployeeRepository implements Repository<Employee> {
  Employee? currentEmployee;

  @override
  get currentItem => currentEmployee;

  @override
  set currentItem(currentItem) =>
    currentEmployee = currentItem;
  

  @override
  Future<List<Employee>> getAll() async {
    try {
      var employeeBox = Hive.box<Employee>('employee_box');
      List<Employee> employees = employeeBox.values.toList();
      return employees;
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<void> add(Employee item) async {
    try {
      var employeeBox = Hive.box<Employee>('employee_box');
      employeeBox.put(item.lastName, item);
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<void> update(Employee item) async {
    // Реализация обновления сотрудника
  }

  @override
  Future<void> delete(String id) async {
    try {
      var employeeBox = Hive.box<Employee>('employee_box');
      employeeBox.delete(id);
    } catch (e) {
      throw Exception(e);
    }
  }
}
