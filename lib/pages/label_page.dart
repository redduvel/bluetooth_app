import 'dart:io';

import 'package:bluetooth_app/bloc/bloc.bloc.dart';
import 'package:bluetooth_app/bloc/printer/printer.bloc.dart';
import 'package:bluetooth_app/bloc/printer/printer.event.dart';
import 'package:bluetooth_app/bloc/printer/printer.state.dart';
import 'package:bluetooth_app/bloc/search_engine/search.bloc.dart';
import 'package:bluetooth_app/bloc/search_engine/search.event.dart';
import 'package:bluetooth_app/bloc/search_engine/search.state.dart';
import 'package:bluetooth_app/models/employee.dart';
import 'package:bluetooth_app/models/nomenclature.dart';
import 'package:bluetooth_app/models/product.dart';
import 'package:bluetooth_app/pages/tabs/products_tab.dart';
import 'package:bluetooth_app/widgets/product_gridcard.dart';
import 'package:bluetooth_app/widgets/text_feild.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class LabelPage extends StatefulWidget {
  const LabelPage({super.key});

  @override
  State<LabelPage> createState() => _LabelPageState();
}

class _LabelPageState extends State<LabelPage> {
  late PrinterBloc printerBloc;
  late GenericSearchBloc<Product> productSearchBloc;
  late GenericSearchBloc<Nomenclature> nomenclatureSearchBloc;
  final TextEditingController searchController = TextEditingController();

  Set<Nomenclature> selectedNomenclatures = {};
  List<Product> products = [];

  @override
  void initState() {
    super.initState();
    printerBloc = context.read<PrinterBloc>();
    printerBloc.add(InitializePrinter());

    productSearchBloc = context.read<GenericSearchBloc<Product>>();
    nomenclatureSearchBloc = context.read<GenericSearchBloc<Nomenclature>>();
  }

