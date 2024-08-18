import 'package:bluetooth_app/bloc/bloc.bloc.dart';
import 'package:bluetooth_app/models/nomenclature.dart';
import 'package:bluetooth_app/models/product.dart';
import 'package:bluetooth_app/widgets/product_card.dart';
import 'package:bluetooth_app/widgets/product_gridcard.dart';
import 'package:bluetooth_app/widgets/text_feild.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProductsTab extends StatefulWidget {
  final bool showProductTools;
  final bool showFloatingActionButton;
  final bool showHideProducts;
  final bool isSetting;
  final double gridChilAspectRatio;
  final int gridCrossAxisCount;

  const ProductsTab({
    super.key,
    required this.showProductTools,
    required this.showFloatingActionButton,
    required this.showHideProducts,
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
  TextEditingController defrostingController = TextEditingController();
  TextEditingController closedTimeController = TextEditingController();
  TextEditingController openedTimeController = TextEditingController();
  bool validCategory = true;

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
    defrostingController.dispose();
    closedTimeController.dispose();
    openedTimeController.dispose();
    super.dispose();
  }

  void createProduct() {
    if (_isInputValid()) {
      final product = Product(
        title: nameController.text,
        subtitle: subnameController.text,
        defrosting: int.parse(defrostingController.text),
        closedTime: int.parse(closedTimeController.text),
        openedTime: int.parse(openedTimeController.text),
        category: selectedCategory!, // Сохраняем выбранную категорию
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
        defrostingController.text.isNotEmpty &&
        closedTimeController.text.isNotEmpty &&
        openedTimeController.text.isNotEmpty &&
        selectedCategory != null;
  }

  void _resetControllers() {
    nameController.clear();
    subnameController.clear();
    defrostingController.clear();
    closedTimeController.clear();
    openedTimeController.clear();
    selectedCategory = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: BlocBuilder<GenericBloc<Nomenclature>, GenericState<Nomenclature>>(
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
                _resetControllers(); // Сброс контроллеров перед созданием нового продукта
                _showAddProductModal();
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildProductGrid(List<Nomenclature> nomenclatures) {
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
                  dropdownMenuEntries: nomenclatures.map((nomenclature) {
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
                final filteredProducts = _getFilteredProducts(productState.items);
                if (filteredProducts.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Center(child: Text('Нет продуктов для этой категории.')),
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
        .where((product) => product.category.id == selectedCategory?.id) // Сравниваем по id категории
        .where((product) => widget.showHideProducts || !product.isHide)
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
        crossAxisCount: widget.gridCrossAxisCount,
        childAspectRatio: widget.gridChilAspectRatio,
      ),
    );
  }

  void _showAddProductModal() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return BottomSheet(
          onClosing: () {},
          builder: (context) {
            return StatefulBuilder(
              builder: (context, setState) {
                return Scaffold(
                  body: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CustomScrollView(
                      slivers: [
                        const SliverAppBar(
                          centerTitle: true,
                          title: Text('Добавление продукта'),
                          automaticallyImplyLeading: false,
                        ),
                        _buildProductNameInputs(),
                        const SliverToBoxAdapter(child: SizedBox(height: 10)),
                        _buildCategoryDropdown(setState, context),
                        const SliverToBoxAdapter(child: SizedBox(height: 10)),
                        _buildProductTimesInputs(),
                        const SliverToBoxAdapter(child: SizedBox(height: 10)),
                        SliverToBoxAdapter(
                          child: ElevatedButton(
                            onPressed: createProduct,
                            child: const Text('Добавить'),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildProductNameInputs() {
    return SliverToBoxAdapter(
      child: Card(
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
      ),
    );
  }

  Widget _buildCategoryDropdown(void Function(void Function()) setState, BuildContext context) {
    return SliverToBoxAdapter(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: BlocBuilder<GenericBloc<Nomenclature>, GenericState<Nomenclature>>(
            builder: (context, state) {
              if (state is ItemsLoaded<Nomenclature>) {
                return DropdownMenu<Nomenclature>(
                  onSelected: (value) => setState(() {
                    selectedCategory = value;
                  }),
                  hintText: 'Выберите категорию',
                  width: MediaQuery.of(context).size.width - 40,
                  leadingIcon: const Icon(Icons.category),
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
      ),
    );
  }

  Widget _buildProductTimesInputs() {
    return SliverToBoxAdapter(
      child: Card(
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
      ),
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Text('Ошибка загрузки категорий: $error'),
    );
  }
}
