import 'package:bluetooth_app/clean/config/theme/colors.dart';
import 'package:bluetooth_app/clean/config/theme/text_styles.dart';
import 'package:bluetooth_app/clean/core/Domain/bloc/db.bloc.dart';
import 'package:bluetooth_app/clean/core/Domain/entities/category.dart';
import 'package:bluetooth_app/clean/core/Presentation/widgets/primary_button.dart';
import 'package:bluetooth_app/clean/core/Presentation/widgets/primary_textfield.dart';
import 'package:bluetooth_app/clean/features/admin/presentation/pages/main_screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reorderables/reorderables.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  late DBBloc<Category> bloc;
  TextEditingController nameController = TextEditingController();
  TextEditingController editController = TextEditingController();
  List<Category> otherNomenclatures = [];
  bool valid = false;

  @override
  void initState() {
    bloc = context.read<DBBloc<Category>>()..add(LoadItems<Category>());
    bloc = context.read<DBBloc<Category>>()..add(Sync<Category>());
    super.initState();
  }

  @override
  void dispose() {
    nameController.dispose();
    editController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: BlocBuilder<DBBloc<Category>, DBState<Category>>(
        builder: (context, state) {
          if (state is ItemsLoaded<Category>) {
            return _buildNomenclatureList(state.items);
          }

          if (state is ItemOperationFailed<Category>) {
            return _buildError(state.error);
          }

          return const Center(
            child: SizedBox.shrink(),
          );
        },
      ),
    );
  }

  Widget _buildNomenclatureList(List<Category> nomenclatures) {
    // Отделение категории "Архив" и "TAG" от остальных
    final archiveCategory = nomenclatures.firstWhere(
      (nomenclature) => nomenclature.name == 'Архив',
      orElse: () => Category(order: -1, id: '', name: '', isHide: false),
    );

    final tagCategory = nomenclatures.firstWhere(
      (nomenclature) => nomenclature.name == 'TAG',
      orElse: () => Category(order: -1, id: '', name: '', isHide: false),
    );

    otherNomenclatures = nomenclatures
        .where((nomenclature) =>
            nomenclature.name != 'Архив' && nomenclature.name != 'TAG')
        .toList();

    return CustomScrollView(
      slivers: [
        SliverAppBar(
                backgroundColor: AppColors.white,

          title: Text(
            'Управление категориями',
            style: AppTextStyles.labelMedium18.copyWith(fontSize: 24),
          ),
          centerTitle: false,
          automaticallyImplyLeading: false,
        ),
        SliverToBoxAdapter(
          child: PrimaryTextField(
              controller: nameController,
              width: double.infinity,
              hintText: 'Название'),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          sliver: SliverToBoxAdapter(
            child: PrimaryButtonIcon(
              toPage: const SettingsScreen(),
              selected: true,
              text: 'Добавить',
              icon: Icons.add,
              onPressed: () {
                bloc.add(AddItem(Category(
                  order: 1,
                    name: nameController.text, isHide: false)));
              },
            ),
          ),
        ),
        if (archiveCategory.id.isNotEmpty) ...[
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Системные:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: _buildNomenclatureTile(archiveCategory, false,
                icon: Icons.archive),
          ),
          SliverToBoxAdapter(
            child: _buildNomenclatureTile(tagCategory, false, icon: Icons.tag),
          ),
          const SliverToBoxAdapter(
            child: Divider(),
          ),
        ],
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Пользовательские:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        ReorderableSliverList(
          delegate: ReorderableSliverChildBuilderDelegate(
              childCount: otherNomenclatures.length, (context, index) {
            final nomenclature = otherNomenclatures[index];

            return ListTile(
              key: ValueKey(nomenclature),
              leading: nomenclature.isHide
                  ? const Icon(Icons.visibility_off, size: 24)
                  : const Icon(Icons.category),
              title: Text(nomenclature.name),
              trailing: PopupMenuButton(
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      //_showEditCategoryDialog(nomenclature);
                      break;
                    case 'hide':
                      bloc.add(UpdateItem<Category>(
                        nomenclature.copyWith(isHide: !nomenclature.isHide),
                      ));
                      break;
                    case 'delete':
                      bloc.add(DeleteItem<Category>(nomenclature.id));
                      //_showDeleteConfirmationDialog(nomenclature);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Text('Изменить'),
                  ),
                  PopupMenuItem(
                    value: 'hide',
                    child: Text(
                        nomenclature.isHide ? 'Убрать из скрытых' : 'Скрыть'),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Удалить'),
                  ),
                ],
              ),
            );
          }),
          onReorder: (oldIndex, newIndex) {
            setState(() {
              final oldItem = otherNomenclatures[oldIndex];
              final newItem = otherNomenclatures[newIndex];

              bloc.add(ReorderList<Category>(oldItem.order!, newItem.order!));

              var row = otherNomenclatures.removeAt(oldIndex);
              otherNomenclatures.insert(newIndex, row);
            });
          },
        ),
      ],
    );
  }

  ListTile _buildNomenclatureTile(Category nomenclature, bool showTools,
      {IconData? icon}) {
    return ListTile(
      key: ValueKey(nomenclature.id),
      leading: nomenclature.isHide
          ? const Icon(Icons.visibility_off, size: 24)
          : Icon(icon ?? Icons.category),
      title: Text(nomenclature.name),
      trailing: showTools
          ? PopupMenuButton(
              onSelected: (value) {
                // switch (value) {
                //   case 'edit':
                //     _showEditCategoryDialog(nomenclature);
                //     break;
                //   case 'hide':
                //     bloc.add(UpdateItem<Nomenclature>(
                //       nomenclature.copyWith(isHide: !nomenclature.isHide),
                //     ));
                //     break;
                //   case 'delete':
                //     _showDeleteConfirmationDialog(nomenclature);
                //     break;
                // }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Text('Изменить'),
                ),
                PopupMenuItem(
                  value: 'hide',
                  child: Text(
                      nomenclature.isHide ? 'Убрать из скрытых' : 'Скрыть'),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('Удалить'),
                ),
              ],
            )
          : null,
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Text('Ошибка загрузки данных: $error'),
    );
  }
}
