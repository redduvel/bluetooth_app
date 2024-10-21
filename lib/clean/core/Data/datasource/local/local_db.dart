import 'package:bluetooth_app/clean/core/Domain/entities/category.dart';
import 'package:bluetooth_app/clean/core/Domain/entities/product.dart';
import 'package:bluetooth_app/clean/core/Domain/entities/user.dart';
import 'package:bluetooth_app/clean/core/Domain/entities/characteristic.dart';
import 'package:hive_flutter/hive_flutter.dart';

class LocalDB {
  static LocalDB? _instance;
  LocalDB._();
  static LocalDB get instance => _instance ??= LocalDB._();

  static void createDB() async {
    await Hive.initFlutter('db3');

    Hive.registerAdapter(UserAdapter());
    Hive.registerAdapter(ProductAdapter());
    Hive.registerAdapter(CategoryAdapter());
    Hive.registerAdapter(CharacteristicAdapter());
    Hive.registerAdapter(MeasurementUnitAdapter());

    await Hive.openBox<User>('users');
    await Hive.openBox<Category>('categories');
    await Hive.openBox<Product>('products');
    await Hive.openBox('settings');
  }
}
