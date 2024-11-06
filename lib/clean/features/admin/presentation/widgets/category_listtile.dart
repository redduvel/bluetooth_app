import 'package:auto_route/auto_route.dart';
import 'package:bluetooth_app/clean/config/theme/colors.dart';
import 'package:bluetooth_app/clean/core/Domain/bloc/db.bloc.dart';
import 'package:bluetooth_app/clean/core/Domain/entities/marking/category.dart';
import 'package:bluetooth_app/clean/core/Domain/entities/marking/product.dart';
import 'package:bluetooth_app/clean/core/Presentation/widgets/primary_button.dart';
import 'package:bluetooth_app/clean/core/Presentation/widgets/primary_textfield.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class CategoryListTile extends StatefulWidget {
  final Category category;
  final DBBloc<Category> bloc;
  const CategoryListTile(
      {super.key, required this.category, required this.bloc});

  @override
  State<CategoryListTile> createState() => _CategoryListTileState();
}

class _CategoryListTileState extends State<CategoryListTile> {
  TextEditingController editController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      key: ValueKey(widget.category),
      leading: widget.category.isHide
          ? const Icon(Icons.visibility_off, size: 24)
          : const Icon(Icons.category),
      title: Text(widget.category.name),
      trailing: PopupMenuButton(
        color: AppColors.white,
        onSelected: (value) {
          switch (value) {
            case 'edit':
              _showEditCategoryDialog(widget.category);
              break;
            case 'hide':
              widget.bloc.add(UpdateItem<Category>(
                widget.category.copyWith(isHide: !widget.category.isHide),
              ));
              break;
            case 'delete':
              _showDeleteConfirmationDialog(widget.category);
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
            child:
                Text(widget.category.isHide ? 'Убрать из скрытых' : 'Скрыть'),
          ),
          const PopupMenuItem(
            value: 'delete',
            child: Text('Удалить'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(Category category) {
    var productsBox = Hive.box<Product>('products');

    var relatedProducts = productsBox.values
        .where((product) => product.category.id == category.id)
        .toList();

    String product = relatedProducts.length == 1 ? 'продуктом' : 'продуктами';
    String zeroProduct =
        'Эта категория не связана ни с одним продуктом. Что Вы хотите сделать?';
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          title: const Text('Удаление категории'),
          content: Text(
            relatedProducts.isNotEmpty
                ? 'Эта категория связана с ${relatedProducts.length} $product. Что вы хотите сделать?'
                : zeroProduct,
          ),
          actions: [
            PrimaryButtonIcon(
              text: 'Отмена',
              icon: Icons.close,
              type: ButtonType.normal,
              onPressed: () {
                context.router.popForced();
              },
            ),
            if (relatedProducts.isNotEmpty) ...[
              PrimaryButtonIcon(
                text: 'Удалить вместе с категорией',
                icon: Icons.delete,
                type: ButtonType.delete,
                onPressed: () {
                  for (var product in relatedProducts) {
                    productsBox.delete(product.id);
                  }
                  widget.bloc.add(DeleteItem<Category>(category.id));
                  context.router.popForced();
                },
              ),
              PrimaryButtonIcon(
                text: 'Архивировать продукты и удалить категорию',
                icon: Icons.delete,
                type: ButtonType.delete,
                onPressed: () async {
                  var archiveCategory =
                      Hive.box<Category>('categories').get('archive');
                  for (var product in relatedProducts) {
                    var updatedProduct =
                        product.copyWith(category: archiveCategory);
                    await productsBox.put(product.id, updatedProduct);
                  }

                  widget.bloc.add(DeleteItem<Category>(category.id));

                  if (context.mounted) {
                    context.router.popForced();
                  }
                },
              ),
            ] else
              PrimaryButtonIcon(
                onPressed: () {
                  for (var product in relatedProducts) {
                    productsBox.delete(product.id);
                  }
                  widget.bloc.add(DeleteItem<Category>(category.id));
                  context.router.popForced();
                },
                text: 'Удалить',
                type: ButtonType.delete,
                icon: Icons.delete,
              ),
          ],
        );
      },
    );
  }

  void _showEditCategoryDialog(Category category) {
    editController.text = category.name;
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                PrimaryTextField(
                  controller: editController,
                  hintText: category.name,
                  width: 500,
                ),
                const SizedBox(height: 20),
                PrimaryButtonIcon(
                  text: 'Сохранить изменения',
                  icon: Icons.save,
                  selected: true,
                  width: 500,
                  onPressed: () {
                    widget.bloc.add(UpdateItem<Category>(
                      category.copyWith(
                          id: category.id, name: editController.text),
                    ));
                    editController.clear();
                    context.router.popForced();
                  },
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
