import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:bluetooth_app/clean/config/theme/colors.dart';
import 'package:bluetooth_app/clean/config/theme/text_styles.dart';
import 'package:bluetooth_app/clean/core/Domain/bloc/db.bloc.dart';
import 'package:bluetooth_app/clean/core/Domain/entities/marking/template.dart';
import 'package:bluetooth_app/clean/core/Domain/entities/marking/user.dart';
import 'package:bluetooth_app/clean/core/Domain/entities/marking_db/marking.dart';
import 'package:bluetooth_app/clean/core/Presentation/widgets/primary_button.dart';
import 'package:bluetooth_app/clean/features/printing/Domain/usecase/printing_usecase.dart';
import 'package:bluetooth_app/clean/features/printing/Presentation/bloc/printer.event.dart';
import 'package:bluetooth_app/clean/features/printing/Presentation/sheets/date_time_picker_sheet.dart';
import 'package:bluetooth_app/clean/features/printing/Presentation/widgets/label_template_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:bluetooth_app/clean/features/printing/Presentation/bloc/printer.bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class TemplatePrintSheet extends StatefulWidget {
  final Template template;
  const TemplatePrintSheet({super.key, required this.template});

  @override
  State<TemplatePrintSheet> createState() => _TemplatePrintSheetState();
}

class _TemplatePrintSheetState extends State<TemplatePrintSheet> {
  bool saveMarking = false;
  bool customDate = false;
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: CustomScrollView(
        shrinkWrap: (Platform.isIOS || Platform.isAndroid),
        slivers: [
          SliverToBoxAdapter(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  flex: 7,
                  child: Text(
                    'Печать шаблона: ${widget.template.title}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.labelMedium18
                        .copyWith(color: AppColors.black),
                  ),
                ),
                Flexible(
                  flex: 3,
                  child: CupertinoButton(
                      color: AppColors.primary,
                      minSize: 1,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Text(
                        'Готово',
                        style: AppTextStyles.bodyMedium16
                            .copyWith(color: AppColors.text),
                      ),
                      onPressed: () => context.router.popForced()),
                )
              ],
            ),
          ),
          const SliverToBoxAdapter(
            child: Divider(),
          ),
          SliverToBoxAdapter(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  flex: 1,
                  child: PrimaryButtonIcon(
                    text: 'Текущая дата',
                    icon: Icons.watch_later_outlined,
                    width: double.infinity,
                    onPressed: () {
                      setState(() {
                        customDate = false;
                        startDate = DateTime.now();
                        
                      });
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Flexible(
                  flex: 1,
                  child: PrimaryButtonIcon(
                    text: customDate
                        ? DateFormat('dd.MM.yyyy HH:mm').format(startDate)
                        : 'Выбрать дату',
                    icon: Icons.calendar_month,
                    width: double.infinity,
                    onPressed: () {
                      setState(() {
                        customDate = true;
                      });
                      showDialog(
                          context: context,
                          builder: (context) => DateTimePickerSheet(
                              initialDateTime: startDate,
                              onDateTimeChanged: (date) {
                                setState(() {
                                  startDate = date;
                                  
                                });
                              }));
                    },
                  ),
                ),
              ],
            ),
          ),
          const SliverToBoxAdapter(
            child: Divider(),
          ),
          if (Platform.isMacOS || Platform.isWindows)
            SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: double.infinity,
                  ),
                  child: Wrap(
                    spacing: 5,
                    runSpacing: 5,
                    alignment: WrapAlignment.center,
                    children: widget.template.listProducts
                        .map((entry) {
                                            if (entry.characteristic != null) {
                    endDate = PrintingUsecase.setAdjustmentTime(
                        startDate, entry.characteristic!);
                  }

                          return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                LabelTemplateWidget(
                                  product: entry.product,
                                  customDate: customDate,
                                  startDate: startDate,
                                  customEndDate: endDate,
                                  selectedCharacteristic: entry.characteristic,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Количество: ${entry.count}',
                                  style: AppTextStyles.bodyMedium16,
                                ),
                                Text(
                                  'Характеристика: ${entry.characteristic?.name ?? 'НЕТ'}',
                                  style: AppTextStyles.bodyMedium16,
                                ),
                              ],
                            );
                        })
                        .toList(),
                  ),
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final entry = widget.template.listProducts[index];
                  if (entry.characteristic != null) {
                    endDate = PrintingUsecase.setAdjustmentTime(
                        startDate, entry.characteristic!);
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 8),
                      LabelTemplateWidget(
                        product: entry.product,
                        customDate: customDate,
                        startDate: startDate,
                        customEndDate: endDate,
                        selectedCharacteristic: entry.characteristic,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Количество: ${entry.count}',
                            style: AppTextStyles.bodyMedium16,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Характеристика: ${entry.characteristic?.name ?? 'НЕТ'}',
                            style: AppTextStyles.bodyMedium16,
                          ),
                        ],
                      ),
                      const Divider(),
                    ],
                  );
                },
                childCount: widget.template.listProducts.length,
              ),
            ),
          SliverToBoxAdapter(
            child: SizedBox(
              width: 300,
              child: CheckboxListTile(
                value: saveMarking,
                checkColor: AppColors.white,
                activeColor: AppColors.primary,
                onChanged: (value) {
                  setState(() {
                    saveMarking = value ?? !saveMarking;
                  });
                },
                title: const Text(
                  'Сохранить в журнал?',
                  style: AppTextStyles.bodyMedium16,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: PrimaryButtonIcon(
                text: 'Печатать',
                icon: Icons.print,
                selected: true,
                onPressed: () {
                  startPrint(context);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> startPrint(BuildContext context) async {
    final user = context.read<DBBloc<User>>().repository.currentItem;
    final printerBloc = context.read<PrinterBloc>();
    final markingBloc = context.read<DBBloc<Marking>>();

    for (var entry in widget.template.listProducts) {
      if (!mounted) return;

      if (saveMarking) {
        final endDate = entry.characteristic != null
            ? PrintingUsecase.setAdjustmentTime(
                startDate, entry.characteristic!)
            : startDate;

        markingBloc.add(AddItem(
          Marking(
            product: entry.product,
            user: user,
            category: entry.product.category,
            startDate: startDate,
            endDate: endDate,
            characteristicIndex: entry.product.characteristics.indexOf(
                entry.characteristic ?? entry.product.characteristics.first),
            count: entry.count,
          ),
        ));
      }

      printerBloc.add(PrintLabel(
        product: entry.product,
        employee: user,
        startDate: startDate,
        characteristicIndex: entry.characteristic != null
            ? entry.product.characteristics.indexOf(entry.characteristic!)
            : 0,
        count: entry.count.toString(),
      ));

      if (entry != widget.template.listProducts.last) {
        await Future.delayed(const Duration(seconds: 2));
      }
    }

    if (!mounted) return;
    context.router.popForced();
  }
}
