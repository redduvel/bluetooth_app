import 'package:bluetooth_app/clean/config/theme/colors.dart';
import 'package:bluetooth_app/clean/config/theme/text_styles.dart';
import 'package:bluetooth_app/clean/core/Domain/bloc/db.bloc.dart';
import 'package:bluetooth_app/clean/core/Domain/entities/marking/category.dart';
import 'package:bluetooth_app/clean/core/Domain/entities/marking/characteristic.dart';
import 'package:bluetooth_app/clean/core/Domain/entities/marking/product.dart';
import 'package:bluetooth_app/clean/core/Presentation/widgets/primary_appbar.dart';
import 'package:bluetooth_app/clean/core/Presentation/widgets/primary_button.dart';
import 'package:bluetooth_app/clean/core/Presentation/widgets/primary_textfield.dart';
import 'package:bluetooth_app/clean/features/admin/presentation/cubit/dropdown_controller.dart';
import 'package:bluetooth_app/clean/features/admin/presentation/widgets/allow_free_marking_widget.dart';
import 'package:bluetooth_app/clean/features/admin/presentation/widgets/characteristics_widget.dart';
import 'package:bluetooth_app/clean/features/admin/presentation/widgets/selected_category_widget.dart';
import 'package:bluetooth_app/clean/features/printing/Presentation/widgets/product_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:universal_io/io.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  late DBBloc<Product> bloc;

  TextEditingController nameController = TextEditingController();
  TextEditingController subnameController = TextEditingController();
  bool checkAllowFreeTime = true;
  bool validCategory = true;
  late DropdownCubit<Category> categoryController;

  bool showTools = false;

  List<Characteristic> characteristics = [];
  List<TextEditingController> nameControllers = [];
  List<TextEditingController> valueControllers = [];
  List<MeasurementUnit> units = [];

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
          category: categoryController.state!,
          isHide: false,
          allowFreeTime: checkAllowFreeTime);

      context.read<DBBloc<Product>>().add(AddItem<Product>(product));
      setState(() {
        _resetControllers();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Необходимо заполнить все поля')),
      );
    }
  }

  bool _isInputValid() {
    return nameController.text.isNotEmpty &&
        subnameController.text.isNotEmpty &&
        categoryController.state != null &&
        //characteristics.isNotEmpty &&
        nameControllers.every((controller) => controller.text.isNotEmpty) &&
        valueControllers.every((controller) => controller.text.isNotEmpty);
  }

  void _resetControllers() {
    nameController.clear();
    subnameController.clear();
    characteristics.clear();
    nameControllers.clear();
    valueControllers.clear();
    units.clear();
  }

  @override
  void initState() {
    categoryController = context.read<DropdownCubit<Category>>();
    bloc = context.read<DBBloc<Product>>()..add(LoadItems());
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: (Platform.isMacOS || Platform.isWindows)
          ? PrimaryAppBar(
              title: 'Управление продуктами',
              titleStyle: AppTextStyles.labelMedium18.copyWith(fontSize: 24),
              onSearch: (query) {
                context.read<DBBloc<Product>>().add(Search(query));
              },
              buttons: [
                IconButton(
                    onPressed: () {
                      setState(() {
                        showTools = !showTools;
                      });
                    },
                    icon: Icon(
                        showTools ? Icons.keyboard_arrow_down : Icons.add)),
                BlocBuilder<DBBloc<Product>, DBState<Product>>(
                    builder: (context, state) {
                  if (state is ItemsLoaded<Product>) {
                    return IconButton(
                        onPressed: () => bloc.add(Sync<Product>()),
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
                'Управление продуктами',
                style: AppTextStyles.labelMedium18.copyWith(fontSize: 24),
              ),
              centerTitle: false,
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                    onPressed: () => setState(
                          () => showTools = !showTools,
                        ),
                    icon: Icon(
                        showTools ? Icons.keyboard_arrow_down : Icons.add)),
                IconButton(
                    onPressed: () => bloc.add(Sync<Product>()),
                    icon: const Icon(Icons.sync))
              ],
            ),
          if (showTools) ...[
            SliverPadding(
                padding: const EdgeInsets.all(8),
                sliver: SliverList(
                    delegate: SliverChildListDelegate([
                  PrimaryTextField(
                      controller: nameController,
                      width: 500,
                      hintText: 'Полное название'),
                  PrimaryTextField(
                      controller: subnameController,
                      width: 500,
                      hintText: 'Короткое название'),
                ]))),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              sliver: SliverToBoxAdapter(
                  child: (Platform.isMacOS || Platform.isWindows)
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            SelectedCategoryWidget(
                                controller: categoryController),
                            CheckBox(
                              value: checkAllowFreeTime,
                              title: 'Разрешить свободную маркировку?',
                            )
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            SelectedCategoryWidget(
                                controller: categoryController),
                            CheckBox(
                              value: checkAllowFreeTime,
                              title: 'Разрешить свободную маркировку?',
                            )
                          ],
                        )),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 10)),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
              sliver: SliverToBoxAdapter(
                  child: CharacteristicsWidget(
                nameControllers: nameControllers,
                valueControllers: valueControllers,
                characteristics: characteristics,
                units: units,
              )),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 16),
              sliver: SliverToBoxAdapter(
                child: PrimaryButtonIcon(
                  onPressed: createProduct,
                  icon: Icons.add,
                  selected: true,
                  alignment: Alignment.center,
                  text: 'Добавить',
                ),
              ),
            ),
          ],
          SliverPadding(
            padding: const EdgeInsets.all(8),
            sliver: SliverToBoxAdapter(
                child: BlocBuilder<DBBloc<Product>, DBState<Product>>(
              bloc: bloc,
              builder: (context, state) {
                if (state is ItemsLoaded<Product>) {
                  final products = state.items;
                  return Wrap(
                    spacing: 15,
                    runSpacing: 15,
                    children: products.map((p) {
                      return p.isHide
                          ? Opacity(
                              opacity: 0.5,
                              child: ProductWidget(
                                product: p,
                                bloc: bloc,
                              ),
                            )
                          : ProductWidget(
                              product: p,
                              bloc: bloc,
                            );
                    }).toList(),
                  );
                }

                if (state is ItemsLoading<Product>) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (state is ItemOperationFailed<Product>) {
                  return Center(
                    child: Text(state.error),
                  );
                }

                return const SizedBox.shrink();
              },
            )),
          )
        ],
      ),
    );
  }
}
