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
  Future<List<Nomenclature>> getAll() async {
    try {
      var nomenclatureBox = Hive.box<Nomenclature>('nomenclature_box');
      List<Nomenclature> nomenclatures = nomenclatureBox.values.toList();
      print(
          'GET NOMENCLATURES=================================================================');
      for (var i in nomenclatures) {
        print("${i.id} | ${i.name}");
      }
      return nomenclatures;
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<void> add(Nomenclature item) async {
    try {
      var nomenclatureBox = Hive.box<Nomenclature>('nomenclature_box');
      nomenclatureBox.add(item);
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<bool> update(Nomenclature item) async {
    try {
      var nomenclatureBox =
          Hive.box<Nomenclature>('nomenclature_box').values.toList();

      int updateIndex = nomenclatureBox.indexWhere((n) => n.id == item.id);

      await Hive.box<Nomenclature>('nomenclature_box').putAt(updateIndex, item);

      var productsBox = Hive.box<Product>('products_box');
      var allProducts = productsBox.values.toList();

      for (int i = 0; i < allProducts.length; i++) {
        var product = allProducts[i];
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
  Future<void> reorderList(int oldIndex, int newIndex) async {
    try {
      var nomenclatureBox = Hive.box<Nomenclature>('nomenclature_box');

      final oldItem = nomenclatureBox.get(oldIndex);
      final newItem = nomenclatureBox.get(newIndex);
      update(newItem!.copyWith(id: oldItem!.id));
      update(oldItem.copyWith(id: newItem.id));
    } catch (e) {
      throw Exception("Ошибка при перестановке: $e");
    }
  }
}
