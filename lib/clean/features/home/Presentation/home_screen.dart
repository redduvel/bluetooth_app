import 'package:auto_route/auto_route.dart';
import 'package:bluetooth_app/clean/config/theme/colors.dart';
import 'package:bluetooth_app/clean/core/Presentation/pages/navigation_page.dart';
import 'package:bluetooth_app/clean/core/Presentation/widgets/primary_button.dart';
import 'package:bluetooth_app/clean/features/home/Presentation/pages/employee_page.dart';
import 'package:bluetooth_app/clean/features/home/Presentation/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:universal_io/io.dart';

import 'widgets/body.dart';

@RoutePage()
class HomeScreen extends StatefulWidget {
  static const String path = '/';
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
      ),
      body: const HomeBody(),
      drawer: (Platform.isAndroid || Platform.isIOS)
          ? Drawer(
              child: NavigationPage(controls: [
              [
                PrimaryButtonIcon(
                    toPage: const LoginScreen(),
                    text: 'Администратор',
                    width: double.infinity,
                    icon: Icons.admin_panel_settings),
                PrimaryButtonIcon(
                    toPage: const EmployeeScreen(),
                    text: 'Сотрудники',
                    icon: Icons.person_2)
              ],
              [
                PrimaryButtonIcon(
                    toPage: const LoginScreen(),
                    text: 'Настройки',
                    icon: Icons.settings),
                PrimaryButtonIcon(
                    toPage: const LoginScreen(),
                    text: 'Закрыть',
                    icon: Icons.close)
              ]
            ]))
          : null,
    );
  }
}
