import 'package:bluetooth_app/bloc/bloc.bloc.dart';
import 'package:bluetooth_app/models/nomenclature.dart';
import 'package:bluetooth_app/models/product.dart';
import 'package:bluetooth_app/widgets/text_feild.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProductsTab extends StatefulWidget {
  const ProductsTab({super.key});

  @override
  State<ProductsTab> createState() => _ProductsTabState();
}

class _ProductsTabState extends State<ProductsTab> {
  late GenericBloc<Product> bloc;

  TextEditingController selectedCategoryController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController subnameController =
      TextEditingController();
  TextEditingController categoryController =
      TextEditingController();
  TextEditingController defrostingController =
      TextEditingController();
  TextEditingController closedTimeController =
      TextEditingController();
  TextEditingController openedTimeController =
      TextEditingController();

  bool validCategory = true;

  void createProduct() {
    setState(() {
      if (nameController.text.isEmpty |
          subnameController.text.isEmpty |
          defrostingController.text.isEmpty |
          closedTimeController.text.isEmpty |
          openedTimeController.text.isEmpty |
          categoryController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Необходимо заполнить все поля')));

        return;
      }
    });

    Product product = Product(
      title: nameController.text, 
      subtitle: subnameController.text, 
      defrosting: int.parse(defrostingController.text), 
      closedTime: int.parse(closedTimeController.text), 
      openedTime: int.parse(openedTimeController.text),
      category: categoryController.text
    );

    bloc.add(AddItem<Product>(product));
  }

  @override
  void initState() {
    bloc = context.read<GenericBloc<Product>>()..add(LoadItems<Product>());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: BlocBuilder<GenericBloc<Nomenclature>,
                GenericState<Nomenclature>>(
            builder: (context, stateNomenclature) {
          if (stateNomenclature is ItemsLoaded<Nomenclature>) {
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Row(
                    children: [
                      Expanded(
                        child: DropdownMenu(
                            controller: selectedCategoryController,
                            onSelected: (value) {
                              setState(() {});
                            },
                            hintText: 'Выберете категорию',
                            width: MediaQuery.of(context).size.width - 16,
                            leadingIcon: const Icon(Icons.category),
                            dropdownMenuEntries: List.generate(
                                stateNomenclature.items.length, (index) {
                              return DropdownMenuEntry(
                                  value: index,
                                  label:
                                      stateNomenclature.items[index].name);
                            })),
                      ),
                    ],
                  ),
                ),
                const SliverToBoxAdapter(
                  child: Divider(),
                ),
                
                if (selectedCategoryController.text.isNotEmpty)
                  BlocBuilder<GenericBloc<Product>, GenericState<Product>>(
                    builder: (context, state) {
                      if (state is ItemsLoaded<Product>) {
                        List<Product> products = state.items;
                        List<Product> filteredProducts = products.where((product) => product.category == selectedCategoryController.text).toList();
                      
                        return SliverGrid(
                        delegate: SliverChildBuilderDelegate(childCount: filteredProducts.length,
                            (context, index) {
                          return Card(
                            child: Column(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceEvenly,
                              children: [
                                Text(
                                  filteredProducts[index].title,
                                  style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  filteredProducts[index].subtitle,
                                  style: const TextStyle(
                                      fontSize: 18, color: Colors.grey),
                                ),
                                Text(
                                  filteredProducts[index].category,
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  'Разморозка: ${filteredProducts[index].defrosting}ч.'
                                ),
                                Text(
                                  'Открытое хранение: ${filteredProducts[index].openedTime}ч.'
                                ),
                                Text(
                                  'Закрытое хранение: ${filteredProducts[index].closedTime}ч.'
                                ),
                              ],
                            ),
                          );
                        }),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2, childAspectRatio: 4 / 3));
                      }
                      
                      return const SizedBox.shrink();
                    },
                  )
                else
                  const SliverToBoxAdapter(
                    child: Center(
                      child: Text('Выберете категорию'),
                    ),
                  )
              ],
            );
          }
        
          if (stateNomenclature is ItemOperationFailed<Nomenclature>) {
            return Center(
              child: Text(
                  'Ошибка загрузки категорий: ${stateNomenclature.error}'),
            );
          }
        
          return const SizedBox.shrink();
        }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (context) {
              return BottomSheet(
                onClosing: () {},
                builder: (context) {
                  return StatefulBuilder(builder: (context, setState) {
                    return Scaffold(
                      body: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CustomScrollView(
                          slivers: [
                            const SliverAppBar(
                              centerTitle: true,
                              title: Text('Добавление ингридиента'),
                              automaticallyImplyLeading: false,
                            ),
                            SliverToBoxAdapter(
                              child: Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      TextInput(
                                          controller:
                                              nameController,
                                          hintText: 'Морковь',
                                          labelText: 'Название'),
                                      TextInput(
                                          controller:
                                              subnameController,
                                          hintText: 'Морковь очищеная',
                                          labelText: 'Короткое название'),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SliverToBoxAdapter(
                              child: SizedBox(
                                height: 10,
                              ),
                            ),
                            SliverToBoxAdapter(
                              child: Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: BlocBuilder<GenericBloc<Nomenclature>, GenericState<Nomenclature>>(
                                    builder: (context, state) {
                                      if (state is ItemsLoaded<Nomenclature>) {
                                        return DropdownMenu(
                                          controller: categoryController,
                                          onSelected: (value) => setState(() {
                                                      validCategory = true;
                                                    }),
                                          hintText: 'Выберете категорию',
                                          width: MediaQuery.of(context).size.width - 40,
                                          leadingIcon: const Icon(Icons.category),
                                          dropdownMenuEntries: List.generate(
                                              state.items.length, (index) {
                                            return DropdownMenuEntry(
                                                value: index,
                                                label:
                                                    state.items[index].name);
                                          }));
                                      }

                                      return const SizedBox.shrink();
                                    } 
                                  ),
                                ),
                              ),
                            ),
                            const SliverToBoxAdapter(
                              child: SizedBox(
                                height: 10,
                              ),
                            ),
                            SliverToBoxAdapter(
                              child: Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      const Text('Сроки указываются в часах'),
                                      TextInput(
                                          controller:
                                              defrostingController,
                                          hintText: '100',
                                          labelText: 'Размарозка',
                                          type: TextInputType.number,
                                          icon: Icons.ac_unit),
                                      TextInput(
                                          controller:
                                              closedTimeController,
                                          hintText: '100',
                                          labelText: 'Срок закрытого хранения',
                                          type: TextInputType.number,
                                          icon: Icons.close_fullscreen),
                                      TextInput(
                                          controller:
                                              openedTimeController,
                                          hintText: '100',
                                          labelText: 'Срок открытого хранения',
                                          type: TextInputType.number,
                                          icon: Icons.open_with),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SliverToBoxAdapter(
                              child: SizedBox(
                                height: 10,
                              ),
                            ),
                            SliverToBoxAdapter(
                              child: ElevatedButton(
                                  onPressed: createProduct,
                                  child: const Text('Добавить')),
                            )
                          ],
                        ),
                      ),
                    );
                  });
                },
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
