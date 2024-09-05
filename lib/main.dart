import 'package:bluetooth_app/aaa/tsplprinter.dart';
import 'package:bluetooth_app/bloc/bloc.bloc.dart';
import 'package:bluetooth_app/bloc/printer/printer.bloc.dart';
import 'package:bluetooth_app/bloc/printer/printer.event.dart';
import 'package:bluetooth_app/bloc/repositories/employee.repository.dart';
import 'package:bluetooth_app/bloc/repositories/nomenclature.repository.dart';
import 'package:bluetooth_app/bloc/repositories/product.repository.dart';
import 'package:bluetooth_app/models/characteristic.dart';
import 'package:bluetooth_app/models/employee.dart';
import 'package:bluetooth_app/models/nomenclature.dart';
import 'package:bluetooth_app/models/product.dart';
import 'package:bluetooth_app/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // INITIALIZE HIVE  
  await Hive.initFlutter();

  Hive.registerAdapter(EmployeeAdapter());
  Hive.registerAdapter(ProductAdapter());
  Hive.registerAdapter(NomenclatureAdapter());
  Hive.registerAdapter(CharacteristicAdapter());
  Hive.registerAdapter(MeasurementUnitAdapter());

  await Hive.openBox<Employee>('employee_box');
  await Hive.openBox<Nomenclature>('nomenclature_box');
  await Hive.openBox<Product>('products_box');
  await Hive.openBox('settings');

  if (Hive.box<Nomenclature>('nomenclature_box').get('archive') == null) {
    var archive = Nomenclature(id: 'archive', name: 'Архив', isHide: false);
    Hive.box<Nomenclature>('nomenclature_box').put(archive.id, archive);
  }

  if (Hive.box<Nomenclature>('nomenclature_box').get('tag') == null) {
    var tag = Nomenclature(id: 'tag', name: 'TAG', isHide: false);
    Hive.box<Nomenclature>('nomenclature_box').put(tag.id, tag);
  }


final printer = TSPLPrinter();

  // Подключение к принтеру через USB
  int handle = printer.connect("USB001");
  if (handle != -1) {
    print("Принтер подключен");

    // Отправка команды TSPL
    bool success = printer.sendCommand(handle, "SIZE 30 mm, 20 mm\r\nGAP 3 mm, 0 mm\r\nTEXT 10,10,\"3\",0,1,1,\"Test Label\"\r\nPRINT\r\n");
    if (success) {
      print("Команда отправлена успешно");
    } else {
      print("Ошибка отправки команды");
    }

    // Отключение принтера
    printer.disconnect(handle);
  } else {
    print("Ошибка подключения к принтеру");
  }

  // RUN APP
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) {
          return GenericBloc<Employee>(EmployeeRepository());
        }),
        BlocProvider(create: (context) {
          return GenericBloc<Nomenclature>(NomenclatureRepository())..add(LoadItems<Nomenclature>());
        }),
        BlocProvider(create: (context) {
          return GenericBloc<Product>(ProductRepository());
        }),
        BlocProvider(create: (context) {
          return PrinterBloc()..add(CheckConnection());
        }),
      ],
      child: MaterialApp(
          showSemanticsDebugger: false,
          debugShowCheckedModeBanner: false,
          theme: ThemeData.from(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange)),
          home: const HomePage()),
    );
  }
}
