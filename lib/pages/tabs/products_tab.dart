import 'package:bluetooth_app/bloc/bloc.bloc.dart';
import 'package:bluetooth_app/models/nomenclature.dart';
import 'package:bluetooth_app/models/product.dart';
import 'package:bluetooth_app/models/characteristic.dart';
import 'package:bluetooth_app/widgets/product_card.dart';
import 'package:bluetooth_app/widgets/product_gridcard.dart';
import 'package:bluetooth_app/widgets/text_feild.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class ProductsTab extends StatefulWidget {
  final bool showProductTools;
  final bool showFloatingActionButton;
  final bool showHideEnemies;
  final bool isSetting;
  final double gridChilAspectRatio;
  final int gridCrossAxisCount;

  const ProductsTab({
    super.key,
    required this.showProductTools,
    required this.showFloatingActionButton,
    required this.showHideEnemies,
    required this.gridChilAspectRatio,
    required this.gridCrossAxisCount,
    required this.isSetting,
  });

  @override
  State<ProductsTab> createState() => _ProductsTabState();
}

class _ProductsTabState extends State<ProductsTab> {
  late GenericBloc<Product> productBloc;
  Nomenclature? selectedCategory;

  // Контроллеры для создания продукта
  TextEditingController nameController = TextEditingController();
  TextEditingController subnameController = TextEditingController();
  bool validCategory = true;

  List<Characteristic> characteristics = [];
  List<TextEditingController> nameControllers = [];
  List<TextEditingController> valueControllers = [];
  List<MeasurementUnit> units = [];

  @override
  void initState() {
    super.initState();
    productBloc = context.read<GenericBloc<Product>>();
    productBloc.add(LoadItems<Product>());
  }

  @override
  void dispose() {
    nameController.dispose();
    subnameController.dispose();
    for (var controller in nameControllers) {
      controller.dispose();
    }
    for (var controller in valueControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void createProduct() {
    if (_isInputValid()) {
      final product = Product(
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
        isHide: false,
      );

      productBloc.add(AddItem<Product>(product));

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Необходимо заполнить все поля')),
      );
    }
  }

  bool _isInputValid() {
    return nameController.text.isNotEmpty &&
        subnameController.text.isNotEmpty &&
        selectedCategory != null &&
        characteristics.isNotEmpty &&
        nameControllers.every((controller) => controller.text.isNotEmpty) &&
        valueControllers.every((controller) => controller.text.isNotEmpty);
  }

  void _resetControllers() {
    nameController.clear();
    subnameController.clear();
    selectedCategory = null;

    characteristics.clear();
    nameControllers.clear();
    valueControllers.clear();
    units.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child:
            BlocBuilder<GenericBloc<Nomenclature>, GenericState<Nomenclature>>(
          builder: (context, nomenclatureState) {
            if (nomenclatureState is ItemsLoaded<Nomenclature>) {
              return _buildProductGrid(nomenclatureState.items);
            }

            if (nomenclatureState is ItemOperationFailed<Nomenclature>) {
              return _buildError(nomenclatureState.error);
            }

            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
      floatingActionButton: widget.showFloatingActionButton
          ? FloatingActionButton(
              onPressed: () {
                _resetControllers();

                _showAddProductModal();
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildProductGrid(List<Nomenclature> items) {
    var filteredNomenclatures = items;
    if (!widget.showHideEnemies) {
      filteredNomenclatures = items
          .where((n) => !n.isHide)
          .where((n) => n.name != 'Архив')
          .toList();
    }

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Row(
            children: [
              Expanded(
                child: DropdownMenu<Nomenclature>(
                  onSelected: (value) => setState(() {
                    selectedCategory = value;
                  }),
                  hintText: 'Выберите категорию',
                  width: MediaQuery.of(context).size.width - 16,
                  leadingIcon: const Icon(Icons.category),
                  dropdownMenuEntries:
                      filteredNomenclatures.map((nomenclature) {
                    return DropdownMenuEntry(
                      value: nomenclature,
                      label: nomenclature.name,
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        const SliverToBoxAdapter(child: Divider()),
        if (selectedCategory != null)
          BlocBuilder<GenericBloc<Product>, GenericState<Product>>(
            builder: (context, productState) {
              if (productState is ItemsLoaded<Product>) {
                final filteredProducts =
                    _getFilteredProducts(productState.items);
                if (filteredProducts.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Center(
                        child: Text('Нет продуктов для этой категории.')),
                  );
                }
                return _buildProductGridItems(filteredProducts);
              }
              return const SliverToBoxAdapter(child: SizedBox.shrink());
            },
          )
        else
          const SliverToBoxAdapter(
            child: Center(child: Text('Выберите категорию')),
          ),
      ],
    );
  }

  List<Product> _getFilteredProducts(List<Product> products) {
    return products
        .where((product) =>
            product.category.id ==
            selectedCategory?.id) // Сравниваем по id категории
        .where((product) => widget.showHideEnemies || !product.isHide)
        .toList();
  }

  Widget _buildProductGridItems(List<Product> products) {
    return SliverGrid(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final product = products[index];
          if (widget.isSetting) {
            return ProductCard(
              product: product,
              bloc: productBloc,
              showTools: widget.showProductTools,
            );
          } else {
            return ProductGridItem(
              product: product,
              bloc: productBloc,
            );
          }
        },
        childCount: products.length,
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.isSetting ? widget.gridCrossAxisCount : products.length % 2 == 0 ? 2 : widget.gridCrossAxisCount,
        childAspectRatio: widget.isSetting ? widget.gridChilAspectRatio : products.length % 2 == 0 ? 4/3 : widget.gridChilAspectRatio,
      ),
    );
  }

  Widget _buildProductNameInputs() {
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

  Widget _buildCategoryDropdown(
      void Function(void Function()) setState, BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child:
            BlocBuilder<GenericBloc<Nomenclature>, GenericState<Nomenclature>>(
          builder: (context, state) {
            if (state is ItemsLoaded<Nomenclature>) {
              var nomenclatures = state.items;
              if (!widget.showHideEnemies) {
                nomenclatures =
                    nomenclatures.where((n) => n.name != 'Архив').toList();
              }

              return DropdownMenu<Nomenclature>(
                onSelected: (value) => setState(() {
                  selectedCategory = value;
                }),
                hintText: 'Выберите категорию',
                width: MediaQuery.of(context).size.width - 40,
                leadingIcon: const Icon(Icons.category),
                dropdownMenuEntries: nomenclatures.map((nomenclature) {
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

  Widget _buildError(String error) {
    return Center(
      child: Text('Ошибка загрузки категорий: $error'),
    );
  }

  void _showAddProductModal() {
    showBarModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: StatefulBuilder(
          builder: (context, setState) {
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildProductNameInputs()),
                const SliverToBoxAdapter(child: SizedBox(height: 10)),
                SliverToBoxAdapter(
                    child: _buildCategoryDropdown(setState, context)),
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
                                name: '',
                                value: 0,
                                unit: MeasurementUnit.hours),
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
                  child: ElevatedButton(
                    onPressed: createProduct,
                    child: const Text('Добавить'),
                  ),
                ),
              ],
            );
          },
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
}
