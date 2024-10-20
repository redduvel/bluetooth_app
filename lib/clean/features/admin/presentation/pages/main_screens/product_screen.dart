import 'package:bluetooth_app/clean/config/theme/colors.dart';
import 'package:bluetooth_app/clean/core/Domain/bloc/db.bloc.dart';
import 'package:bluetooth_app/clean/core/Domain/entities/category.dart';
import 'package:bluetooth_app/clean/core/Domain/entities/characteristic.dart';
import 'package:bluetooth_app/clean/core/Domain/entities/product.dart';
import 'package:bluetooth_app/clean/core/Presentation/widgets/primary_appBar.dart';
import 'package:bluetooth_app/clean/core/Presentation/widgets/primary_button.dart';
import 'package:bluetooth_app/clean/core/Presentation/widgets/primary_textfield.dart';
import 'package:bluetooth_app/clean/features/admin/presentation/cubit/dropdown_controller.dart';
import 'package:bluetooth_app/clean/features/admin/presentation/pages/main_screens/settings_screen.dart';
import 'package:bluetooth_app/clean/features/admin/presentation/widgets/allow_free_marking_widget.dart';
import 'package:bluetooth_app/clean/features/admin/presentation/widgets/characteristics_widget.dart';
import 'package:bluetooth_app/clean/features/admin/presentation/widgets/selected_category_widget.dart';
import 'package:bluetooth_app/clean/features/printing/Presentation/widgets/product_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
      appBar: PrimaryAppBar(
        buttons: [
          IconButton(
              onPressed: () {
                setState(() {
                  showTools = !showTools;
                });
              },
              icon: const Icon(Icons.add)),
        ],
      ),
      body: CustomScrollView(
        slivers: [
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
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  SelectedCategoryWidget(controller: categoryController),
                  AllowFreeMarkingWidget(allowFreeMarking: checkAllowFreeTime)
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
                  alignment: Alignment.center,
                  toPage: const SettingsScreen(),
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
                      return ProductWidget(
                        product: p,
                      );
                    }).toList(),
                    
                  );
                }

                if (state is ItemOperationFailed<Product>) {
                  return Center(child: Text(state.error),
                  );
                }

                return SizedBox.shrink();
              },
            )),
          )
        ],
      ),
    );
  }
}
