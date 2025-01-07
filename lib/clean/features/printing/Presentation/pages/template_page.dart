import 'package:bluetooth_app/clean/config/theme/colors.dart';
import 'package:bluetooth_app/clean/config/theme/text_styles.dart';
import 'package:bluetooth_app/clean/core/Domain/bloc/db.bloc.dart';
import 'package:bluetooth_app/clean/core/Domain/entities/marking/product.dart';
import 'package:bluetooth_app/clean/core/Domain/entities/marking/template.dart';
import 'package:bluetooth_app/clean/core/Presentation/widgets/primary_button.dart';
import 'package:bluetooth_app/clean/core/Presentation/widgets/primary_textfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:select2dot1/select2dot1.dart';

class TemplatePage extends StatefulWidget {
  const TemplatePage({super.key});

  @override
  State<TemplatePage> createState() => _TemplatePageState();
}

class _TemplatePageState extends State<TemplatePage> {
  late DBBloc<Template> bloc;
  late TextEditingController _nameController;

  bool showTools = false;
  List<Product> selectBooks = [];

  bool _isValid() {
    return _nameController.text.isNotEmpty && selectBooks.isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    bloc = context.read<DBBloc<Template>>();
    _nameController = TextEditingController();
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
                      showTools = !showTools;
                    });
                  },
                  icon: const Icon(Icons.add)),
            ],
          ),
          if (showTools)
            SliverToBoxAdapter(
              child: BlocBuilder<DBBloc<Product>, DBState<Product>>(
                builder: (context, productState) {
                  return switch (productState) {
                    ItemsLoaded<Product>() => Column(
                        children: [
                          PrimaryTextField(
                            controller: _nameController,
                            width: double.infinity,
                            margin: const EdgeInsets.symmetric(horizontal: 15),
                            hintText: 'Название',
                          ),
                          Padding(
                            padding: const EdgeInsets.all(15),
                            child: Select2dot1(
                              pillboxSettings: PillboxSettings(
                                  defaultDecoration: BoxDecoration(
                                      border:
                                          Border.all(color: AppColors.black),
                                      borderRadius: BorderRadius.circular(5)),
                                  activeDecoration: BoxDecoration(
                                      border: Border.all(
                                        color: AppColors.primary,
                                      ),
                                      borderRadius: BorderRadius.circular(5))),
                              doneButtonModalSettings: DoneButtonModalSettings(
                                  title: 'Выбрать',
                                  iconColor: AppColors.primary,
                                  buttonDecoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius: BorderRadius.circular(5))),
                              isSearchable: true,
                              searchBarModalSettings:
                                  const SearchBarModalSettings(
                                textFieldStyle: AppTextStyles.bodySmall12,
                              ),
                              searchEmptyInfoModalSettings:
                                  const SearchEmptyInfoModalSettings(
                                      text: 'Нет результатов'),
                              onChanged: (value) {
                                WidgetsBinding.instance
                                    .addPostFrameCallback((_) {
                                  setState(() {
                                    selectBooks = value
                                        .map((v) => v.value as Product)
                                        .toList();
                                  });
                                });
                              },
                              dropdownModalSettings:
                                  const DropdownModalSettings(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(5),
                                            topRight: Radius.circular(5)),
                                      ),
                                      backgroundColor: AppColors.onSurface),
                              titleModalSettings: const TitleModalSettings(
                                  title: 'Выберете продукты',
                                  titleTextStyle: AppTextStyles.labelMedium18),
                              selectDataController: SelectDataController(
                                data: [
                                  SingleCategoryModel(
                                    singleItemCategoryList: productState.items
                                        .map((p) => SingleItemCategoryModel(
                                            nameSingleItem: p.title, value: p))
                                        .toList(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          PrimaryButtonIcon(
                              text: "Добавить",
                              selected: true,
                              alignment: Alignment.center,
                              icon: Icons.add,
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              onPressed: () => createTemplate())
                        ],
                      ),
                    _ =>
                      const SizedBox.shrink(child: CircularProgressIndicator()),
                  };
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
                    itemBuilder: (context, index) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: AppColors.secondaryButton),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(templateState.items[index].title,
                                  style: AppTextStyles.labelMedium18),
                              Row(
                                children: [
                                  IconButton(
                                      iconSize: 20,
                                      style: const ButtonStyle(
                                          padding: WidgetStatePropertyAll(
                                              EdgeInsets.zero)),
                                      onPressed: () {},
                                      icon: const Icon(
                                        Icons.print,
                                        color: AppColors.black,
                                      )),
                                  PopupMenuButton(
                                    position: PopupMenuPosition.under,
                                    color: AppColors.white,
                                    itemBuilder: (context) {
                                      return [
                                        const PopupMenuItem(
                                            child: Text(
                                          'Изменить данные',
                                          style: AppTextStyles.bodyMedium16,
                                        )),
                                        // const PopupMenuItem(
                                        //     child: Text(
                                        //   'Изменить оформление',
                                        //   style: AppTextStyles.bodyMedium16,
                                        // )),
                                        PopupMenuItem(
                                            child: const Text(
                                              'Удалить',
                                              style: AppTextStyles.bodyMedium16,
                                            ),
                                            onTap: () => bloc.add(
                                                DeleteItem<Template>(
                                                    templateState
                                                        .items[index].id))),
                                      ];
                                    },
                                  )
                                ],
                              )
                            ],
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: Wrap(
                              spacing: 5,
                              children: List.generate(
                                  templateState.items[index].listProducts
                                      .length, (chipIndex) {
                                        Product product = templateState.items[index].listProducts[chipIndex];

                                return Chip(
                                  backgroundColor: Color(product.backgroundColor ?? AppColors.surface.value),
                                    padding: const EdgeInsets.all(2.5),
                                    labelPadding: const EdgeInsets.all(0),
                                    label: Text(
                                      templateState.items[index]
                                          .listProducts[chipIndex].title,
                                      style: AppTextStyles.bodyMedium16
                                          .copyWith(fontSize: 12),
                                    ));
                              }),
                            ),
                          )
                        ],
                      ),
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

  void createTemplate() {
    if (_isValid()) {
      bloc.add(
        AddItem(
          Template(title: _nameController.text, listProducts: selectBooks),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
        'Необходимо заполнить все поля',
        style: AppTextStyles.bodyMedium16.copyWith(color: AppColors.white),
      )));
    }
  }
}
