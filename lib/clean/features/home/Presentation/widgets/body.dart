import 'package:bluetooth_app/clean/core/Presentation/pages/container_page.dart';
import 'package:bluetooth_app/clean/core/Presentation/pages/navigation_page.dart';
import 'package:bluetooth_app/clean/core/Presentation/widgets/primary_button.dart';
import 'package:bluetooth_app/clean/features/home/Presentation/pages/tabs/LoginScreen.dart';
import 'package:flutter/material.dart';

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
        Flexible(
            flex: 159,
            fit: FlexFit.tight,
            child: NavigationPage(
              controls: [
                [
                  PrimaryButtonIcon(
                      toPage: const LoginScreen(),
                      text: 'Войти',
                      icon: Icons.login)
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
