import 'package:auto_route/auto_route.dart';
import 'package:bluetooth_app/clean/core/Presentation/bloc/navigation_bloc/navigation.bloc.dart';
import 'package:bluetooth_app/clean/core/Presentation/bloc/navigation_bloc/navigation.event.dart';
import 'package:bluetooth_app/clean/core/Presentation/pages/container_page.dart';
import 'package:bluetooth_app/clean/core/Presentation/pages/navigation_page.dart';
import 'package:bluetooth_app/clean/core/Presentation/widgets/primary_button.dart';
import 'package:bluetooth_app/clean/features/home/Presentation/pages/employee_page.dart';
import 'package:bluetooth_app/clean/features/printing/Presentation/pages/dashboard_page.dart';
import 'package:bluetooth_app/clean/features/printing/Presentation/pages/product_page.dart';
import 'package:bluetooth_app/clean/features/printing/Presentation/pages/setting_page.dart';
import 'package:bluetooth_app/clean/features/printing/Presentation/pages/template_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:universal_io/io.dart';

class PrintingBody extends StatefulWidget {
  const PrintingBody({super.key});

  @override
  State<PrintingBody> createState() => _PrintingBodyState();
}

class _PrintingBodyState extends State<PrintingBody> {
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
                    ),
                    PrimaryButtonIcon(
                      toPage: const TemplatePage(),
                      text: 'Шаблоны',
                      icon: Icons.edit_document,
                    ),
                  ],
                  [
                    PrimaryButtonIcon(
                      toPage: const PrintingPage(),
                      text: 'Продукты',
                      icon: Icons.egg_alt,
                    ),
                    PrimaryButtonIcon(
                      toPage: const PrintingSettingPage(),
                      text: 'Настройка принтера',
                      icon: Icons.print,
                    )
                  ],
                  [
                    PrimaryButtonIcon(
                      text: 'Настройки',
                      icon: Icons.settings,
                      width: double.infinity,
                    ),
                    PrimaryButtonIcon(
                        text: 'Выйти',
                        width: double.infinity,
                        onPressed: () {
                          context.router.popForced();
                          context
                              .read<NavigationBloc>()
                              .add(NavigateTo(const EmployeeScreen()));
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
