import 'package:bluetooth_app/clean/core/Presentation/pages/container_page.dart';
import 'package:bluetooth_app/clean/core/Presentation/pages/navigation_page.dart';
import 'package:bluetooth_app/clean/core/Presentation/widgets/primary_button.dart';
import 'package:bluetooth_app/clean/features/home/Presentation/pages/tabs/employee_screen.dart';
import 'package:bluetooth_app/clean/features/home/Presentation/pages/tabs/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:universal_io/io.dart';

class HomeBody extends StatefulWidget {
  const HomeBody({super.key});

  @override
  State<HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<HomeBody> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (Platform.isMacOS || Platform.isWindows)
          Flexible(
              flex: 159,
              fit: FlexFit.tight,
              child: NavigationPage(
                controls: [
                  [
                    PrimaryButtonIcon(
                        toPage: const LoginScreen(),
                        text: 'Администратор',
                        icon: Icons.admin_panel_settings),
                    PrimaryButtonIcon(
                        toPage: const EmployeeScreen(),
                        text: 'Сотрудник',
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
                ],
              )),
        const Flexible(
            flex: 532 + 310, fit: FlexFit.tight, child: ContainerPage()),
      ],
    );
  }
}
