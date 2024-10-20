import 'package:bluetooth_app/clean/core/Data/datasource/remote/remote_db.dart';
import 'package:bluetooth_app/clean/core/Data/repository.dart';
import 'package:bluetooth_app/clean/core/Domain/entities/category.dart';
import 'package:hive_flutter/hive_flutter.dart';

class CategoryRepository implements IRepository<Category> {
  Category? currentCategory;

  @override
  get currentItem => currentCategory;

  @override
  set currentItem(currentItem) => currentCategory = currentItem;

  final String repositoryName;

  CategoryRepository({required this.repositoryName});

  @override
  Future<void> sync() async {
    try {
      List<Category> localData = getAll();
      List<Category> remoteData = [];

      RemoteDB.database
          .from(repositoryName)
          .select()
          .eq('isHide', 'False')
          .asStream()
          .listen((List<Map<String, dynamic>> data) async {
        remoteData = data.map((map) {
          return Category.fromJson(map);
        }).toList();

        final localCategoryMap = {
          for (Category category in localData) category.id: category
        };

        final supabaseCategoryMap = {
          for (Category category in remoteData) category.id: category
        };

        for (Category category in remoteData) {
          if (localCategoryMap.containsKey(category.id)) {
            final localCategory = localCategoryMap[category.id];
            if (localCategory != category) {
              await update(category);
            }
          } else {
            await save(category);
          }
        }

        for (var category in localData) {
          if (!supabaseCategoryMap.containsKey(category.id)) {
            await delete(category.id);
          }
        }
      });
    } catch (e) {
      Exception(e);
    }
  }

  @override
  List<Category> getAll() {
    try {
      var categoriesBox = Hive.box<Category>(repositoryName);
      List<Category> categories = categoriesBox.values.toList();
      categories.sort((a, b) => a.order.compareTo(b.order));
      return categories;
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<void> save(Category item, {bool sync = false}) async {
    try {
      var nomenclatureBox = Hive.box<Category>(repositoryName);

      List<Category> userCategories =
          nomenclatureBox.values.where((n) => n.order < 100000).toList();

      int maxOrder = userCategories.isNotEmpty
          ? userCategories.map((n) => n.order).reduce((a, b) => a > b ? a : b)
          : 0;

      item = item.copyWith(order: maxOrder + 1);

      await nomenclatureBox.put(item.id, item).whenComplete(() async {
        if (sync) {
          await RemoteDB.database.from(repositoryName).insert(item.toJson());
        }
      });
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<bool> update(Category item, {bool sync = false}) async {
    try {
      await Hive.box<Category>(repositoryName)
          .put(item.id, item)
          .whenComplete(() async {
        if (sync) {
          await RemoteDB.database
              .from(repositoryName)
              .update(item.toJson())
              .eq('id', item.id);
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
      var productBox = Hive.box<Category>(repositoryName);
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
      var nomenclatureBox = Hive.box<Category>(repositoryName);

      final oldItem =
          nomenclatureBox.values.firstWhere((n) => n.order == oldIndex);
      final newItem =
          nomenclatureBox.values.firstWhere((n) => n.order == newIndex);

      final oldOrder = oldItem.order;
      final newOrder = newItem.order;

      await nomenclatureBox
          .put(oldItem.id, oldItem.copyWith(order: newOrder))
          .whenComplete(() async {
        if (sync) {
          await RemoteDB.database
              .from(repositoryName)
              .update(oldItem.copyWith(order: newOrder).toJson())
              .eq('id', oldItem.id);
        }
      });

      await nomenclatureBox
          .put(newItem.id, newItem.copyWith(order: oldOrder))
          .whenComplete(() async {
        if (sync) {
          await RemoteDB.database
              .from(repositoryName)
              .update(newItem.copyWith(order: oldOrder).toJson())
              .eq('id', newItem.id);
        }
      });
    } catch (e) {
      throw Exception(e);
    }
  }

  List<Category> getFixedCategories(Box<Category> box) {
    return box.values
        .where((category) => category.order == 0 || category.order == 1)
        .toList();
  }

  List<Category> getEditableCategories(Box<Category> box) {
    return box.values.where((category) => category.order > 1).toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }
}
