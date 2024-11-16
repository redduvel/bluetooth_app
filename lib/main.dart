import 'package:bluetooth_app/clean/core/Data/datasource/local/local_db.dart';
import 'package:bluetooth_app/clean/core/Data/datasource/remote/remote_db.dart';
import 'package:bluetooth_app/clean/core/Data/repositories/category_repository.dart';
import 'package:bluetooth_app/clean/core/Data/repositories/marking_repositore.dart';
import 'package:bluetooth_app/clean/core/Data/repositories/product_repository.dart';
import 'package:bluetooth_app/clean/core/Data/repositories/template_repository.dart';
import 'package:bluetooth_app/clean/core/Data/repositories/user_repository.dart';
import 'package:bluetooth_app/clean/core/Domain/bloc/db.bloc.dart';
import 'package:bluetooth_app/clean/core/Domain/bloc/user.cubit.dart';
import 'package:bluetooth_app/clean/core/Domain/entities/marking/category.dart';
import 'package:bluetooth_app/clean/core/Domain/entities/marking/product.dart';
import 'package:bluetooth_app/clean/core/Domain/entities/marking/user.dart';
import 'package:bluetooth_app/clean/core/Presentation/bloc/navigation_bloc/navigation.bloc.dart';
import 'package:bluetooth_app/clean/core/Presentation/bloc/navigation_bloc/navigation.state.dart';
import 'package:bluetooth_app/clean/features/printing/Presentation/pages/dashboard_page.dart';
import 'package:bluetooth_app/clean/features/admin/presentation/cubit/dropdown_controller.dart';
import 'package:bluetooth_app/clean/features/printing/Presentation/bloc/printer.bloc.dart';
import 'package:bluetooth_app/clean/features/printing/Presentation/bloc/printer.event.dart';
//import 'package:bluetooth_app/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'clean/config/routes/app_router.dart';

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
        BlocProvider(create: (_) => UserCubit()),
        BlocProvider(create: (_) => DropdownCubit<Category>()),
        BlocProvider(create: (_) => DBBloc(UserRepository(repositoryName: 'users'))
              ..add(Sync<User>()),
        ),
        BlocProvider(create: (_) => DBBloc(ProductRepository(repositoryName: 'products'))
              ..add(Sync<Product>()),
        ),
        BlocProvider(create: (_) => DBBloc(CategoryRepository(repositoryName: 'categories'))
              ..add(Sync<Category>()),
        ),
        BlocProvider(create: (_) => DBBloc(MarkingRepositore(repositoryName: 'markings'))),
        BlocProvider(create: (_) => DBBloc(TemplateRepository(repositoryName: 'templates'))),
        BlocProvider(create: (_) => NavigationBloc(InitialState(const DashboardPage()))),
        BlocProvider(create: (_) => PrinterBloc()..add(CheckConnection())),
      ],
      child: MaterialApp.router(
        showSemanticsDebugger: false,
        debugShowCheckedModeBanner: false,
        routerConfig: AppRouter().config(),
      ),
    );
  }
}
