import 'package:bluetooth_app/bloc/repository.dart';
import 'package:bluetooth_app/models/nomenclature.dart';
import 'package:bluetooth_app/models/product.dart';
import 'package:hive_flutter/hive_flutter.dart';

class NomenclatureRepository implements Repository<Nomenclature> {
  Nomenclature? currentNomenclature;

  @override
  get currentItem => currentNomenclature;

  @override
  set currentItem(currentItem) => currentNomenclature = currentItem;

  @override
  List<Nomenclature> getAll() {
    try {
      var nomenclatureBox = Hive.box<Nomenclature>('nomenclature_box');
      List<Nomenclature> nomenclatures = nomenclatureBox.values.toList();
      nomenclatures.sort((a, b) => a.order.compareTo(b.order));
      return nomenclatures;
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<void> add(Nomenclature item) async {
    try {
      var nomenclatureBox = Hive.box<Nomenclature>('nomenclature_box');

      List<Nomenclature> userCategories =
          nomenclatureBox.values.where((n) => n.order < 100000).toList();

      int maxOrder = userCategories.isNotEmpty
          ? userCategories.map((n) => n.order).reduce((a, b) => a > b ? a : b)
          : 0;

      item = item.copyWith(order: maxOrder + 1);

      nomenclatureBox.put(item.id, item);
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<bool> update(Nomenclature item) async {
    try {
      await Hive.box<Nomenclature>('nomenclature_box').put(item.id, item);

      var productsBox = Hive.box<Product>('products_box');
      var allProducts = productsBox.values.toList();

      for (var product in allProducts) {
        if (product.category.id == item.id) {
          var updatedProduct = product.copyWith(category: item);
          await productsBox.put(product.id, updatedProduct);
        }
      }

      return true;
    } catch (e) {
      throw Exception('Ошибка при обновлении категории: $e');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      var nomenclatureBox = Hive.box<Nomenclature>('nomenclature_box');
      nomenclatureBox.delete(id);
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  void reorderList(int oldIndex, int newIndex) {
    try {
      var nomenclatureBox = Hive.box<Nomenclature>('nomenclature_box');

      final oldItem =
          nomenclatureBox.values.firstWhere((n) => n.order == oldIndex);
      final newItem =
          nomenclatureBox.values.firstWhere((n) => n.order == newIndex);

      final oldOrder = oldItem.order;
      final newOrder = newItem.order;

      nomenclatureBox.put(oldItem.id, oldItem.copyWith(order: newOrder));
      nomenclatureBox.put(newItem.id, newItem.copyWith(order: oldOrder));
    } catch (e) {
      throw Exception("Ошибка при перестановке: $e");
    }
  }

  List<Nomenclature> getFixedCategories(Box<Nomenclature> box) {
    return box.values
        .where((category) => category.order == 0 || category.order == 1)
        .toList();
  }

  List<Nomenclature> getEditableCategories(Box<Nomenclature> box) {
    return box.values.where((category) => category.order > 1).toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }
}
