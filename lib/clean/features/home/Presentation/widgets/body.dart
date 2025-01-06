import 'package:bluetooth_app/clean/core/Presentation/pages/container_page.dart';
import 'package:bluetooth_app/clean/core/Presentation/pages/navigation_page.dart';
import 'package:bluetooth_app/clean/core/Presentation/widgets/primary_button.dart';
import 'package:bluetooth_app/clean/features/home/Presentation/pages/employee_page.dart';
import 'package:bluetooth_app/clean/features/home/Presentation/pages/login_page.dart';
import 'package:bluetooth_app/clean/features/home/Presentation/pages/start_page.dart';
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
                        width: double.infinity,
                        icon: Icons.admin_panel_settings),
                    PrimaryButtonIcon(
                        toPage: const EmployeeScreen(),
                        text: 'Сотрудники',
                        width: double.infinity,
                        icon: Icons.person_2)
                  ],
                  [
                    PrimaryButtonIcon(
                    toPage: const StartPage(),
                    text: 'Стартовая страница',
                    width: double.infinity,
                    icon: Icons.start),
                    PrimaryButtonIcon(
                        onPressed: () {
                          exit(0);
                        },
                        text: 'Закрыть приложение',
                        width: double.infinity,
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
