import 'dart:io';

import 'package:bluetooth_app/bloc/bloc.bloc.dart';
import 'package:bluetooth_app/bloc/printer/printer.bloc.dart';
import 'package:bluetooth_app/bloc/printer/printer.event.dart';
import 'package:bluetooth_app/bloc/repositories/employee.repository.dart';
import 'package:bluetooth_app/bloc/repositories/nomenclature.repository.dart';
import 'package:bluetooth_app/bloc/repositories/product.repository.dart';
import 'package:bluetooth_app/bloc/search_engine/search.bloc.dart';
import 'package:bluetooth_app/clean/features/admin/presentation/admin_screen.dart';
import 'package:bluetooth_app/clean/core/Presentation/bloc/navigation_bloc/navigation.bloc.dart';
import 'package:bluetooth_app/clean/core/Presentation/bloc/navigation_bloc/navigation.state.dart';
import 'package:bluetooth_app/clean/features/admin/presentation/pages/main_screens/dashboard_screen.dart';
import 'package:bluetooth_app/clean/features/home/Presentation/home_screen.dart';
import 'package:bluetooth_app/models/characteristic.dart';
import 'package:bluetooth_app/models/employee.dart';
import 'package:bluetooth_app/models/nomenclature.dart';
import 'package:bluetooth_app/models/product.dart';
//import 'package:bluetooth_app/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // INITIALIZE HIVE
  await Hive.initFlutter('db2');

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
    var archive = Nomenclature(
        order: 100000, id: 'archive', name: 'Архив', isHide: false);
    Hive.box<Nomenclature>('nomenclature_box').put(archive.id, archive);
  }

  if (Hive.box<Nomenclature>('nomenclature_box').get('tag') == null) {
    var tag =
        Nomenclature(order: 100001, id: 'tag', name: 'TAG', isHide: false);
    Hive.box<Nomenclature>('nomenclature_box').put(tag.id, tag);
  }

  // Инициализация менеджера окна
  // if (Platform.isWindows || Platform.isMacOS) {
  // await windowManager.ensureInitialized();

  //   // Настройки окна
  //   WindowOptions windowOptions = const WindowOptions(
  //     size: Size(800, 600),
  //     center: true,
  //     backgroundColor: Colors.transparent,
  //     titleBarStyle: TitleBarStyle.hidden,
  //   );
  //   windowManager.waitUntilReadyToShow(windowOptions, () async {
  //     await windowManager.setFullScreen(true);
  //     windowManager.show();
  //   });
  // }

  // RUN APP
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  bool productSearchCondition(Product product, String query) {
    return product.title.toLowerCase().contains(query) ||
        product.subtitle.toLowerCase().contains(query);
  }

  bool nomenclatureSearchCondition(Nomenclature nomenclature, String query) {
    return nomenclature.name.toLowerCase().contains(query);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) {
          return GenericBloc<Employee>(EmployeeRepository());
        }),
        BlocProvider(create: (context) {
          return GenericBloc<Nomenclature>(NomenclatureRepository())
            ..add(LoadItems<Nomenclature>());
        }),
        BlocProvider(create: (context) {
          return GenericBloc<Product>(ProductRepository());
        }),
        BlocProvider(create: (context) {
          return PrinterBloc()..add(CheckConnection());
        }),
        BlocProvider(create: (context) {
          return GenericSearchBloc<Product>(
              Hive.box<Product>('products_box'), productSearchCondition);
        }),
        BlocProvider(create: (context) {
          return GenericSearchBloc<Nomenclature>(
              Hive.box('nomenclature_box'), nomenclatureSearchCondition);
        }),

        // NEW BLOCS

        BlocProvider(create: (context) {
          return NavigationBloc(InitialState(const DashboardScreen()));
        })
      ],
      child: const MaterialApp(
          showSemanticsDebugger: false,
          debugShowCheckedModeBanner: false,
          home: HomeScreen()),
    );
  }
}
