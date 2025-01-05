import 'package:auto_route/auto_route.dart';
import 'package:bluetooth_app/clean/config/theme/colors.dart';
import 'package:bluetooth_app/clean/config/theme/text_styles.dart';
import 'package:bluetooth_app/clean/core/Domain/bloc/db.bloc.dart';
import 'package:bluetooth_app/clean/core/Domain/bloc/user.cubit.dart';
import 'package:bluetooth_app/clean/core/Domain/entities/marking/product.dart';

import 'package:bluetooth_app/clean/features/printing/Presentation/sheets/normal_print_sheet.dart';
import 'package:bluetooth_app/clean/features/printing/Presentation/sheets/schelude_print_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:universal_io/io.dart';

class ProductWidget extends StatefulWidget {
  final Product product;
  final DBBloc<Product> bloc;

  const ProductWidget({super.key, required this.product, required this.bloc});

  @override
  State<ProductWidget> createState() => _ProductWidgetState();
}

class _ProductWidgetState extends State<ProductWidget> {
  bool saveMarking = false;

  Color backgroundColor = AppColors.surface;

  int count = 1;
  TextEditingController customPrintController = TextEditingController();
  late TextEditingController controller;

  DateTime customEndDate = DateTime.now();
  DateTime startDate = DateTime.now();
  DateTime adjustmentDateTime = DateTime.now();
  int selectedCharacteristic = 0;

  @override
  void initState() {
    controller = TextEditingController(text: '$count');

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: (Platform.isMacOS || Platform.isWindows)
          ? 200
          : (MediaQuery.of(context).size.width - 20 - 16) / 2,
      height: 200,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
          color: Color(widget.product.backgroundColor ??
              AppColors.secondaryButton.value),
          borderRadius: BorderRadius.circular(8)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 100,
                    child: Text(
                      widget.product.title,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.labelMedium18,
                    ),
                  ),
                  Text(
                    widget.product.category.name,
                    style: AppTextStyles.labelSmall12,
                  )
                ],
              ),
              PopupMenuButton(
                position: PopupMenuPosition.under,
                color: AppColors.white,
                itemBuilder: (context) {
                  return [
                    PopupMenuItem(
                        child: const Text(
                          'Изменить оформление',
                          style: AppTextStyles.bodyMedium16,
                        ),
                        onTap: () => showEditColorDialog(context)),
                    if (context.read<UserCubit>().state ==
                        CurrentUser.admin) ...[
                      const PopupMenuItem(
                          child: Text(
                        'Изменить данные',
                        style: AppTextStyles.bodyMedium16,
                      )),
                      PopupMenuItem(
                        child: Text(
                          widget.product.isHide
                              ? 'Убрать из скрытых'
                              : 'Скрыть',
                          style: AppTextStyles.bodyMedium16,
                        ),
                        onTap: () {
                          context
                              .read<DBBloc<Product>>()
                              .add(UpdateItem<Product>(
                                widget.product
                                    .copyWith(isHide: !widget.product.isHide),
                              ));
                        },
                      ),
                      PopupMenuItem(
                        child: const Text('Удалить',
                            style: AppTextStyles.bodyMedium16),
                        onTap: () {
                          context
                              .read<DBBloc<Product>>()
                              .add(DeleteItem<Product>(widget.product.id));
                        },
                      ),
                    ]
                  ];
                },
              )
            ],
          ),
          Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: widget.product.characteristics.map((c) {
                return Text(
                  c.toString(),
                  style: AppTextStyles.bodyMedium16,
                );
              }).toList()),
          Row(
            children: [
              CupertinoButton(
                  minSize: 30,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child:
                      const Icon(CupertinoIcons.printer, color: AppColors.text),
                  onPressed: () => _showPrintBottomSheet(context)),
              const Spacer(),
              CupertinoButton(
                  minSize: 30,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: const Icon(
                    CupertinoIcons.clock,
                    color: AppColors.text,
                  ),
                  onPressed: () => _showScheduleBottomSheet(context))
            ],
          )
        ],
      ),
    );
  }

  Future<dynamic> showEditColorDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) => Dialog(
              backgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4)),
              child: Container(
                padding: const EdgeInsets.all(25),
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children:
                      List.generate(AppColors.backgroundColors.length, (index) {
                    Color backgroundColor = AppColors.backgroundColors[index];

                    return InkWell(
                      onTap: () {
                        widget.product.setColor(backgroundColor.value);
                        widget.bloc.add(UpdateItem(widget.product
                            .copyWith(backgroundColor: backgroundColor.value)));
                        context.router.popForced();
                      },
                      child: Card(
                        color: backgroundColor,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: backgroundColor,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ));
  }

  void _showPrintBottomSheet(BuildContext context) {

    showBarModalBottomSheet(
      context: context,
            backgroundColor: AppColors.onSurface,
      enableDrag: false,
      builder: (context) {
        return NormalPrintSheet(product: widget.product);
      },
    );
  }

  // для печати с отложенной датой
  void _showScheduleBottomSheet(BuildContext context) {
    showBarModalBottomSheet(
      context: context,
      backgroundColor: AppColors.onSurface,
      enableDrag: false,
      builder: (context) {
        return ScheludePrintDialog(product: widget.product);
      },
    );
  }
}
