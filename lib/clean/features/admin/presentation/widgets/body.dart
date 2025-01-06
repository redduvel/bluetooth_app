import 'package:auto_route/auto_route.dart';
import 'package:bluetooth_app/clean/core/Presentation/bloc/navigation_bloc/navigation.bloc.dart';
import 'package:bluetooth_app/clean/core/Presentation/bloc/navigation_bloc/navigation.event.dart';
import 'package:bluetooth_app/clean/core/Presentation/pages/container_page.dart';
import 'package:bluetooth_app/clean/core/Presentation/pages/navigation_page.dart';
import 'package:bluetooth_app/clean/core/Presentation/widgets/primary_button.dart';
import 'package:bluetooth_app/clean/features/admin/presentation/pages/main_screens/category_screen.dart';
import 'package:bluetooth_app/clean/features/printing/Presentation/pages/dashboard_page.dart';
import 'package:bluetooth_app/clean/features/admin/presentation/pages/main_screens/employee_screen.dart';
import 'package:bluetooth_app/clean/features/admin/presentation/pages/main_screens/product_screen.dart';
import 'package:bluetooth_app/clean/features/home/Presentation/pages/login_page.dart';
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
                      text: 'Журнал',
                      icon: Icons.dashboard,
                      width: double.infinity,
                    ),
                    PrimaryButtonIcon(
                      toPage: const EmployeeScreen(),
                      text: 'Сотрудники',
                      icon: Icons.person,
                      width: double.infinity,
                    ),
                    PrimaryButtonIcon(
                      toPage: const CategoryScreen(),
                      text: 'Категории',
                      icon: Icons.category,
                      width: double.infinity,
                    ),
                    PrimaryButtonIcon(
                      toPage: const ProductScreen(),
                      text: 'Продукты',
                      icon: Icons.egg,
                      width: double.infinity,
                    )
                  ],
                  [
                    PrimaryButtonIcon(
                        text: 'Выйти',
                        type: ButtonType.delete,
                        width: double.infinity,
                        onPressed: () {
                          context.router.popForced();
                          context
                              .read<NavigationBloc>()
                              .add(NavigateTo(const LoginScreen()));
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
