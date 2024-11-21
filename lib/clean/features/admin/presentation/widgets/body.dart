import 'package:auto_route/auto_route.dart';
import 'package:bluetooth_app/clean/config/routes/app_router.dart';
import 'package:bluetooth_app/clean/core/Presentation/bloc/navigation_bloc/navigation.bloc.dart';
import 'package:bluetooth_app/clean/core/Presentation/bloc/navigation_bloc/navigation.event.dart';
import 'package:bluetooth_app/clean/core/Presentation/pages/container_page.dart';
import 'package:bluetooth_app/clean/core/Presentation/pages/navigation_page.dart';
import 'package:bluetooth_app/clean/core/Presentation/widgets/primary_button.dart';
import 'package:bluetooth_app/clean/features/admin/presentation/pages/main_screens/category_screen.dart';
import 'package:bluetooth_app/clean/features/printing/Presentation/pages/dashboard_page.dart';
import 'package:bluetooth_app/clean/features/admin/presentation/pages/main_screens/employee_screen.dart';
import 'package:bluetooth_app/clean/features/admin/presentation/pages/main_screens/product_screen.dart';
import 'package:bluetooth_app/clean/features/admin/presentation/pages/main_screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:universal_io/io.dart';

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
        if (Platform.isMacOS || Platform.isWindows)
          Flexible(
              flex: 159,
              fit: FlexFit.tight,
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
                          context.router.replace(const HomeRoute());
                          context
                              .read<NavigationBloc>()
                              .add(Started(const DashboardPage()));
                        },
                        icon: Icons.logout)
                  ]
                ],
              )),
        const Flexible(
            flex: 532 + 310, fit: FlexFit.tight, child: ContainerPage()),
      ],
    );
  }
}
