import 'package:bluetooth_app/clean/core/Data/datasource/local/local_db.dart';
import 'package:bluetooth_app/clean/core/Data/datasource/remote/remote_db.dart';
import 'package:bluetooth_app/clean/core/Data/repositories/category_repository.dart';
import 'package:bluetooth_app/clean/core/Data/repositories/marking_repositore.dart';
import 'package:bluetooth_app/clean/core/Data/repositories/product_repository.dart';
import 'package:bluetooth_app/clean/core/Data/repositories/user_repository.dart';
import 'package:bluetooth_app/clean/core/Domain/bloc/db.bloc.dart';
import 'package:bluetooth_app/clean/core/Domain/entities/marking/category.dart';
import 'package:bluetooth_app/clean/core/Domain/entities/marking/product.dart';
import 'package:bluetooth_app/clean/core/Domain/entities/marking/user.dart';
import 'package:bluetooth_app/clean/core/Domain/entities/marking_db/marking.dart';
import 'package:bluetooth_app/clean/core/Presentation/bloc/navigation_bloc/navigation.bloc.dart';
import 'package:bluetooth_app/clean/core/Presentation/bloc/navigation_bloc/navigation.state.dart';
import 'package:bluetooth_app/clean/features/printing/Presentation/pages/dashboard_page.dart';
import 'package:bluetooth_app/clean/features/admin/presentation/cubit/dropdown_controller.dart';
import 'package:bluetooth_app/clean/features/home/Presentation/home_screen.dart';
import 'package:bluetooth_app/clean/features/printing/Presentation/bloc/printer.bloc.dart';
import 'package:bluetooth_app/clean/features/printing/Presentation/bloc/printer.event.dart';
//import 'package:bluetooth_app/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  LocalDB.createDB();

  await RemoteDB.createDB();
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

  // bool productSearchCondition(Product product, String query) {
  //   return product.title.toLowerCase().contains(query) ||
  //       product.subtitle.toLowerCase().contains(query);
  // }

  // bool nomenclatureSearchCondition(Nomenclature nomenclature, String query) {
  //   return nomenclature.name.toLowerCase().contains(query);
  // }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // NEW BLOCS
        BlocProvider(create: (_) => DropdownCubit<Category>()),
        BlocProvider(
          create: (context) {
            return DBBloc(UserRepository(repositoryName: 'users'))
              ..add(Sync<User>());
          },
        ),
        BlocProvider(
          create: (context) {
            return DBBloc(ProductRepository(repositoryName: 'products'))
              ..add(Sync<Product>());
          },
        ),
        BlocProvider(
          create: (context) {
            return DBBloc(CategoryRepository(repositoryName: 'categories'))
              ..add(Sync<Category>());
          },
        ),
        BlocProvider(
          create: (context) {
            return DBBloc(MarkingRepositore(repositoryName: 'markings'));
          },
        ),
        BlocProvider(create: (context) {
          return NavigationBloc(InitialState(const DashboardPage()));
        }),
        BlocProvider(create: (context) {
          return PrinterBloc()..add(CheckConnection());
        }),
      ],
      child: const MaterialApp(
          showSemanticsDebugger: false,
          debugShowCheckedModeBanner: false,
          home: HomeScreen()),
    );
  }
}
