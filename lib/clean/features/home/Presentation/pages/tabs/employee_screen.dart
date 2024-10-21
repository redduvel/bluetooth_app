import 'package:bluetooth_app/clean/config/theme/colors.dart';
import 'package:bluetooth_app/clean/config/theme/text_styles.dart';
import 'package:bluetooth_app/clean/core/Domain/bloc/db.bloc.dart';
import 'package:bluetooth_app/clean/core/Domain/entities/user.dart';
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
  late DBBloc<User> bloc;

  @override
  void initState() {
    bloc = context.read<DBBloc<User>>()..add(LoadItems<User>());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.white,
        body: BlocBuilder<DBBloc<User>, DBState<User>>(
          bloc: bloc,
          builder: (context, state) {
            if (state is ItemsLoaded<User>) {
              return CustomScrollView(
                slivers: [
                  SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                    return ListTile(
                      title: Text(
                        state.items[index].fullName,
                        style: AppTextStyles.bodyMedium16,
                      ),
                      leading: const Icon(Icons.person),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        context.read<DBBloc<User>>().repository.currentItem = state.items[index];
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const PrintingScreen()));
                        context.read<NavigationBloc>().add(NavigateTo(const PrintingPage()));
                      },
                    );
                  }, childCount: state.items.length))
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ));
  }
}
