import 'package:bluetooth_app/bloc/bloc.bloc.dart';
import 'package:bluetooth_app/models/nomenclature.dart';
import 'package:bluetooth_app/models/product.dart';
import 'package:bluetooth_app/widgets/text_feild.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProductCard extends StatefulWidget {
  final Product product;
  final GenericBloc<Product> bloc;
  final bool showTools;

  const ProductCard({
    super.key,
    required this.product,
    required this.bloc,
    this.showTools = false,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool validCategory = true;
  Nomenclature? selectedCategory; // Добавляем переменную для хранения выбранной категории

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildProductInfoTile(),
          _buildProductDetailsTile(),
        ],
      ),
    );
  }

  Widget _buildProductInfoTile() {
    return ListTile(
      leading: widget.product.isHide
          ? const Icon(Icons.visibility_off, size: 24)
          : null,
      title: Text(widget.product.title),
      subtitle: Text(widget.product.subtitle),
      trailing: widget.showTools ? _buildPopupMenu() : null,
    );
  }

  Widget _buildProductDetailsTile() {
    return ListTile(
      title: Text(widget.product.category.name),
      trailing: IconButton(onPressed: () {}, icon: const Icon(Icons.print)),
      subtitle: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Разморозка: ${widget.product.defrosting}ч."),
          Text('Хранение (о): ${widget.product.openedTime}ч.'),
          Text('Хранение (з): ${widget.product.closedTime}ч.'),
        ],
      ),
    );
  }

  Widget _buildPopupMenu() {
    return PopupMenuButton(
      itemBuilder: (context) => [
        PopupMenuItem(
          child: const Text('Изменить'),
          onTap: () => _showEditDialog(context),
        ),
        PopupMenuItem(
          child: Text(widget.product.isHide ? 'Убрать из скрытых' : 'Скрыть'),
          onTap: () {
            widget.bloc.add(UpdateItem<Product>(
              widget.product.copyWith(isHide: !widget.product.isHide),
            ));
          },
        ),
        PopupMenuItem(
          child: const Text('Удалить'),
          onTap: () => widget.bloc.add(DeleteItem<Product>(widget.product.id)),
        ),
      ],
    );
  }

  void _showEditDialog(BuildContext context) {
    TextEditingController nameController =
        TextEditingController(text: widget.product.title);
    TextEditingController subnameController =
        TextEditingController(text: widget.product.subtitle);
    TextEditingController defrostingController =
        TextEditingController(text: widget.product.defrosting.toString());
    TextEditingController closedTimeController =
        TextEditingController(text: widget.product.closedTime.toString());
    TextEditingController openedTimeController =
        TextEditingController(text: widget.product.openedTime.toString());

    // Инициализируем выбранную категорию текущей категорией продукта
    selectedCategory = widget.product.category;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (context) {
          return _buildEditDialog(
            context,
            nameController,
            subnameController,
            defrostingController,
            closedTimeController,
            openedTimeController,
          );
        },
      );
    });
  }

  Widget _buildEditDialog(
    BuildContext context,
    TextEditingController nameController,
    TextEditingController subnameController,
    TextEditingController defrostingController,
    TextEditingController closedTimeController,
    TextEditingController openedTimeController,
  ) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(8.0),
        margin: const EdgeInsets.all(15),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTextInputCard(nameController, subnameController),
            const SizedBox(height: 10),
            _buildCategoryDropdown(context),
            const SizedBox(height: 10),
            _buildStorageInputCard(defrostingController, closedTimeController,
                openedTimeController),
            const SizedBox(height: 10),
            _buildSaveButton(
              context,
              nameController,
              subnameController,
              defrostingController,
              closedTimeController,
              openedTimeController,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextInputCard(TextEditingController nameController,
      TextEditingController subnameController) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextInput(
              controller: nameController,
              hintText: 'Морковь',
              labelText: 'Название',
            ),
            TextInput(
              controller: subnameController,
              hintText: 'Морковь очищенная',
              labelText: 'Короткое название',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child:
            BlocBuilder<GenericBloc<Nomenclature>, GenericState<Nomenclature>>(
          builder: (context, state) {
            if (state is ItemsLoaded<Nomenclature>) {
              return DropdownMenu<Nomenclature>(
                hintText: selectedCategory?.name ?? 'Выберите категорию',
                width: MediaQuery.of(context).size.width - 70,
                leadingIcon: const Icon(Icons.category),
                onSelected: (value) => setState(() {
                  selectedCategory = value; // Сохраняем выбранную категорию
                  validCategory = true;
                }),
                dropdownMenuEntries: state.items.map((nomenclature) {
                  return DropdownMenuEntry(
                    value: nomenclature,
                    label: nomenclature.name,
                  );
                }).toList(),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildStorageInputCard(
      TextEditingController defrostingController,
      TextEditingController closedTimeController,
      TextEditingController openedTimeController) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const Text('Сроки указываются в часах'),
            TextInput(
              controller: defrostingController,
              hintText: '100',
              labelText: 'Разморозка',
              type: TextInputType.number,
              icon: Icons.ac_unit,
            ),
            TextInput(
              controller: closedTimeController,
              hintText: '100',
              labelText: 'Срок закрытого хранения',
              type: TextInputType.number,
              icon: Icons.close_fullscreen,
            ),
            TextInput(
              controller: openedTimeController,
              hintText: '100',
              labelText: 'Срок открытого хранения',
              type: TextInputType.number,
              icon: Icons.open_with,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton(
    BuildContext context,
    TextEditingController nameController,
    TextEditingController subnameController,
    TextEditingController defrostingController,
    TextEditingController closedTimeController,
    TextEditingController openedTimeController,
  ) {
    return ElevatedButton(
      onPressed: () {
        if (selectedCategory == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Выберите категорию')),
          );
          return;
        }

        Product updatedProduct = Product(
          id: widget.product.id,
          title: nameController.text,
          subtitle: subnameController.text,
          defrosting: int.parse(defrostingController.text),
          closedTime: int.parse(closedTimeController.text),
          openedTime: int.parse(openedTimeController.text),
          category: selectedCategory!, // Используем выбранную категорию
          isHide: widget.product.isHide,
        );

        widget.bloc.add(UpdateItem<Product>(updatedProduct));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Данные обновлены.')),
        );

        Navigator.pop(context);
      },
      child: const Text('Сохранить изменения'),
    );
  }
}
