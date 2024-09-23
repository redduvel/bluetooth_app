import 'package:bluetooth_app/bloc/repository.dart';
import 'package:bluetooth_app/models/employee.dart';
import 'package:hive_flutter/hive_flutter.dart';

class EmployeeRepository implements Repository<Employee> {
  Employee? currentEmployee;

  @override
  get currentItem => currentEmployee;

  @override
  set currentItem(currentItem) => currentEmployee = currentItem;

  @override
  List<Employee> getAll() {
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
      employeeBox.put(item.id, item);
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<bool> update(Employee item) async {
    try {
      await Hive.box<Employee>('employee_box').put(item.id, item);
      return true;
    } catch (e) {
      throw Exception(e);
    }
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

  @override
  Future<void> reorderList(int newIndex, int oldIndex) async {
    try {
      var employeeBox = Hive.box<Employee>('employee_box');
      Employee employee = employeeBox.getAt(oldIndex)!;
      employeeBox.deleteAt(oldIndex);
      employeeBox.putAt(newIndex, employee);
    } catch (e) {
      throw Exception(e);
    }
  }
}
