import 'package:bluetooth_app/clean/config/theme/colors.dart';
import 'package:bluetooth_app/clean/config/theme/text_styles.dart';
import 'package:bluetooth_app/clean/core/Domain/entities/marking/product.dart';
import 'package:bluetooth_app/clean/core/Domain/entities/marking/template.dart';
import 'package:bluetooth_app/clean/features/printing/Presentation/sheets/template_print_sheet.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class TemplateWidget extends StatefulWidget {
  final Template template;
  final Function(Template) onEdit;
  final Function(Template) onDelete;
  const TemplateWidget(
      {super.key,
      required this.template,
      required this.onEdit,
      required this.onDelete});

  @override
  State<TemplateWidget> createState() => _TemplateWidgetState();
}

class _TemplateWidgetState extends State<TemplateWidget> {
  void _onEdit() {
    widget.onEdit(widget.template);
  }

  void _onDelete() {
    widget.onDelete(widget.template);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
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
              
              Flexible(
                flex: 7,
                child: Text(widget.template.title, style: AppTextStyles.labelMedium18)),
              Flexible(
                flex: 3,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                        iconSize: 20,
                        style: const ButtonStyle(
                            padding: WidgetStatePropertyAll(EdgeInsets.zero)),
                        onPressed: () {
                          showBarModalBottomSheet(
                              context: context,
                              isDismissible: false,
                              enableDrag: false,
                              builder: (context) =>
                                  TemplatePrintSheet(template: widget.template));
                        },
                        icon: const Icon(
                          Icons.print,
                          color: AppColors.black,
                        )),
                    PopupMenuButton(
                      position: PopupMenuPosition.under,
                      color: AppColors.white,
                      itemBuilder: (context) {
                        return [
                          PopupMenuItem(
                            child: const Text(
                              'Изменить данные',
                              style: AppTextStyles.bodyMedium16,
                            ),
                            onTap: () => _onEdit(),
                          ),
                          PopupMenuItem(
                              child: const Text(
                                'Удалить',
                                style: AppTextStyles.bodyMedium16,
                              ),
                              onTap: () => _onDelete()),
                        ];
                      },
                    )
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: Wrap(
              spacing: 5,
              runSpacing: 5,
              children: List.generate(widget.template.listProducts.length,
                  (chipIndex) {
                Product product =
                    widget.template.listProducts[chipIndex].product;

                return Chip(
                    backgroundColor: Color(
                        product.backgroundColor ?? AppColors.surface.value),
                    padding: const EdgeInsets.all(2.5),
                    labelPadding: const EdgeInsets.all(0),
                    label: Text(
                      widget.template.listProducts[chipIndex].product.title,
                      style: AppTextStyles.bodyMedium16.copyWith(fontSize: 12),
                    ));
              }),
            ),
          )
        ],
      ),
    );
  }
}
