import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:bluetooth_app/clean/config/theme/colors.dart';
import 'package:bluetooth_app/clean/config/theme/text_styles.dart';
import 'package:bluetooth_app/clean/core/Domain/entities/marking/product.dart';
import 'package:bluetooth_app/clean/core/Presentation/widgets/primary_button.dart';
import 'package:bluetooth_app/clean/features/printing/Presentation/bloc/multi_select_product_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MultiProductSelectionWidget extends StatefulWidget {
  final MultiProductCubit controller;
  final List<Product> products;

  const MultiProductSelectionWidget(
      {super.key, required this.controller, required this.products});

  @override
  _MultiProductSelectionWidgetState createState() =>
      _MultiProductSelectionWidgetState();
}

class _MultiProductSelectionWidgetState
    extends State<MultiProductSelectionWidget> {


  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MultiProductCubit, MultiProductState>(
      builder: (context, state) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dropdown для добавления продуктов
            CustomDropdown<Product>.search(
                hintBuilder: (context, hint, enabled) => Text(
                      'Выберете продукты',
                      style: AppTextStyles.bodyMedium16
                          .copyWith(color: AppColors.text),
                    ),
                listItemBuilder: (context, item, isSelected, onItemSelect) =>
                    Text(
                      item.title,
                      style: AppTextStyles.bodyMedium16
                          .copyWith(color: AppColors.black),
                    ),
                decoration: CustomDropdownDecoration(
                    closedBorder: Border.all(color: AppColors.secondaryButton),
                    closedBorderRadius: BorderRadius.circular(4),
                    expandedBorder: Border.all(color: AppColors.secondaryText),
                    expandedBorderRadius: BorderRadius.circular(4),
                    expandedFillColor: AppColors.inputSurface,
                    closedFillColor: AppColors.inputSurface,
                    searchFieldDecoration: const SearchFieldDecoration(
                        hintStyle: AppTextStyles.bodySmall12,
                        textStyle: AppTextStyles.bodySmall12,
                        border: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: AppColors.secondaryButton)),
                        focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: AppColors.secondaryText)),
                        fillColor: AppColors.surface)),
                items: widget.products
                    .where((product) => !state.selectedProducts.contains(product))
                    .toList(),
                searchHintText: 'Поиск продуктов...',
                noResultFoundText: 'Нет доступных продуктов.',
                excludeSelected: false,
                headerBuilder: (context, selectedItem, enabled) => Text(
                      'Выберете продукты',
                      style: AppTextStyles.bodyMedium16
                          .copyWith(color: AppColors.text),
                    ),
                onChanged: (value) {
                  if (value != null) {
                    widget.controller.addProduct(value);
                  }
                }),
      
            const SizedBox(height: 16),
            // list selected products
            if (state.selectedProducts.isNotEmpty)
              GridView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 1 / 1.2),
                children: state.selectedProducts.map((product) {
                  return Container(
                    decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.title,
                              style: AppTextStyles.bodyMedium16,
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            CustomDropdown(
                              hintText: 'Выберете характеристику',
                              items: product.characteristics,
                              initialItem: state.selectedCharacteristics.isNotEmpty ? state.selectedCharacteristics[product] : null,
                              closedHeaderPadding: const EdgeInsets.all(8),
                              onChanged: (value) {
                                widget.controller.updateCharacteristic(product, value);
                                                              },
                              decoration: CustomDropdownDecoration(
                                hintStyle: AppTextStyles.bodyMedium16,
                                closedBorder:
                                    Border.all(color: AppColors.secondaryButton),
                                closedBorderRadius: BorderRadius.circular(4),
                                expandedBorder:
                                    Border.all(color: AppColors.secondaryText),
                                expandedBorderRadius: BorderRadius.circular(4),
                                expandedFillColor: AppColors.inputSurface,
                                closedFillColor: AppColors.inputSurface,
                              ),
                            ),
                            TextFormField(
                                initialValue: state.productQuantities[product]?.toString() ?? '1',
                                keyboardType: TextInputType.number,
                                
                                decoration: const InputDecoration(
                                  hintText: 'Количество',
                                  fillColor: AppColors.surface,
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: AppColors.secondaryButton
                                    )
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: AppColors.secondaryText
                                    )
                                  ),
                                  isDense: true,
                                ),
                                onChanged: (value) {
                                  final int? quantity = int.tryParse(value);
                                  if (quantity != null && quantity > 0) {
                                    widget.controller.updateQuantity(product, quantity);
                                    
                                  }
                                },
                              ),
                          ],
                        ),
                        PrimaryButtonIcon(
                            onPressed: () {
                              widget.controller.removeProduct(product);
                              
                            },
                            width: double.infinity,
                            type: ButtonType.delete,
                            icon: Icons.delete,
                            text: 'Удалить'),
                      ],
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}
