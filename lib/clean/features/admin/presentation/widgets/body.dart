import 'package:bluetooth_app/clean/core/Presentation/bloc/navigation_bloc/navigation.bloc.dart';
import 'package:bluetooth_app/clean/core/Presentation/widgets/primary_button.dart';
import 'package:bluetooth_app/clean/features/admin/presentation/pages/main_screens/dashboard_screen.dart';
import 'package:bluetooth_app/clean/features/admin/presentation/pages/main_screens/product_screen.dart';
import 'package:bluetooth_app/clean/features/admin/presentation/pages/main_screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/Presentation/pages/container_page.dart';
import '../../../../core/Presentation/pages/navigation_page.dart';

class AdminBody extends StatefulWidget {
  const AdminBody({super.key});

  @override
  State<AdminBody> createState() => _AdminBodyState();
}

class _AdminBodyState extends State<AdminBody> {
  late NavigationBloc bloc;
  @override
  void initState() {
    bloc = context.read<NavigationBloc>();

    super.initState();
  }

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
                    toPage: const DashboardScreen(),
                    text: 'Доска',
                    icon: Icons.dashboard,
                  ),
                  PrimaryButtonIcon(
                    toPage: const SettingsScreen(),
                    text: 'Категории',
                    icon: Icons.category,
                  ),
                  PrimaryButtonIcon(
                    toPage: const ProductScreen(),
                    text: 'Продукты',
                    icon: Icons.egg,
                  )
                ],
                [
                  PrimaryButtonIcon(
                      toPage: const SettingsScreen(),
                      text: 'Настройки',
                      icon: Icons.settings),
                  PrimaryButtonIcon(
                      toPage: const SettingsScreen(),
                      text: 'Выйти',
                      icon: Icons.logout)
                ]
              ],
            )),
        const Flexible(flex: 532 + 310, fit: FlexFit.tight, child: ContainerPage()),
        // Flexible(
        //     flex: 310,
        //     fit: FlexFit.tight,
        //     child: Column(
        //       children: [
        //         Expanded(
        //             child: Container(
        //           color: Colors.white,
        //         ))
        //       ],
        //     )),
      ],
    );
  }
}
