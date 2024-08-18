import 'package:bluetooth_app/bloc/repository.dart';
import 'package:bluetooth_app/models/nomenclature.dart';
import 'package:bluetooth_app/models/product.dart';
import 'package:hive_flutter/hive_flutter.dart';

class NomenclatureRepository implements Repository<Nomenclature> {
  Nomenclature? currentNomenclature;

  @override
  get currentItem => currentNomenclature;

  @override
  set currentItem(currentItem) =>
    currentNomenclature = currentItem;

  @override
  Future<List<Nomenclature>> getAll() async {
    try {
      var nomenclatureBox = Hive.box<Nomenclature>('nomenclature_box');
      List<Nomenclature> nomenclatures = nomenclatureBox.values.toList();
      return nomenclatures;
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<void> add(Nomenclature item) async {
    try {
      var nomenclatureBox = Hive.box<Nomenclature>('nomenclature_box');
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
}
