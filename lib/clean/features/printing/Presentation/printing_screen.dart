
import 'package:bluetooth_app/clean/config/theme/colors.dart';
import 'package:bluetooth_app/clean/core/Presentation/bloc/navigation_bloc/navigation.bloc.dart';
import 'package:bluetooth_app/clean/core/Presentation/bloc/navigation_bloc/navigation.event.dart';
import 'package:bluetooth_app/clean/core/Presentation/pages/navigation_page.dart';
import 'package:bluetooth_app/clean/core/Presentation/widgets/primary_button.dart';
import 'package:bluetooth_app/clean/features/home/Presentation/home_screen.dart';
import 'package:bluetooth_app/clean/features/home/Presentation/pages/tabs/employee_screen.dart';
import 'package:bluetooth_app/clean/features/printing/Presentation/bloc/printer.bloc.dart';
import 'package:bluetooth_app/clean/features/printing/Presentation/bloc/printer.state.dart';
import 'package:bluetooth_app/clean/features/printing/Presentation/pages/category_page.dart';
import 'package:bluetooth_app/clean/features/printing/Presentation/pages/product_page.dart';
import 'package:bluetooth_app/clean/features/printing/Presentation/pages/setting_page.dart';
import 'package:bluetooth_app/clean/features/printing/Presentation/widgets/body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:universal_io/io.dart';

class PrintingScreen extends StatefulWidget {
  const PrintingScreen({super.key});

  @override
  State<PrintingScreen> createState() => _PrintingScreenState();
}

class _PrintingScreenState extends State<PrintingScreen> {



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        actions: [
          if (Platform.isAndroid || Platform.isIOS)
            BlocBuilder<PrinterBloc, PrinterState>(
              builder: (context, state) {
                if (state is PrinterLoading) {
                  return const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: SpinKitFadingCircle(
                      color: Colors.orange,
                      size: 25.0,
                    ),
                  );
                }

                return IconButton(
                  onPressed: () => context.read<NavigationBloc>().add(NavigateTo(const PrintingSettingPage())),
                  icon: Icon(
                    context.read<PrinterBloc>().connectedDevice != null
                        ? Icons.print
                        : Icons.print_disabled,
                    color: context.read<PrinterBloc>().connectedDevice != null
                        ? Colors.green
                        : Colors.red,
                  ),
                );
              },
            ),
        ],
      ),
      body: const PrintingBody(),
      drawer: (Platform.isAndroid || Platform.isIOS)
          ? Drawer(
              child: NavigationPage(controls: [[
                PrimaryButtonIcon(
                  toPage: const PrintingPage(),
                  text: 'Продукты',
                  icon: Icons.egg_alt,
                ),
                PrimaryButtonIcon(
                  toPage: const CategoryPage(),
                  text: 'Категории',
                  icon: Icons.category,
                ),
                PrimaryButtonIcon(
                  toPage: const PrintingSettingPage(),
                  text: 'Настройка принтера',
                  icon: Icons.print,
                )
              ], [
                PrimaryButtonIcon(
                  text: 'Настройки',
                  icon: Icons.settings,
                  width: double.infinity,
                ),
                PrimaryButtonIcon(
                    text: 'Выйти',
                    width: double.infinity,
                    onPressed: () {
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
                      context
                          .read<NavigationBloc>()
                          .add(NavigateTo(const EmployeeScreen()));
                    },
                    icon: Icons.logout)
              ]]),
            )
          : null,
    );
  }

  
}
