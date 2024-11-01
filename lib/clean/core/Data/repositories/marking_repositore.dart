import 'package:bluetooth_app/clean/core/Data/repository.dart';
import 'package:bluetooth_app/clean/core/Domain/entities/marking_db/marking.dart';
import 'package:hive_flutter/hive_flutter.dart';

class MarkingRepositore implements IRepository<Marking> {
  Marking? currentMarking;

  @override
  get currentItem => currentMarking;

  @override
  set currentItem(currentItem) => currentMarking = currentItem;

  final String repositoryName;

  MarkingRepositore({required this.repositoryName});

  @override
  Future<void> delete(String id, {bool sync = false}) async {
    try {
      var markingBox = Hive.box<Marking>(repositoryName);
      await markingBox.delete(id);
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  List<Marking> getAll() {
    try {
      var markingBox = Hive.box<Marking>(repositoryName);
      List<Marking> markings = markingBox.values.toList();
      return markings;
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<void> reorderList(int newIndex, int oldIndex, {bool sync = false}) {
    throw UnimplementedError();
  }

  @override
  Future<void> save(Marking model, {bool sync = false}) async {
    try {
      var markingBox = Hive.box<Marking>(repositoryName);

      await markingBox.put(model.id, model);
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<List<Marking>> sync() {
    // TODO: implement sync
    throw UnimplementedError();
  }

  @override
  Future<void> update(Marking model, {bool sync = false}) async {
    try {
      await Hive.box<Marking>(repositoryName).put(model.id, model);
    } catch (e) {
      throw Exception(e);
    }
  }
}
