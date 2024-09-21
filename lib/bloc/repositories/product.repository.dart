import 'package:bluetooth_app/bloc/repository.dart';
import 'package:bluetooth_app/models/product.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ProductRepository implements Repository<Product> {
  Product? currentProduct;

  @override
  get currentItem => currentProduct;

  @override
  set currentItem(currentItem) => currentProduct = currentItem;

  @override
  Future<void> add(Product item) async {
    try {
      var productBox = Hive.box<Product>('products_box');
      
      productBox.put(item.id, item);
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      var productBox = Hive.box<Product>('products_box');
      productBox.delete(id);
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<List<Product>> getAll() async {
    try {
      var productBox = Hive.box<Product>('products_box');
      List<Product> products = productBox.values.toList();
      return products;
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<bool> update(Product item) async {
    try {
      await Hive.box<Product>('products_box').put(item.id, item);
      return true;
    } catch (e) {
      throw Exception(e);
    }
  }

    @override
  Future<void> reorderList(int newIndex, int oldIndex) async {
    try {
      var productBox = Hive.box<Product>('products_box');
      Product product = productBox.getAt(oldIndex)!;
      productBox.deleteAt(oldIndex);
      productBox.putAt(newIndex, product);

    } catch (e) {
      throw Exception(e);
    }
  }
}