import 'package:bluetooth_app/clean/core/Data/repository.dart';
import 'package:bluetooth_app/clean/core/Domain/entities/marking/template.dart';
import 'package:hive_flutter/hive_flutter.dart';

class TemplateRepository implements IRepository {
  Template? currentTemplate;

  @override
  get currentItem => currentTemplate;

  @override
  set currentItem(currentItem) => currentTemplate = currentItem;

  final String repositoryName;

  TemplateRepository({required this.repositoryName});

  @override
  Future<void> delete(String id, {bool sync = false}) {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  List<Template> getAll() {
    try {
      var templateBox = Hive.box<Template>(repositoryName);
      List<Template> templates = templateBox.values.toList();
      return templates;
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<void> reorderList(int newIndex, int oldIndex, {bool sync = false}) {
    // TODO: implement reorderList
    throw UnimplementedError();
  }

  @override
  Future<void> save(model, {bool sync = false}) {
    // TODO: implement save
    throw UnimplementedError();
  }

  @override
  Future<List> sync() {
    // TODO: implement sync
    throw UnimplementedError();
  }

  @override
  Future<void> update(model, {bool sync = false}) {
    // TODO: implement update
    throw UnimplementedError();
  }
}
