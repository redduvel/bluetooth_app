import 'package:bluetooth_app/clean/core/Data/datasource/remote/remote_db.dart';
import 'package:bluetooth_app/clean/core/Data/repository.dart';
import 'package:bluetooth_app/clean/core/Domain/entities/product.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ProductRepository implements IRepository<Product> {
  Product? currentProduct;

  @override
  get currentItem => currentProduct;

  @override
  set currentItem(currentItem) => currentProduct = currentItem;

  final String repositoryName;

  ProductRepository({required this.repositoryName});

  @override
  Future<void> sync() async {
    try {
      
    } catch (e) {}
  }

  @override
  List<Product> getAll() {
    try {
      var productBox = Hive.box<Product>(repositoryName);
      List<Product> products = productBox.values.toList();
      return products;
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<void> save(Product item, {bool sync = false}) async {
    try {
      var productBox = Hive.box<Product>(repositoryName);

      await productBox.put(item.id, item).whenComplete(() async {
        if (sync) {
          await RemoteDB.database.from(repositoryName).insert(item.toJson());
        }
      });
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<bool> update(Product item, {bool sync = false}) async {
    try {
      await Hive.box<Product>(repositoryName)
          .put(item.id, item)
          .whenComplete(() async {
        if (sync) {
          await RemoteDB.database.from(repositoryName).update(item.toJson()).eq('id', item.id);
        }
      });
      return true;
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<void> delete(String id, {bool sync = false}) async {
    try {
      var productBox = Hive.box<Product>(repositoryName);
      await productBox.delete(id).whenComplete(() async {
        if (sync) {
          await RemoteDB.database.from(repositoryName).delete().eq('id', id);
        }
      });
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<void> reorderList(int newIndex, int oldIndex,
      {bool sync = false}) async {
    try {
      //var employeeBox = Hive.box<Employee>('employee_box');
      //User employee = employeeBox.getAt(oldIndex)!;
      //employeeBox.deleteAt(oldIndex);
      //employeeBox.putAt(newIndex, employee);
    } catch (e) {
      throw Exception(e);
    }
  }
}
