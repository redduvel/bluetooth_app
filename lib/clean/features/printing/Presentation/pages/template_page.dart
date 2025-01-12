import 'package:bluetooth_app/clean/config/theme/colors.dart';
import 'package:bluetooth_app/clean/config/theme/text_styles.dart';
import 'package:bluetooth_app/clean/core/Domain/bloc/db.bloc.dart';
import 'package:bluetooth_app/clean/core/Domain/entities/marking/product.dart';
import 'package:bluetooth_app/clean/core/Domain/entities/marking/template.dart';
import 'package:bluetooth_app/clean/core/Presentation/widgets/primary_button.dart';
import 'package:bluetooth_app/clean/core/Presentation/widgets/primary_textfield.dart';
import 'package:bluetooth_app/clean/features/printing/Presentation/bloc/multi_select_product_cubit.dart';
import 'package:bluetooth_app/clean/features/printing/Presentation/widgets/multi_select_product_widget.dart';
import 'package:bluetooth_app/clean/features/printing/Presentation/widgets/template_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TemplatePage extends StatefulWidget {
  const TemplatePage({super.key});

  @override
  State<TemplatePage> createState() => _TemplatePageState();
}

class _TemplatePageState extends State<TemplatePage> {
  Template? editTemplate;

  late DBBloc<Template> bloc;
  late TextEditingController _nameController;
  late MultiProductCubit _productsController;

  bool _showTools = false;

  bool _isValid() {
    return _nameController.text.isNotEmpty &&
        _productsController.state.toEntries().isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    bloc = context.read<DBBloc<Template>>();
    _nameController = TextEditingController();
    _productsController = MultiProductCubit();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          //if (Platform.isIOS || Platform.isAndroid || Platform.isWindows)
          SliverAppBar(
            backgroundColor: AppColors.white,
            title: Text(
              'Шаблоны',
              style: AppTextStyles.labelMedium18.copyWith(fontSize: 24),
            ),
            centerTitle: false,
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                  onPressed: () {
                    setState(() {
                      _showTools = !_showTools;
                    });
                  },
                  icon:
                      Icon(_showTools ? Icons.keyboard_arrow_down : Icons.add)),
            ],
          ),
          if (_showTools)
            SliverToBoxAdapter(
              child: BlocBuilder<DBBloc<Product>, DBState<Product>>(
                builder: (context, productState) {
                  if (productState is ItemsLoaded<Product>) {
                    return Column(
                      children: [
                        PrimaryTextField(
                          controller: _nameController,
                          width: double.infinity,
                          margin: const EdgeInsets.symmetric(horizontal: 15),
                          hintText: 'Название',
                        ),
                        BlocProvider.value(
                          value: _productsController,
                          child: MultiProductSelectionWidget(
                            controller: _productsController,
                            products: productState.items,
                          ),
                        ),
                        PrimaryButtonIcon(
                            text: editTemplate != null ? "Сохранить" : "Добавить",
                            selected: true,
                            alignment: Alignment.center,
                            icon: editTemplate != null
                                ? Icons.save
                                : Icons.add,
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            onPressed: () => createTemplate())
                      ],
                    );
                  }
                  return const SizedBox.shrink(
                      child: CircularProgressIndicator());
                },
              ),
            ),
        ],
        body: Padding(
          padding: const EdgeInsets.all(15),
          child: BlocBuilder<DBBloc<Template>, DBState<Template>>(
            builder: (context, templateState) {
              return switch (templateState) {
                ItemsLoaded<Template>() => ListView.builder(
                    itemCount: templateState.items.length,
                    itemBuilder: (context, index) => TemplateWidget(
                      template: templateState.items[index],
                      onDelete: (template) {
                        bloc.add(DeleteItem<Template>(template.id));
                      },
                      onEdit: (template) => editTemplateFunc(template),
                    ),
                  ),
                _ => const SizedBox.shrink(child: CupertinoActivityIndicator()),
              };
            },
          ),
        ),
      ),
    );
  }

  void editTemplateFunc(Template template) {
    setState(() {
      _showTools = !_showTools;

      editTemplate = template;

      _nameController.text = template.title;
      _productsController.fromTemplateEntries(template.listProducts);
    });
  }

  void createTemplate() {
    if (_isValid()) {
      if (editTemplate != null) {
        final updatedTemplate = editTemplate!.copyWith(
            title: _nameController.text,
            listProducts: _productsController.state.toEntries());
        bloc.add(UpdateItem<Template>(updatedTemplate));
      } else {
        final newTemplate = Template(
            title: _nameController.text,
            listProducts: _productsController.state.toEntries());
        bloc.add(
          AddItem<Template>(
            newTemplate,
          ),
        );
      }

      setState(() {
        _showTools = false;
        editTemplate = null;
        _nameController.clear();
        _productsController.clear();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
        'Необходимо заполнить все поля',
        style: AppTextStyles.bodyMedium16.copyWith(color: AppColors.white),
      )));
    }
  }
}
