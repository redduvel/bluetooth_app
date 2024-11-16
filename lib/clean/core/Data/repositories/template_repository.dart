import 'package:bluetooth_app/clean/core/Data/repository.dart';
import 'package:bluetooth_app/clean/core/Domain/entities/marking/template.dart';
import 'package:hive_flutter/hive_flutter.dart';

class TemplateRepository implements IRepository<Template> {
  Template? currentTemplate;

  @override
  get currentItem => currentTemplate;

  @override
  set currentItem(currentItem) => currentTemplate = currentItem;

  final String repositoryName;

  TemplateRepository({required this.repositoryName});

  @override
  Future<void> delete(String id, {bool sync = false}) async {
    try {
      var templateBox = Hive.box<Template>(repositoryName);
      await templateBox.delete(id);
    } catch (e) {
      throw Exception(e);
    }
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
  Future<void> save(Template model, {bool sync = false}) async {
    try {
      var templateBox = Hive.box<Template>(repositoryName);
      await templateBox.put(model.id, model);
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  List<Template> search(String query) {
    try {
      final data = getAll();

      final searchResult = data.where((d) {
        final itemName = d.name.toLowerCase();
        final input = query.toLowerCase();

        return itemName.contains(input);
      }).toList();

      return searchResult;
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<List<Template>> sync() {
    // TODO: implement sync
    throw UnimplementedError();
  }

  @override
  Future<void> update(Template model, {bool sync = false}) async {
    try {
      await Hive.box<Template>(repositoryName).put(model.id, model);
    } catch (e) {
      throw Exception(e);
    }
  }
}
