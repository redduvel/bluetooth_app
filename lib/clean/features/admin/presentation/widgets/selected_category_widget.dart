import 'package:bluetooth_app/clean/config/theme/colors.dart';
import 'package:bluetooth_app/clean/core/Domain/bloc/db.bloc.dart';
import 'package:bluetooth_app/clean/core/Domain/entities/category.dart';
import 'package:bluetooth_app/clean/features/admin/presentation/cubit/dropdown_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SelectedCategoryWidget extends StatefulWidget {
  final DropdownCubit<Category> controller;

   SelectedCategoryWidget({super.key, required this.controller});

  @override
  State<SelectedCategoryWidget> createState() => _SelectedCategoryWidgetState();
}

class _SelectedCategoryWidgetState extends State<SelectedCategoryWidget> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DBBloc<Category>, DBState<Category>>(
      builder: (context, state) {
        if (state is ItemsLoaded<Category>) {
          var nomenclatures = state.items;
          // if (!widget.showHideEnemies) {
          //   nomenclatures =
          //       nomenclatures.where((n) => n.name != 'Архив').toList();
          // }

          return DropdownMenu<Category>(
            
            onSelected: (value) => setState(() {
              widget.controller.selectOption(value!);
            }),
            hintText: 'Выберите категорию',
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
    );
  }
}
