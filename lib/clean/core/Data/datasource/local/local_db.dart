import 'package:bluetooth_app/clean/core/Domain/entities/category.dart';
import 'package:bluetooth_app/clean/core/Domain/entities/product.dart';
import 'package:bluetooth_app/clean/core/Domain/entities/user.dart';
import 'package:bluetooth_app/clean/core/Domain/entities/characteristic.dart';
import 'package:hive_flutter/hive_flutter.dart';

class LocalDB {
  static LocalDB? _instance;
  // Avoid self instance
  LocalDB._();
  static LocalDB get instance => _instance ??= LocalDB._();

  static void createDB() async {
    await Hive.initFlutter('db2');

    Hive.registerAdapter(UserAdapter());
    Hive.registerAdapter(ProductAdapter());
    Hive.registerAdapter(CategoryAdapter());
    Hive.registerAdapter(CharacteristicAdapter());
    Hive.registerAdapter(MeasurementUnitAdapter());

    await Hive.openBox<User>('employee_box');
    await Hive.openBox<Category>('nomenclature_box');
    await Hive.openBox<Product>('products_box');
    await Hive.openBox('settings');

    if (Hive.box<Category>('nomenclature_box').get('archive') == null) {
      var archive = Category(
          order: 100000, id: 'archive', name: 'Архив', isHide: false);
      Hive.box<Category>('nomenclature_box').put(archive.id, archive);
    }

    if (Hive.box<Category>('nomenclature_box').get('tag') == null) {
      var tag =
          Category(order: 100001, id: 'tag', name: 'TAG', isHide: false);
      Hive.box<Category>('nomenclature_box').put(tag.id, tag);
    }
  }
}
