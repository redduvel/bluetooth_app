import 'package:bluetooth_app/clean/config/theme/colors.dart';
import 'package:bluetooth_app/clean/config/theme/text_styles.dart';
import 'package:bluetooth_app/clean/core/Presentation/widgets/primary_textfield.dart';
import 'package:flutter/material.dart';
import 'package:select2dot1/select2dot1.dart';
import 'package:universal_io/io.dart';

class TemplatePage extends StatefulWidget {
  const TemplatePage({super.key});

  @override
  State<TemplatePage> createState() => _TemplatePageState();
}

class _TemplatePageState extends State<TemplatePage> {
  List<String> selectBooks = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.white,
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
                  IconButton(onPressed: () {}, icon: const Icon(Icons.add)),
                  IconButton(onPressed: () {}, icon: const Icon(Icons.edit))
                ],
              ),
            SliverToBoxAdapter(
                child: Column(
              children: [
                PrimaryTextField(
                    controller: TextEditingController(),
                    width: 800,
                    margin: const EdgeInsets.symmetric(horizontal: 15),
                    hintText: 'Название'),
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: Select2dot1(
                      pillboxSettings: PillboxSettings(
                          defaultDecoration: BoxDecoration(
                              border: Border.all(color: AppColors.black),
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
                      searchBarModalSettings: const SearchBarModalSettings(
                        textFieldStyle: AppTextStyles.bodySmall12,
                      ),
                      searchEmptyInfoModalSettings:
                          const SearchEmptyInfoModalSettings(
                              text: 'Нет результатов'),
                      onChanged: (value) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          setState(() {
                            selectBooks =
                                value.map((v) => v.value as String).toList();
                          });
                        });
                      },
                      dropdownModalSettings: const DropdownModalSettings(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(5),
                                topRight: Radius.circular(5)),
                          ),
                          backgroundColor: AppColors.onSurface),
                      titleModalSettings: const TitleModalSettings(
                          title: 'Выберете продукты',
                          titleTextStyle: AppTextStyles.labelMedium18),
                      selectDataController: SelectDataController(data: [
                        const SingleCategoryModel(singleItemCategoryList: [
                          SingleItemCategoryModel(
                              nameSingleItem: 'Продукт 1', value: 'Product 1'),
                          SingleItemCategoryModel(
                              nameSingleItem: 'Продукт 2', value: 'Product 2'),
                          SingleItemCategoryModel(
                              nameSingleItem: 'Продукт 3', value: 'Product 3'),
                          SingleItemCategoryModel(
                              nameSingleItem: 'Продукт 4', value: 'Product 4'),
                          SingleItemCategoryModel(
                              nameSingleItem: 'Продукт 5', value: 'Product 5'),
                          SingleItemCategoryModel(
                              nameSingleItem: 'Продукт 6', value: 'Product 6'),
                          SingleItemCategoryModel(
                              nameSingleItem: 'Продукт 7', value: 'Product 7'),
                        ])
                      ])),
                )
              ],
            )),
            SliverPadding(
              padding: const EdgeInsets.all(15),
              sliver: SliverList(
                  delegate: SliverChildListDelegate([
                Container(
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
                            'Название шаблона',
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
                                      'Изменить оформление',
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
                          children: List.generate(10, (index) {
                            return Chip(
                                padding: const EdgeInsets.all(2.5),
                                labelPadding: const EdgeInsets.all(0),
                                label: Text(
                                  'Продукт 1',
                                  style: AppTextStyles.bodyMedium16
                                      .copyWith(fontSize: 12),
                                ));
                          }),
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: AppColors.blueOnSurface),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Название шаблона',
                        style: AppTextStyles.labelMedium18
                            .copyWith(color: AppColors.surface),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Wrap(
                        spacing: 5,
                        children: List.generate(4, (index) {
                          return const Chip(label: Text('Продукт 1'));
                        }),
                      )
                    ],
                  ),
                )
              ])),
            )
          ],
        ));
  }
}
