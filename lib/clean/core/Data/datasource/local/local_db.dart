import 'package:bluetooth_app/clean/core/Domain/entities/marking/category.dart';
import 'package:bluetooth_app/clean/core/Domain/entities/marking/product.dart';
import 'package:bluetooth_app/clean/core/Domain/entities/marking/template.dart';
import 'package:bluetooth_app/clean/core/Domain/entities/marking/template_entry.dart';
import 'package:bluetooth_app/clean/core/Domain/entities/marking/user.dart';
import 'package:bluetooth_app/clean/core/Domain/entities/marking/characteristic.dart';
import 'package:bluetooth_app/clean/core/Domain/entities/marking_db/marking.dart';
import 'package:hive_flutter/hive_flutter.dart';

class LocalDB {
  static LocalDB? _instance;
  LocalDB._();
  static LocalDB get instance => _instance ??= LocalDB._();

  static void createDB() async {
    await Hive.initFlutter('db10');

    Hive.registerAdapter(UserAdapter());
    Hive.registerAdapter(ProductAdapter());
    Hive.registerAdapter(CategoryAdapter());
    Hive.registerAdapter(CharacteristicAdapter());
    Hive.registerAdapter(MeasurementUnitAdapter());
    Hive.registerAdapter(MarkingStatusAdapter());
    Hive.registerAdapter(MarkingAdapter());
    Hive.registerAdapter(TemplateEntryAdapter());
    Hive.registerAdapter(TemplateAdapter());

    await Hive.openBox<Marking>('markings');
    await Hive.openBox<User>('users');
    await Hive.openBox<Category>('categories');
    await Hive.openBox<Product>('products');
    await Hive.openBox<Template>('templates');
    await Hive.openBox('settings');
  }
}
