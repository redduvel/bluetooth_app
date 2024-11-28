import 'package:auto_route/auto_route.dart';
import 'package:bluetooth_app/clean/config/theme/colors.dart';
import 'package:bluetooth_app/clean/core/Presentation/pages/navigation_page.dart';
import 'package:bluetooth_app/clean/core/Presentation/widgets/primary_button.dart';
import 'package:bluetooth_app/clean/features/home/Presentation/bloc/home/home.bloc.dart';
import 'package:bluetooth_app/clean/features/home/Presentation/pages/employee_page.dart';
import 'package:bluetooth_app/clean/features/home/Presentation/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
      body: BlocListener<HomeBloc, HomeState>(
        listener: (context, state) => (Platform.isAndroid || Platform.isIOS)
            ? {
                print("open"),
                Scaffold.of(context).openDrawer(),
              }
            : null,
        child: const HomeBody(),
      ),
      drawer: (Platform.isAndroid || Platform.isIOS)
          ? Drawer(
              width: double.infinity,
              child: NavigationPage(controls: [
                [
                  PrimaryButtonIcon(
                      toPage: const LoginScreen(),
                      onPressed: Navigator.of(context).pop,
                      text: 'Администратор',
                      width: double.infinity,
                      icon: Icons.admin_panel_settings),
                  PrimaryButtonIcon(
                      toPage: const EmployeeScreen(),
                      onPressed: Navigator.of(context).pop,
                      text: 'Сотрудники',
                      width: double.infinity,
                      icon: Icons.person_2)
                ],
                [
                  // PrimaryButtonIcon(
                  //     toPage: const ApplicationSettingsScreen(),
                  //     text: 'Настройки',
                  //     icon: Icons.settings),
                  PrimaryButtonIcon(
                      type: ButtonType.delete,
                      width: double.infinity,
                      onPressed: () => exit(0),
                      text: 'Закрыть',
                      icon: Icons.close)
                ]
              ]))
          : null,
    );
  }
}
