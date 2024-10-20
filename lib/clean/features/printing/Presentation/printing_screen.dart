import 'package:bluetooth_app/clean/config/theme/colors.dart';
import 'package:bluetooth_app/clean/core/Presentation/pages/navigation_page.dart';
import 'package:bluetooth_app/clean/features/printing/Presentation/widgets/body.dart';
import 'package:flutter/material.dart';
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
      body: const PrintingBody(),
      drawer: (Platform.isAndroid || Platform.isIOS) ? const Drawer(
        child: NavigationPage(controls: []),
      ) : null,
    );
  }
}