  @override
  Widget build(BuildContext context) {
    final employeeName =
        context.read<GenericBloc<Employee>>().repository.currentItem.fullName;

    return Scaffold(
      appBar: AppBar(
        title: Text(employeeName),
        centerTitle: false,
        actions: [
          IconButton(
              onPressed: () {
                showBarModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return StatefulBuilder(builder: (context, setState) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        child: CustomScrollView(
                          slivers: [
                            const SliverToBoxAdapter(
                                child: Center(
                                    child: Text('Поиск',
                                        style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.w500)))),
                            SliverToBoxAdapter(
                              child: TextField(
                                controller: searchController,
                                onChanged: (value) {
                                  if (value.isEmpty) {
                                    setState(() {
                                      products.clear();
                                    });
                                  }
                                  nomenclatureSearchBloc
                                      .add(SearchItems<Nomenclature>(value));
                                  productSearchBloc
                                      .add(SearchItems<Product>(value));
                                },
                              ),
                            ),
                            const SliverToBoxAdapter(
                                child: SizedBox(height: 30)),
                            BlocBuilder<GenericSearchBloc<Nomenclature>,
                                GenericSearchState<Nomenclature>>(
                              bloc: nomenclatureSearchBloc,
                              builder: (context, state) {
                                if (state is SearchLoading<Nomenclature>) {
                                  return const SliverToBoxAdapter(
                                      child: CircularProgressIndicator());
                                } else if (state
                                    is SearchLoaded<Nomenclature>) {
                                  final nomenclatures = state.items
                                      .where((n) => !n.isHide)
                                      .toList();

                                  return SliverToBoxAdapter(
                                    child: Wrap(
                                      runSpacing: 5,
                                      spacing: 5,
                                      children: List.generate(
                                          nomenclatures.length, (index) {
                                        Nomenclature nomenclature =
                                            nomenclatures[index];
                                        return ChoiceChip(
                                          label: Text(nomenclature.name),
                                          selected: selectedNomenclatures
                                              .contains(nomenclature),
                                          onSelected: (value) {},
                                        );
                                      }),
                                    ),
                                  );
                                } else if (state is SearchError<Nomenclature>) {
                                  return SliverToBoxAdapter(
                                      child: Text(
                                    state.message,
                                    style: const TextStyle(fontSize: 24),
                                  ));
                                } else {
                                  return SliverToBoxAdapter(child: Container());
                                }
                              },
                            ),
                            BlocBuilder<GenericSearchBloc<Product>,
                                GenericSearchState<Product>>(
                              bloc: productSearchBloc,
                              builder: (context, state) {
                                if (state is SearchLoading<Product>) {
                                  return const SliverToBoxAdapter(
                                      child: CircularProgressIndicator());
                                } else if (state is SearchLoaded<Product>) {
                                  WidgetsBinding.instance
                                      .addPostFrameCallback((_) {
                                    setState(() {
                                      products = state.items;
                                    });
                                  });
                                  return const SliverToBoxAdapter(
                                      child: SizedBox());
                                } else {
                                  return SliverToBoxAdapter(child: Container());
                                }
                              },
                            ),
                            ..._buildProductsList(products)
                          ],
                        ),
                      );
                    });
                  },
                );
              },
              icon: const Icon(Icons.search)),
          if (Platform.isAndroid || Platform.isIOS)
            BlocBuilder<PrinterBloc, PrinterState>(
              builder: (context, state) {
                if (state is PrinterLoading) {
                  return const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: SpinKitFadingCircle(
                      color: Colors.orange,
                      size: 25.0,
                    ),
                  );
                }

                return IconButton(
                  onPressed: () => _showPrinterSettings(context),
                  icon: Icon(
                    printerBloc.connectedDevice != null
                        ? Icons.print
                        : Icons.print_disabled,
                    color: printerBloc.connectedDevice != null
                        ? Colors.green
                        : Colors.red,
                  ),
                );
              },
            ),
        ],
      ),
      body: ProductsTab(
        showProductTools: false,
        showFloatingActionButton: false,
        showHideEnemies: true,
        isSetting: false,
        gridCrossAxisCount: Platform.isMacOS || Platform.isWindows ? 7 : 2,
        gridChilAspectRatio:
            Platform.isMacOS || Platform.isWindows ? 3 / 4 : 1 / 1,
      ),
    );
  }

  void _showPrinterSettings(BuildContext context) {
    showBarModalBottomSheet(
      context: context,
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height / 2,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: BlocBuilder<PrinterBloc, PrinterState>(
              bloc: printerBloc,
              builder: (context, state) {
                return CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      backgroundColor: Colors.transparent,
                      title: const Text('Настройки Bluetooth'),
                      automaticallyImplyLeading: false,
                      actions: [
                        IconButton(
                            onPressed: () {
                              printerBloc.add(InitializePrinter());
                            },
                            icon: const Icon(Icons.refresh)),
                        IconButton(
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    TextEditingController heightController =
                                        TextEditingController(
                                            text: printerBloc.labelHeigth);
                                    TextEditingController widthController =
                                        TextEditingController(
                                            text: printerBloc.labelWidth);
                                    TextEditingController gapController =
                                        TextEditingController(
                                            text: printerBloc.labelGap);
                                    return AlertDialog(
                                      title: const Text('Настройки этикетки'),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          TextInput(
                                              controller: heightController,
                                              hintText: '20',
                                              labelText:
                                                  'Высота этикетки (mm)'),
                                          TextInput(
                                              controller: widthController,
                                              hintText: '30',
                                              labelText:
                                                  'Ширина этикетки (mm)'),
                                          TextInput(
                                              controller: gapController,
                                              hintText: '2',
                                              labelText:
                                                  'Расстояние между этикетками (mm)'),
                                        ],
                                      ),
                                      actions: [
                                        ElevatedButton(
                                            onPressed: () {
                                              printerBloc.add(SetSettings(
                                                  height: heightController.text,
                                                  width: widthController.text,
                                                  gap: gapController.text));
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(const SnackBar(
                                                      content: Text(
                                                          'Настройки этикетки изменены!')));
                                              Navigator.pop(context);
                                            },
                                            child: const Text('Подтвердить'))
                                      ],
                                    );
                                  });
                            },
                            icon: const Icon(Icons.settings))
                      ],
                    ),
                    if (state is PrinterLoading)
                      const SliverToBoxAdapter(
                        child: Center(
                            child: SpinKitFadingCircle(
                          color: Colors.orange,
                          size: 40,
                        )),
                      ),
                    if (state is DevicesLoaded) _buildDeviceList(state.devices),
                    if (state is PrinterDisconnected)
                      const SliverToBoxAdapter(
                          child: Center(child: Text('Принтер отключен'))),
                    if (state is PrinterConnected)
                      _buildDeviceList(printerBloc.devices)
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildDeviceList(List<BluetoothDevice> devices) {
    final devicess = devices.where((d) => d.platformName != '').toList();

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final device = devicess[index];
          return ListTile(
            title: Text(device.platformName),
            subtitle: Text(device.remoteId.toString()),
            onTap: () => printerBloc.add(ConnectToDevice(device)),
            trailing: printerBloc.connectedDevice == device
                ? const Text(
                    'Подключено',
                    style: TextStyle(color: Colors.green),
                  )
                : null,
          );
        },
        childCount: devicess.length,
      ),
    );
  }

  _buildProductGrid(List<Product> items) {
    return CustomScrollView(
      slivers: [
        ..._buildProductsList(items),
      ],
    );
  }

  List<Widget> _buildProductsList(List<Product> products) {
    Map<Nomenclature, List<Product>> productsByCategory =
        groupProductsByNomenclature(products);

    if (products.isEmpty) {
      return [
        const SliverToBoxAdapter(
          child: SizedBox.shrink(),
        )
      ];
    }

    for (var product in products) {
      if (selectedNomenclatures
          .any((nomenclature) => product.category.id == nomenclature.id)) {
        if (!productsByCategory.containsKey(product.category)) {
          productsByCategory[product.category] = [];
        }
        productsByCategory[product.category]!.add(product);
      }
    }

    List<Widget> widgets = [];

    widgets = productsByCategory.entries.map((entry) {
      final category = entry.key;
      final productsInCategory = entry.value;

      return SliverList(
        delegate: SliverChildListDelegate([
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              category.name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(),
          GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: Platform.isMacOS || Platform.isWindows ? 7 : 2,
        childAspectRatio:
            Platform.isMacOS || Platform.isWindows ? 3 / 4 : 1 / 1,),
              itemBuilder: (context, index) {
                final product = productsInCategory[index];

                return ProductGridItem(
                  product: product,
                  bloc: context.read<GenericBloc<Product>>(),
                );
              },
              itemCount: productsInCategory.length)
        ]),
      );
    }).toList();

    return widgets;
  }

  Map<Nomenclature, List<Product>> groupProductsByNomenclature(
      List<Product> products) {
    Map<Nomenclature, List<Product>> groupedProducts = {};

    for (var product in products) {
      if (!groupedProducts.containsKey(product.category)) {
        groupedProducts[product.category] = [];
      }
      groupedProducts[product.category]?.add(product);
    }

    return groupedProducts;
  }
}
