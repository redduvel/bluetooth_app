import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:bluetooth_app/bloc/bloc.bloc.dart';
import 'package:bluetooth_app/models/nomenclature.dart';
import 'package:bluetooth_app/models/product.dart';
import 'package:bluetooth_app/widgets/text_feild.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class DocumentsTab extends StatefulWidget {
  const DocumentsTab({super.key});

  @override
  State<DocumentsTab> createState() => _DocumentsTabState();
}

class _DocumentsTabState extends State<DocumentsTab> {
  late GenericBloc<Nomenclature> bloc;
  TextEditingController nameController = TextEditingController();
  TextEditingController editController = TextEditingController();
  List<Nomenclature> otherNomenclatures = [];
  bool valid = false;

  @override
  void initState() {
    bloc = context.read<GenericBloc<Nomenclature>>()
      ..add(LoadItems<Nomenclature>());
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
      body: BlocBuilder<GenericBloc<Nomenclature>, GenericState<Nomenclature>>(
        builder: (context, state) {
          if (state is ItemsLoaded<Nomenclature>) {
            return _buildNomenclatureList(state.items);
          }

          if (state is ItemOperationFailed<Nomenclature>) {
            return _buildError(state.error);
          }

          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCategoryModal(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildNomenclatureList(List<Nomenclature> nomenclatures) {
    if (nomenclatures.isEmpty) {
      return const Center(
        child: Text('Нет категорий'),
      );
    } else {
      // Отделение категории "Архив" и "TAG" от остальных
      final archiveCategory = nomenclatures.firstWhere(
        (nomenclature) => nomenclature.name == 'Архив',
        orElse: () => Nomenclature(id: '', name: '', isHide: false),
      );

      final tagCategory = nomenclatures.firstWhere(
        (nomenclature) => nomenclature.name == 'TAG',
        orElse: () => Nomenclature(id: '', name: '', isHide: false),
      );

      otherNomenclatures = nomenclatures
          .where((nomenclature) =>
              nomenclature.name != 'Архив' && nomenclature.name != 'TAG')
          .toList();

      return CustomScrollView(
        slivers: [
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
              child:
                  _buildNomenclatureTile(tagCategory, false, icon: Icons.tag),
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
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
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
                        _showEditCategoryDialog(nomenclature);
                        break;
                      case 'hide':
                        bloc.add(UpdateItem<Nomenclature>(
                          nomenclature.copyWith(isHide: !nomenclature.isHide),
                        ));
                        break;
                      case 'delete':
                        _showDeleteConfirmationDialog(nomenclature);
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
            }, childCount: otherNomenclatures.length),
          ),
        ],
      );
    }
  }

  void _showDeleteConfirmationDialog(Nomenclature nomenclature) {
    var productsBox = Hive.box<Product>('products_box');

    var relatedProducts = productsBox.values
        .where((product) => product.category.id == nomenclature.id)
        .toList();

    String product = relatedProducts.length == 1 ? 'продуктом' : 'продуктами';
    String zeroProduct =
        'Эта категория не связана ни с одним продуктом. Что Вы хотите сделать?';
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Удаление категории'),
          content: Text(
            relatedProducts.isNotEmpty
                ? 'Эта категория связана с ${relatedProducts.length} $product. Что вы хотите сделать?'
                : zeroProduct,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Отмена'),
            ),
            if (relatedProducts.isNotEmpty) ...[
              TextButton(
                onPressed: () {
                  for (var product in relatedProducts) {
                    productsBox.delete(product.id);
                  }
                  bloc.add(DeleteItem<Nomenclature>(nomenclature.id));
                  Navigator.pop(context);
                },
                child: const Text('Удалить вместе с категорией'),
              ),
              TextButton(
                onPressed: () async {
                  var archiveCategory =
                      Hive.box<Nomenclature>('nomenclature_box').get('archive');
                  for (var product in relatedProducts) {
                    var updatedProduct =
                        product.copyWith(category: archiveCategory);
                    await productsBox.put(product.id, updatedProduct);
                  }

                  bloc.add(DeleteItem<Nomenclature>(nomenclature.id));

                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
                child: const Text('Архивировать продукты и удалить категорию'),
              ),
            ] else
              TextButton(
                onPressed: () {
                  for (var product in relatedProducts) {
                    productsBox.delete(product.id);
                  }
                  bloc.add(DeleteItem<Nomenclature>(nomenclature.id));
                  Navigator.pop(context);
                },
                child: const Text('Удалить'),
              ),
          ],
        );
      },
    );
  }

  ListTile _buildNomenclatureTile(Nomenclature nomenclature, bool showTools,
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
                switch (value) {
                  case 'edit':
                    _showEditCategoryDialog(nomenclature);
                    break;
                  case 'hide':
                    bloc.add(UpdateItem<Nomenclature>(
                      nomenclature.copyWith(isHide: !nomenclature.isHide),
                    ));
                    break;
                  case 'delete':
                    _showDeleteConfirmationDialog(nomenclature);
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
            )
          : null,
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Text('Ошибка загрузки данных: $error'),
    );
  }

  void _showAddCategoryModal(BuildContext context) {
    showBarModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      builder: (context) {
        return SizedBox(
          height: 500,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: CustomScrollView(
              slivers: [
                const SliverAppBar(
                  title: Text('Добавление категории'),
                  centerTitle: true,
                  backgroundColor: Colors.transparent,
                  automaticallyImplyLeading: false,
                ),
                SliverToBoxAdapter(
                  child: TextInput(
                    controller: nameController,
                    hintText: 'Специи',
                    labelText: 'Название',
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(
                    height: 30,
                  ),
                ),
                SliverToBoxAdapter(
                  child: ElevatedButton(
                    onPressed: () {
                      if (nameController.text.isEmpty) {
                        setState(() {
                          valid = true;
                        });
                        return;
                      }
                      bloc.add(AddItem<Nomenclature>(
                        Nomenclature(name: nameController.text, isHide: false),
                      ));
                      nameController.clear();
                      Navigator.pop(context);
                    },
                    child: const Text('Добавить'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEditCategoryDialog(Nomenclature nomenclature) {
    editController.text = nomenclature.name;
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextInput(
                  controller: editController,
                  hintText: nomenclature.name,
                  labelText: "Название",
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    bloc.add(UpdateItem<Nomenclature>(
                      nomenclature.copyWith(
                          id: nomenclature.id, name: editController.text),
                    ));
                    editController.clear();
                    Navigator.pop(context);
                  },
                  child: const Text('Сохранить изменения'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
