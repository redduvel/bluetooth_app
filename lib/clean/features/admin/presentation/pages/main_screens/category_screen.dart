import 'package:bluetooth_app/clean/config/theme/colors.dart';
import 'package:bluetooth_app/clean/config/theme/text_styles.dart';
import 'package:bluetooth_app/clean/core/Domain/bloc/db.bloc.dart';
import 'package:bluetooth_app/clean/core/Domain/entities/marking/category.dart';
import 'package:bluetooth_app/clean/core/Presentation/widgets/primary_button.dart';
import 'package:bluetooth_app/clean/core/Presentation/widgets/primary_textfield.dart';
import 'package:bluetooth_app/clean/features/admin/presentation/widgets/category_listtile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reorderables/reorderables.dart';
import 'package:universal_io/io.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  late DBBloc<Category> bloc;
  TextEditingController nameController = TextEditingController();
  List<Category> otherCategories = [];

  @override
  void initState() {
    bloc = context.read<DBBloc<Category>>()..add(LoadItems<Category>());
    super.initState();
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: BlocBuilder<DBBloc<Category>, DBState<Category>>(
        builder: (context, state) {
          if (state is ItemsLoaded<Category>) {
            return _buildCategories(state.items);
          }

          if (state is ItemsLoading<Category>) {
            return _buildCategories([]);
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

  Widget _buildCategories(List<Category> categories) {
    final archiveCategory = categories.firstWhere(
      (c) => c.name == 'Архив',
      orElse: () => Category(order: -1, id: '', name: '', isHide: false),
    );

    final tagCategory = categories.firstWhere(
      (c) => c.name == 'TAG',
      orElse: () => Category(order: -1, id: '', name: '', isHide: false),
    );

    otherCategories =
        categories.where((c) => c.name != 'Архив' && c.name != 'TAG').toList();

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
          actions: [
            if (Platform.isMacOS || Platform.isWindows)
              PrimaryButtonIcon(
                text: 'Синхронизировать',
                icon: Icons.sync,
                padding: const EdgeInsets.symmetric(horizontal: 15),
                selected: true,
                onPressed: () => bloc.add(Sync<Category>()),
              ),
            if (Platform.isAndroid || Platform.isIOS)
              IconButton(
                  onPressed: () => bloc.add(Sync<Category>()),
                  icon: const Icon(Icons.sync))
          ],
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
              selected: true,
              text: 'Добавить',
              icon: Icons.add,
              onPressed: () => (nameController.text.isEmpty)
                  ? null
                  : bloc.add(AddItem(Category(
                      order: 1, name: nameController.text, isHide: false))),
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
            child: _buildCategoryTile(archiveCategory, Icons.archive),
          ),
          SliverToBoxAdapter(
            child: _buildCategoryTile(tagCategory, Icons.tag),
          ),
          const SliverToBoxAdapter(
            child: Divider(),
          ),
        ],
        if (otherCategories.isNotEmpty) ...[
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
                childCount: otherCategories.length, (context, index) {
              final category = otherCategories[index];

              return CategoryListTile(category: category, bloc: bloc);
            }),
            onReorder: (oldIndex, newIndex) {
              setState(() {
                final oldItem = otherCategories[oldIndex];
                final newItem = otherCategories[newIndex];

                bloc.add(
                    ReorderList<Category>(oldItem.order, newItem.order, true));

                var row = otherCategories.removeAt(oldIndex);
                otherCategories.insert(newIndex, row);
              });
            },
          ),
        ],
        if (categories.isEmpty)
          const SliverPadding(
            padding: EdgeInsets.symmetric(vertical: 15),
            sliver: SliverToBoxAdapter(
              child: Center(
                child: CircularProgressIndicator(
                  color: AppColors.greenOnSurface,
                ),
              ),
            ),
          )
      ],
    );
  }

  ListTile _buildCategoryTile(Category nomenclature, IconData? icon) {
    return ListTile(
      key: ValueKey(nomenclature.id),
      leading: nomenclature.isHide
          ? const Icon(Icons.visibility_off, size: 24)
          : Icon(icon ?? Icons.category),
      title: Text(nomenclature.name),
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Text('Ошибка загрузки данных: $error'),
    );
  }
}
