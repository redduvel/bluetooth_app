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
import 'package:bluetooth_app/clean/core/Domain/entities/marking/template.dart';
import 'package:bluetooth_app/clean/core/Domain/entities/marking/user.dart';
import 'package:bluetooth_app/clean/core/Domain/entities/marking_db/marking.dart';
import 'package:bluetooth_app/clean/core/Domain/usecases/sync_service.dart';
import 'package:bluetooth_app/clean/core/Presentation/bloc/navigation_bloc/navigation.bloc.dart';
import 'package:bluetooth_app/clean/core/Presentation/bloc/navigation_bloc/navigation.state.dart';
import 'package:bluetooth_app/clean/features/home/Presentation/pages/start_page.dart';
import 'package:bluetooth_app/clean/features/printing/Presentation/bloc/printer.bloc.dart';
import 'package:bluetooth_app/clean/features/printing/Presentation/bloc/printer.event.dart';
//import 'package:bluetooth_app/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'clean/config/routes/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  LocalDB.createDB();

  final blocs = await initializeBlocs();

  await SyncService.initialize(
          categoryBloc: blocs.categoryBloc,
          productBloc: blocs.productBloc,
          userBloc: blocs.userBloc)
      .then((value) {
    value.sync();
  });

  await RemoteDB.createDB();
  await RemoteDB.sync();
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

  runApp(MyApp(blocs: blocs));
}

class MyApp extends StatelessWidget {
  final Blocs blocs;

  const MyApp({super.key, required this.blocs});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: blocs.userBloc),
        RepositoryProvider.value(value: blocs.productBloc),
        RepositoryProvider.value(value: blocs.categoryBloc),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<UserCubit>(create: (_) => UserCubit()),
          BlocProvider(
              create: (_) => DBBloc<Template>(
                  TemplateRepository(repositoryName: 'templates'))
                ..add(LoadItems<Template>())),
          BlocProvider(
              create: (_) =>
                  DBBloc(MarkingRepositore(repositoryName: 'markings'))
                    ..add(LoadItems<Marking>())),
          BlocProvider(
              create: (_) => NavigationBloc(InitialState(const StartPage()))),
          BlocProvider(create: (_) => PrinterBloc()..add(CheckConnection())),
        ],
        child: MaterialApp.router(
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate
          ],
          supportedLocales: const [Locale('ru', 'RU')],
          locale: const Locale('ru', ''),
          routerConfig: AppRouter().config(),
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}

// filepath: /lib/core/init/blocs.dart
class Blocs {
  final DBBloc<User> userBloc;
  final DBBloc<Product> productBloc;
  final DBBloc<Category> categoryBloc;

  Blocs({
    required this.userBloc,
    required this.productBloc,
    required this.categoryBloc,
  });
}

Future<Blocs> initializeBlocs() async {
  final userBloc = DBBloc<User>(UserRepository(repositoryName: 'users'));

  final productBloc =
      DBBloc<Product>(ProductRepository(repositoryName: 'products'));

  final categoryBloc =
      DBBloc<Category>(CategoryRepository(repositoryName: 'categories'));

  return Blocs(
    userBloc: userBloc,
    productBloc: productBloc,
    categoryBloc: categoryBloc,
  );
}
