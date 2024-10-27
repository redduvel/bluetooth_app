import 'package:bluetooth_app/clean/config/theme/colors.dart';
import 'package:bluetooth_app/clean/config/theme/text_styles.dart';
import 'package:bluetooth_app/clean/core/Domain/bloc/db.bloc.dart';
import 'package:bluetooth_app/clean/core/Domain/entities/category.dart';
import 'package:bluetooth_app/clean/core/Domain/entities/product.dart';
import 'package:bluetooth_app/clean/core/Presentation/widgets/primary_appbar.dart';
import 'package:bluetooth_app/clean/features/printing/Presentation/bloc/printer.bloc.dart';
import 'package:bluetooth_app/clean/features/printing/Presentation/widgets/product_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:universal_io/io.dart';

class PrintingPage extends StatefulWidget {
  const PrintingPage({super.key});

  @override
  State<PrintingPage> createState() => _PrintingPageState();
}

class _PrintingPageState extends State<PrintingPage> {
  late PrinterBloc printerBloc;

  Set<Category> selectedCategories = {};
  List<Category> categories = [];
  Category? selectedCategory;
  List<Product> products = [];

  @override
  void initState() {
    super.initState();
    printerBloc = context.read<PrinterBloc>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: (Platform.isMacOS || Platform.isWindows)
          ? PrimaryAppBar(
              title: 'Печать маркировок',
              titleStyle: AppTextStyles.labelMedium18.copyWith(fontSize: 24),
              buttons: [
                BlocBuilder<DBBloc<Product>, DBState<Product>>(
                    builder: (context, state) {
                  if (state is ItemsLoaded<Product>) {
                    return IconButton(
                        onPressed: () => context.read<DBBloc<Product>>().add(Sync<Product>()),
                        icon: const Icon(Icons.sync));
                  }
                  if (state is ItemsLoading<Product>) {
                    return const CircularProgressIndicator(
                        color: AppColors.greenOnSurface);
                  }

                  return const SizedBox.shrink();
                }),
              ],
            )
          : null,
      body: CustomScrollView(
        slivers: [
          if (Platform.isIOS || Platform.isAndroid)
            SliverAppBar(
              backgroundColor: AppColors.white,
              title: Text(
                'Печать маркировок',
                style: AppTextStyles.labelMedium18.copyWith(fontSize: 24),
              ),
              centerTitle: false,
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                    onPressed: () => context.read<DBBloc<Product>>().add(Sync<Product>()),
                    icon: const Icon(Icons.sync))
              ],
            ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            sliver: SliverToBoxAdapter(
              child: BlocBuilder<DBBloc<Category>, DBState<Category>>(
                  builder: (context, state) {
                if (state is ItemsLoaded<Category>) {
                  return Wrap(
                    runSpacing: 5,
                    spacing: 5,
                    children: List.generate(state.items.length, (index) {
                      Category category = state.items[index];
                      return ChoiceChip(
                        backgroundColor: AppColors.surface,
                        selectedColor: AppColors.greenSurface,
                        checkmarkColor: AppColors.greenOnSurface,
                        selectedShadowColor: AppColors.greenOnSurface,
                        label: Text(category.name),
                        selected: selectedCategories.contains(category),
                        onSelected: (value) {
                          setState(() {
                            if (selectedCategories.contains(category)) {
                              selectedCategories.remove(category);
                            } else {
                              selectedCategories.add(category);
                              selectedCategory = category;
                            }
                          });
                        },
                      );
                    }),
                  );
                }

                return const SizedBox.shrink();
              }),
            ),
          ),
          if (selectedCategory != null)
            BlocBuilder<DBBloc<Product>, DBState<Product>>(
              builder: (context, productState) {
                if (productState is ItemsLoaded<Product>) {
                  final filteredProducts = _getFilteredProducts(
                      productState.items, selectedCategories);
                  if (filteredProducts.isEmpty) {
                    return const SliverToBoxAdapter(
                      child: Center(
                          child: Text(
                        'Нет продуктов для этой категории.',
                        style: AppTextStyles.labelMedium18,
                      )),
                    );
                  } else {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      setState(() {
                        products = productState.items;
                      });
                    });
                  }
                }
                return const SliverToBoxAdapter(child: SizedBox.shrink());
              },
            )
          else
            const SliverToBoxAdapter(
              child: Center(
                  child: Text(
                'Выберите категорию',
                style: AppTextStyles.labelMedium18,
              )),
            ),
          ..._buildProductsList(products),
        ],
      ),
    );
  }

  List<Product> _getFilteredProducts(
      List<Product> products, Set<Category> nomenclatures) {
    final productss = products.where((product) {
      return nomenclatures
          .any((nomenclature) => product.category.id == nomenclature.id);
    }).toList();
    return productss;
  }

  List<Widget> _buildProductsList(List<Product> products) {
    Map<Category, List<Product>> productsByCategory = {};

    if (products.isEmpty) {
      return [
        const SliverToBoxAdapter(
          child: SizedBox.shrink(),
        )
      ];
    }

    for (var product in products) {
      if (selectedCategories
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

      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        sliver: SliverList(
          delegate: SliverChildListDelegate([
            Text(
              category.name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Wrap(
              spacing: 15,
              runSpacing: 15,
              children: List.generate(productsInCategory.length, (index) {
                return ProductWidget(
                  product: productsInCategory[index],
                  bloc: context.read<DBBloc<Product>>(),
                );
              }),
            )
          ]),
        ),
      );
    }).toList();

    return widgets;
  }
}
