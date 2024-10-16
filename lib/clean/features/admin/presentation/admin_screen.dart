import 'package:bluetooth_app/clean/features/admin/presentation/widgets/body.dart';
import 'package:flutter/material.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: AdminBody(),
    );
  }
}
