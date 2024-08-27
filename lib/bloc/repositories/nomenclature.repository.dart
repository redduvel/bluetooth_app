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
      nomenclatureBox.add(item);
    } catch (e) {
      throw Exception(e);
    }
  }

@override
Future<bool> update(int index, Nomenclature item) async {
  try {
    await Hive.box<Nomenclature>('nomenclature_box').putAt(index, item);
    return true;
  } catch (e) {
    throw Exception('Ошибка при обновлении категории: $e');
  }
}


  @override
  Future<void> delete(int index) async {
    try {
      var nomenclatureBox = Hive.box<Nomenclature>('nomenclature_box');
      nomenclatureBox.deleteAt(index);
    } catch (e) {
      throw Exception(e);
    }
  }

@override
Future<void> reorderList(int oldIndex, int newIndex) async {
  try {
    var nomenclatureBox = Hive.box<Nomenclature>('nomenclature_box');
    List<Nomenclature> nomenclatures = nomenclatureBox.values.toList();


    Nomenclature movedItem = nomenclatures.elementAt(oldIndex);

    nomenclatures.removeAt(oldIndex);

    nomenclatures.insert(newIndex, movedItem);
    nomenclatureBox.clear();
    for (var n in nomenclatures) {
      nomenclatureBox.add(n);
    }
  } catch (e) {
    throw Exception("Ошибка при перестановке: $e");
  }
}

}
