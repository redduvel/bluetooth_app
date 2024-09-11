import 'package:bluetooth_app/bloc/bloc.bloc.dart';
import 'package:bluetooth_app/models/characteristic.dart';
import 'package:bluetooth_app/models/nomenclature.dart';
import 'package:bluetooth_app/models/product.dart';
import 'package:bluetooth_app/widgets/text_feild.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

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
  Nomenclature? selectedCategory;

  @override
  Widget build(BuildContext context) {
    return Card(
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
      title: RichText(
          textScaler: const TextScaler.linear(1),
          text: TextSpan(
              text: widget.product.title,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black),
              children: [
                TextSpan(
                  text: "  ${widget.product.subtitle}",
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                      color: Colors.black),
                )
              ])),
      subtitle: Text(
        widget.product.category.name,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      trailing: widget.showTools ? _buildPopupMenu() : null,
    );
  }

  Widget _buildProductDetailsTile() {
    return ListTile(
      title: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widget.product.characteristics
            .map((c) => _buildProductInfo(c))
            .toList(),
      ),
    );
  }

  Widget _buildProductInfo(Characteristic characteristic) {
    return Text(
      "${characteristic.shortName}: ${characteristic.value} ${getLocalizedMeasurementUnit(characteristic.unit)}",
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(fontSize: 14),
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

    List<Characteristic> characteristics =
        List.from(widget.product.characteristics);
    List<TextEditingController> nameControllers = characteristics
        .map((c) => TextEditingController(text: c.name))
        .toList();
    List<TextEditingController> valueControllers = characteristics
        .map((c) => TextEditingController(text: c.value.toString()))
        .toList();
    List<MeasurementUnit> units = characteristics.map((c) => c.unit).toList();

    selectedCategory = widget.product.category;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      showBarModalBottomSheet(
        backgroundColor: Colors.white,
        context: context,
        builder: (context) {
          return _buildEditDialog(
            context,
            nameController,
            subnameController,
            nameControllers,
            valueControllers,
            units,
            characteristics,
          );
        },
      );
    });
  }

  Widget _buildEditDialog(
    BuildContext context,
    TextEditingController nameController,
    TextEditingController subnameController,
    List<TextEditingController> nameControllers,
    List<TextEditingController> valueControllers,
    List<MeasurementUnit> units,
    List<Characteristic> characteristics,
  ) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: StatefulBuilder(
        builder: (context, setState) => CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
                child: _buildTextInputCard(nameController, subnameController)),
            const SliverToBoxAdapter(child: SizedBox(height: 10)),
            SliverToBoxAdapter(child: _buildCategoryDropdown(context)),
            const SliverToBoxAdapter(child: SizedBox(height: 10)),
            SliverList(
                delegate: SliverChildListDelegate(
              [
                ...List.generate(characteristics.length, (index) {
                  return _buildCharacteristicInput(
                    context,
                    setState,
                    index,
                    nameControllers,
                    valueControllers,
                    units,
                    characteristics,
                  );
                }),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      characteristics.add(
                        Characteristic(
                            name: '', value: 0, unit: MeasurementUnit.hours),
                      );
                      nameControllers.add(TextEditingController());
                      valueControllers.add(TextEditingController());
                      units.add(MeasurementUnit.hours);
                    });
                  },
                  child: const Text('Добавить характеристику'),
                ),
              ],
            )),
            const SliverToBoxAdapter(child: SizedBox(height: 10)),
            SliverToBoxAdapter(
              child: _buildSaveButton(
                context,
                nameController,
                subnameController,
                characteristics,
                nameControllers,
                valueControllers,
                units,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCharacteristicInput(
    BuildContext context,
    Function setState,
    int index,
    List<TextEditingController> nameControllers,
    List<TextEditingController> valueControllers,
    List<MeasurementUnit> units,
    List<Characteristic> characteristics,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          shrinkWrap: true,
          children: [
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextInput(
                    controller: nameControllers[index],
                    labelText: 'Название',
                    hintText: 'Разморозка',
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      setState(() {
                        characteristics.removeAt(index);
                        nameControllers.removeAt(index);
                        valueControllers.removeAt(index);
                        units.removeAt(index);
                      });
                    },
                  ),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 3,
                  child: TextInput(
                    controller: valueControllers[index],
                    labelText: 'Значение',
                    hintText: '15',
                    type: TextInputType.number,
                  ),
                ),
                const VerticalDivider(),
                Expanded(
                  flex: 1,
                  child: DropdownButton<MeasurementUnit>(
                    value: units[index],
                    padding: EdgeInsets.zero,
                    onChanged: (newUnit) {
                      setState(() {
                        units[index] = newUnit!;
                      });
                    },
                    alignment: Alignment.center,
                    style: const TextStyle(fontSize: 12, color: Colors.black),
                    items: MeasurementUnit.values.map((MeasurementUnit unit) {
                      return DropdownMenuItem<MeasurementUnit>(
                        value: unit,
                        child: Text(
                          getLocalizedMeasurementUnit(unit),
                          style: const TextStyle(fontSize: 14),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
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
                width: MediaQuery.of(context).size.width - 40,
                leadingIcon: const Icon(Icons.category),
                onSelected: (value) => setState(() {
                  selectedCategory = value;
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

  Widget _buildSaveButton(
    BuildContext context,
    TextEditingController nameController,
    TextEditingController subnameController,
    List<Characteristic> characteristics,
    List<TextEditingController> nameControllers,
    List<TextEditingController> valueControllers,
    List<MeasurementUnit> units,
  ) {
    return ElevatedButton(
      onPressed: () {
        if (selectedCategory == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Выберите категорию')),
          );
          return;
        }

        Product updatedProduct = widget.product.copyWith(
          title: nameController.text,
          subtitle: subnameController.text,
          characteristics: List.generate(characteristics.length, (index) {
            return Characteristic(
              name: nameControllers[index].text,
              value: int.parse(valueControllers[index].text),
              unit: units[index],
            );
          }),
          category: selectedCategory!,
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
