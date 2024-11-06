import 'package:bluetooth_app/clean/config/theme/colors.dart';
import 'package:bluetooth_app/clean/core/Presentation/bloc/navigation_bloc/navigation.bloc.dart';
import 'package:bluetooth_app/clean/core/Presentation/bloc/navigation_bloc/navigation.event.dart';
import 'package:bluetooth_app/clean/core/Presentation/pages/navigation_page.dart';
import 'package:bluetooth_app/clean/core/Presentation/widgets/primary_button.dart';
import 'package:bluetooth_app/clean/features/admin/presentation/pages/main_screens/category_screen.dart';
import 'package:bluetooth_app/clean/features/printing/Presentation/pages/dashboard_page.dart';
import 'package:bluetooth_app/clean/features/admin/presentation/pages/main_screens/employee_screen.dart';
import 'package:bluetooth_app/clean/features/admin/presentation/pages/main_screens/product_screen.dart';
import 'package:bluetooth_app/clean/features/admin/presentation/pages/main_screens/settings_screen.dart';
import 'package:bluetooth_app/clean/features/admin/presentation/widgets/body.dart';
import 'package:bluetooth_app/clean/features/home/Presentation/home_screen.dart';
import 'package:bluetooth_app/clean/features/home/Presentation/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:universal_io/io.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.surface,
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
                  PrimaryButtonIcon(
                      toPage: const SettingsScreen(),
                      text: 'Настройки',
                      width: double.infinity,
                      icon: Icons.settings),
                  PrimaryButtonIcon(
                        text: 'Выйти',
                        width: double.infinity,
                        onPressed: () {
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
                          context.read<NavigationBloc>().add(NavigateTo(const LoginScreen()));
                        },
                        icon: Icons.logout)
                ]
              ],
            ))
          : null,
    );
  }
}
