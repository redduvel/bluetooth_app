import 'package:auto_route/auto_route.dart';
import 'package:bluetooth_app/clean/config/routes/app_router.dart';
import 'package:bluetooth_app/clean/config/theme/colors.dart';
import 'package:bluetooth_app/clean/core/Presentation/bloc/navigation_bloc/navigation.bloc.dart';
import 'package:bluetooth_app/clean/core/Presentation/bloc/navigation_bloc/navigation.event.dart';
import 'package:bluetooth_app/clean/core/Presentation/pages/navigation_page.dart';
import 'package:bluetooth_app/clean/core/Presentation/widgets/primary_button.dart';
import 'package:bluetooth_app/clean/features/admin/presentation/pages/main_screens/category_screen.dart';
import 'package:bluetooth_app/clean/features/printing/Presentation/bloc/printer.bloc.dart';
import 'package:bluetooth_app/clean/features/printing/Presentation/bloc/printer.state.dart';
import 'package:bluetooth_app/clean/features/printing/Presentation/pages/dashboard_page.dart';
import 'package:bluetooth_app/clean/features/admin/presentation/pages/main_screens/employee_screen.dart';
import 'package:bluetooth_app/clean/features/admin/presentation/pages/main_screens/product_screen.dart';
import 'package:bluetooth_app/clean/features/admin/presentation/widgets/body.dart';
import 'package:bluetooth_app/clean/features/printing/Presentation/pages/setting_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:universal_io/io.dart';

@RoutePage()
class AdminScreen extends StatelessWidget {
  static const String path = '/admin';
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        actions: [
          if (Platform.isAndroid || Platform.isIOS)
            BlocBuilder<PrinterBloc, PrinterState>(
              builder: (context, state) {
                if (state is PrinterLoading) {
                  return const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: SpinKitFadingCircle(
                      color: Colors.orange,
                      size: 25.0,
                    ),
                  );
                }

                return IconButton(
                  onPressed: () => context
                      .read<NavigationBloc>()
                      .add(NavigateTo(const PrintingSettingPage())),
                  icon: Icon(
                    context.read<PrinterBloc>().connectedDevice != null
                        ? Icons.print
                        : Icons.print_disabled,
                    color: context.read<PrinterBloc>().connectedDevice != null
                        ? Colors.green
                        : Colors.red,
                  ),
                );
              },
            ),
        ],
      ),
      body: const AdminBody(),
      drawer: (Platform.isAndroid || Platform.isIOS)
          ? Drawer(
              child: NavigationPage(
              controls: [
                [
                  PrimaryButtonIcon(
                    toPage: const DashboardPage(),
                    text: 'Доска (демо версия журнала)',
                    width: double.infinity,
                    icon: Icons.dashboard,
                  ),
                  PrimaryButtonIcon(
                    text: 'Сотрудники',
                    icon: Icons.person,
                    width: double.infinity,
                    toPage: const EmployeeScreen(),
                  ),
                  PrimaryButtonIcon(
                    toPage: const CategoryScreen(),
                    text: 'Категории',
                    width: double.infinity,
                    icon: Icons.category,
                  ),
                  PrimaryButtonIcon(
                    toPage: const ProductScreen(),
                    text: 'Продукты',
                    width: double.infinity,
                    icon: Icons.egg,
                  )
                ],
                [
                  // PrimaryButtonIcon(
                  //     toPage: const SettingsScreen(),
                  //     text: 'Настройки',
                  //     width: double.infinity,
                  //     icon: Icons.settings),
                  PrimaryButtonIcon(
                      text: 'Выйти',
                      width: double.infinity,
                      onPressed: () {
                        context.router.replace(const HomeRoute());
                        context
                            .read<NavigationBloc>()
                            .add(Started(const DashboardPage()));
                      },
                      icon: Icons.logout)
                ]
              ],
            ))
          : null,
    );
  }
}
