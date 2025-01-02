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
  Future<void> reorderList(int newIndex, int oldIndex,
      {bool sync = false}) async {}

  @override
  Future<void> save(Template template, {bool sync = false}) async {
    try {
      var templateBox = Hive.box<Template>(repositoryName);

      await templateBox.put(template.id, template);
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<List<Template>> sync() async {
    try {
      var templateBox = Hive.box<Template>(repositoryName);
      List<Template> templates = templateBox.values.toList();
      return templates;
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<bool> update(Template template, {bool sync = false}) async {
    try {
      await Hive.box<Template>(repositoryName).put(template.id, template);
      return true;
    } catch (e) {
      throw Exception(e);
    }
  }
  @override
  List<Template> search(String query) {
    // TODO: implement search
    throw UnimplementedError();
  }
}
