import 'package:bluetooth_app/clean/config/theme/colors.dart';
import 'package:bluetooth_app/clean/core/Presentation/bloc/navigation_bloc/navigation.bloc.dart';
import 'package:bluetooth_app/clean/core/Presentation/bloc/navigation_bloc/navigation.event.dart';
import 'package:bluetooth_app/clean/features/printing/Presentation/pages/product_page.dart';
import 'package:bluetooth_app/clean/features/printing/Presentation/printing_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EmployeeScreen extends StatefulWidget {
  const EmployeeScreen({super.key});

  @override
  State<EmployeeScreen> createState() => _EmployeeScreenState();
}

class _EmployeeScreenState extends State<EmployeeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: CustomScrollView(
        slivers: [

          SliverList.separated(itemBuilder: (context, index) {
            return ListTile(
              title: Text('Employee $index'),
              onTap: () {
                context.read<NavigationBloc>().add(NavigateTo(PrintingPage()));
                Navigator.push(context, MaterialPageRoute(builder: (context) => PrintingScreen()));
              },
              trailing: Icon(Icons.arrow_forward_ios),
            );
          }, separatorBuilder: (context, index) {
            return Divider();
          }, itemCount: 200,)
        ],
      )
    );
  }
}