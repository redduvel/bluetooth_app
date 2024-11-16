import 'package:bluetooth_app/clean/config/theme/colors.dart';
import 'package:bluetooth_app/clean/config/theme/text_styles.dart';
import 'package:bluetooth_app/clean/core/Domain/bloc/db.bloc.dart';
import 'package:bluetooth_app/clean/core/Domain/entities/marking/product.dart';
import 'package:bluetooth_app/clean/core/Domain/entities/marking/template.dart';
import 'package:bluetooth_app/clean/core/Presentation/widgets/primary_appBar.dart';
import 'package:bluetooth_app/clean/core/Presentation/widgets/primary_button.dart';
import 'package:bluetooth_app/clean/core/Presentation/widgets/primary_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:multi_dropdown/multi_dropdown.dart';
import 'package:universal_io/io.dart';

class TemplatePage extends StatefulWidget {
  const TemplatePage({super.key});

  @override
  State<TemplatePage> createState() => _TemplatePageState();
}

class _TemplatePageState extends State<TemplatePage> {
  TextEditingController nameController = TextEditingController();
  MultiSelectController<Product> productsController =
      MultiSelectController<Product>();
  List<String> selectBooks = [];

  bool showTools = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.white,
        appBar: (Platform.isMacOS || Platform.isWindows)
            ? PrimaryAppBar(
                title: 'Управление шаблонами',
                titleStyle: AppTextStyles.labelMedium18.copyWith(fontSize: 24),
                onSearch: (query) {
                  context.read<DBBloc<Product>>().add(Search<Product>(query));
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
                ],
              )
            : null,
        body: CustomScrollView(
          slivers: [
            if (Platform.isIOS || Platform.isAndroid)
              SliverAppBar(
                backgroundColor: AppColors.white,
                title: Text(
                  'Панель шаблонов',
                  style: AppTextStyles.labelMedium18.copyWith(fontSize: 24),
                ),
                centerTitle: false,
                automaticallyImplyLeading: false,
                actions: [
                  IconButton(
                      onPressed: () => setState(() {
                            showTools = !showTools;
                          }),
                      icon: !showTools ? const Icon(Icons.add) : const Icon(Icons.arrow_drop_down)),
                ],
              ),
            if (showTools)
              SliverPadding(
                  padding: const EdgeInsets.all(8),
                  sliver: SliverList(
                      delegate: SliverChildListDelegate([
                    PrimaryTextField(
                        controller: nameController,
                        width: 500,
                        hintText: 'Название'),
                    Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: BlocBuilder<DBBloc<Product>, DBState<Product>>(
                          builder: (context, state) {
                            if (state is ItemsLoaded<Product>) {
                              return MultiDropdown<Product>(
                                fieldDecoration: FieldDecoration(
                                    hintText: 'Выбор продуктов',
                                    hintStyle: AppTextStyles.bodyMedium16
                                        .copyWith(
                                            color: AppColors.secondaryText),
                                    borderRadius: 4,
                                    backgroundColor: AppColors.inputSurface,
                                    border: const OutlineInputBorder(
                                        borderSide: BorderSide(
                                      color: AppColors.secondaryButton,
                                    )),
                                    focusedBorder: const OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: AppColors.secondaryText))),
                                dropdownDecoration: DropdownDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                dropdownItemDecoration:
                                    const DropdownItemDecoration(
                                        selectedTextColor:
                                            AppColors.greenOnSurface,
                                        selectedBackgroundColor:
                                            AppColors.greenSurface,
                                        disabledTextColor:
                                            AppColors.secondaryText,
                                        disabledBackgroundColor:
                                            AppColors.secondaryButton),
                                searchEnabled: true,
                                searchDecoration: SearchFieldDecoration(
                                  hintText: 'Поиск по названию',
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(4),
                                      borderSide: const BorderSide(
                                          color: AppColors.secondaryButton)),
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(4),
                                      borderSide: const BorderSide(
                                          color: AppColors.secondaryText)),
                                ),
                                items: state.items.map((a) {
                                  return DropdownItem<Product>(
                                      label: a.title, value: a);
                                }).toList(),
                                controller: productsController,
                              );
                            }

                            if (state is ItemOperationFailed) {
                              return 
                              Container(
                                decoration: BoxDecoration(
                                  color: AppColors.inputSurface,
                                  border: Border.all(
                                    color: AppColors.secondaryButton,
                                    
                                  ),
                                  borderRadius: BorderRadius.circular(4)
                                ),
                                alignment: Alignment.center,
                                child: const Text('Ошибка загрузки данных', style: AppTextStyles.bodyMedium16,),
                              );
                            }

                            return Container(
                                decoration: BoxDecoration(
                                  color: AppColors.inputSurface,
                                  border: Border.all(
                                    color: AppColors.secondaryButton,
                                    
                                  ),
                                  borderRadius: BorderRadius.circular(4)
                                ),
                                alignment: Alignment.center,
                                child: const Text('Идет загрузка данных...', style: AppTextStyles.bodyMedium16,),
                              );
                          },
                        )),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: PrimaryButtonIcon(
                        text: 'Добавить',
                        icon: Icons.add,
                        selected: true,
                        onPressed: () {
                          context.read<DBBloc<Template>>().add(
                              AddItem<Template>(Template(
                                  name: nameController.text,
                                  products: productsController.selectedItems
                                      .map((v) => v.value)
                                      .toList())));
                        },
                      ),
                    )
                  ]))),
            SliverPadding(
              padding: const EdgeInsets.all(15),
              sliver: BlocBuilder<DBBloc<Template>, DBState<Template>>(
                builder: (context, state) {
                  if (state is ItemsLoaded<Template>) {
                    return SliverList(
                        delegate: SliverChildListDelegate(state.items.map((t) {
                      return Container(
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: AppColors.blueOnSurface),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  t.name,
                                  style: AppTextStyles.labelMedium18
                                      .copyWith(color: AppColors.surface),
                                ),
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
                                          color: AppColors.white,
                                        )),
                                    PopupMenuButton(
                                      position: PopupMenuPosition.under,
                                      iconColor: AppColors.white,
                                      color: AppColors.white,
                                      itemBuilder: (context) {
                                        return [
                                          const PopupMenuItem(
                                              child: Text(
                                            'Изменить данные',
                                            style: AppTextStyles.bodyMedium16,
                                          )),
                                          const PopupMenuItem(
                                              child: Text(
                                            'Удалить',
                                            style: AppTextStyles.bodyMedium16,
                                          )),
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
                                children: 
                                  t.products.map((p) {
                                   return Chip(
                                      padding: const EdgeInsets.all(2.5),
                                      labelPadding: const EdgeInsets.all(0),
                                      backgroundColor: AppColors.inputSurface,
                                      shape: RoundedRectangleBorder(
                                        side: const BorderSide(color: AppColors.secondaryText),
                                        borderRadius: BorderRadius.circular(10)
                                      ),
                                      label: Text(
                                        p.title,
                                        style: AppTextStyles.bodyMedium16
                                            .copyWith(fontSize: 12),
                                      ));
                                  }).toList()
                                
                              ),
                            )
                          ],
                        ),
                      );
                    }).toList()));
                  }

                  if (state is ItemOperationFailed<Template>) {
                    return SliverToBoxAdapter(
                      child: Center(
                        child: Text(state.error),
                      ),
                    );
                  }

                  return const SliverToBoxAdapter(child: SizedBox.shrink());
                },
              ),
            )
          ],
        ));
  }
}
