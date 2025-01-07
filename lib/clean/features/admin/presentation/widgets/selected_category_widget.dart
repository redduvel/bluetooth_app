import 'package:bluetooth_app/clean/config/theme/colors.dart';
import 'package:bluetooth_app/clean/core/Domain/bloc/db.bloc.dart';
import 'package:bluetooth_app/clean/core/Domain/entities/marking/category.dart';
import 'package:bluetooth_app/clean/features/admin/presentation/cubit/dropdown_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SelectedCategoryWidget extends StatefulWidget {
  final DropdownCubit<Category> controller;

  const SelectedCategoryWidget({super.key, required this.controller});

  @override
  State<SelectedCategoryWidget> createState() => _SelectedCategoryWidgetState();
}

class _SelectedCategoryWidgetState extends State<SelectedCategoryWidget> {

  @override
  Widget build(BuildContext context) {

    return BlocProvider<DropdownCubit<Category>>(
      create: (context) => widget.controller,
      child: BlocBuilder<DBBloc<Category>, DBState<Category>>(
        builder: (context, state) {
          if (state is ItemsLoaded<Category>) {
            var nomenclatures = state.items;
      
            return DropdownMenu<Category>(
              onSelected: (value) => setState(() {
                widget.controller.selectOption(value!);
              }),
              hintText: 'Выберите категорию',
              width: double.infinity,
              menuStyle: const MenuStyle(
                backgroundColor: WidgetStatePropertyAll(AppColors.surface)
              ),
              leadingIcon: const Icon(Icons.category),
              dropdownMenuEntries: nomenclatures.map((nomenclature) {
                return DropdownMenuEntry(
                  style: const ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(AppColors.surface),
                  ),
                  value: nomenclature,
                  label: nomenclature.name,
                );
              }).toList(),
            );
          }
          if (state is ItemOperationFailed<Category>) {
            return Text(state.error);
          }
          return const Text('Нет категорий');
        },
      ),
    );
  }
}
