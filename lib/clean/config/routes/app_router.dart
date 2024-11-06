import 'package:bluetooth_app/clean/features/admin/presentation/admin_screen.dart';
import 'package:bluetooth_app/clean/features/home/Presentation/home_screen.dart';
import 'package:bluetooth_app/clean/features/printing/Presentation/printing_screen.dart';
import 'package:auto_route/auto_route.dart';

part 'app_router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Screen,Route')
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
        AutoRoute(path: HomeScreen.path, page: HomeRoute.page),
        AutoRoute(path: AdminScreen.path, page: AdminRoute.page),
        AutoRoute(path: PrintingScreen.path, page: PrintingRoute.page),
      ];
}
