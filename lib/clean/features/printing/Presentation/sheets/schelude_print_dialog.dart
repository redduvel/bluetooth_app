import 'package:auto_route/auto_route.dart';
import 'package:bluetooth_app/clean/config/theme/colors.dart';
import 'package:bluetooth_app/clean/config/theme/text_styles.dart';
import 'package:bluetooth_app/clean/core/Domain/bloc/db.bloc.dart';
import 'package:bluetooth_app/clean/core/Domain/entities/marking/characteristic.dart';
import 'package:bluetooth_app/clean/core/Domain/entities/marking/product.dart';
import 'package:bluetooth_app/clean/core/Domain/entities/marking/user.dart';
import 'package:bluetooth_app/clean/core/Domain/entities/marking_db/marking.dart';
import 'package:bluetooth_app/clean/core/Presentation/widgets/primary_button.dart';
import 'package:bluetooth_app/clean/core/Presentation/widgets/primary_textfield.dart';
import 'package:bluetooth_app/clean/features/printing/Domain/usecase/printing_usecase.dart';
import 'package:bluetooth_app/clean/features/printing/Presentation/bloc/printer.bloc.dart';
import 'package:bluetooth_app/clean/features/printing/Presentation/bloc/printer.event.dart';
import 'package:bluetooth_app/clean/features/printing/Presentation/widgets/label_template_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';

class ScheludePrintDialog extends StatefulWidget {
  final Product product;
  const ScheludePrintDialog({super.key, required this.product});

  @override
  State<ScheludePrintDialog> createState() => _ScheludePrintDialogState();
}

class _ScheludePrintDialogState extends State<ScheludePrintDialog> {
  late TextEditingController amountController;
  late bool saveMarking;
  late bool adjustmentType;
  late int count;

  DateTime customEndDate = DateTime.now();
  DateTime adjustmentDateTime = DateTime.now();
  int selectedCharacteristic = 0;

  @override
  void initState() {
    super.initState();
    amountController = TextEditingController(text: '1');
    saveMarking = false;
    adjustmentType = false;
    count = 1;

  }

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: CustomScrollView(
        shrinkWrap: true,
        slivers: [
          SliverToBoxAdapter(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  flex: 7,
                  child: Text(
                    'Печать этикетки: ${widget.product.title}',
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
                      padding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
          const SliverToBoxAdapter(child: Divider()),
          SliverToBoxAdapter(
            child: LabelTemplateWidget(
                product: widget.product,
                customDate: true,
                startDate: adjustmentDateTime,
                customEndDate: customEndDate,
                selectedCharacteristic:
                    widget.product.characteristics.isNotEmpty
                        ? widget.product.characteristics[selectedCharacteristic]
                        : null),
          ),
          const SliverToBoxAdapter(child: Divider()),
          if (widget.product.characteristics.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.start,
                  alignment: WrapAlignment.center,
                  runAlignment: WrapAlignment.center,
                  spacing: 5,
                  runSpacing: -3,
                  children: List.generate(widget.product.characteristics.length,
                      (index) {
                    Characteristic c = widget.product.characteristics[index];

                    return ChoiceChip(
                      backgroundColor: AppColors.white,
                      selectedColor: AppColors.greenSurface,
                      checkmarkColor: AppColors.greenOnSurface,
                      label: Text(c.name),
                      selected: selectedCharacteristic == index,
                      onSelected: (value) {
                        setState(() {
                          selectedCharacteristic = index;
                          customEndDate = PrintingUsecase.setAdjustmentTime(
                              adjustmentDateTime,
                              widget.product
                                  .characteristics[selectedCharacteristic]);
                        });
                      },
                    );
                  })),
            ),
            const SliverToBoxAdapter(child: Divider()),
          ],
          if (widget.product.characteristics.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: TableCalendar(
                locale: Localizations.localeOf(context).languageCode,
                focusedDay: adjustmentDateTime, firstDay: DateTime(2000), lastDay: DateTime(2100),
                selectedDayPredicate: (day) => isSameDay(day, adjustmentDateTime),
                availableCalendarFormats: const {
                  CalendarFormat.month: 'Month'
                },
                headerStyle: const HeaderStyle(
                  leftChevronIcon: Icon(Icons.arrow_back_ios, color: AppColors.black,),
                  rightChevronIcon: Icon(Icons.arrow_forward_ios, color: AppColors.black,)
                ),
                calendarStyle: CalendarStyle(
                  selectedDecoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary
                  ),
                  todayDecoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary
                    ),
                    
                  ),
                  todayTextStyle: AppTextStyles.bodyMedium16.copyWith(
                    color: AppColors.black
                  )
                ),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                  adjustmentDateTime = selectedDay;

                  customEndDate = PrintingUsecase.setAdjustmentTime(
                      adjustmentDateTime,
                      widget.product.characteristics[selectedCharacteristic]);
                });
                },)
            ),
            
            const SliverToBoxAdapter(child: Divider()),
          ],
          SliverToBoxAdapter(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    flex: 2,
                    child: PrimaryButtonIcon(
                      onPressed: () {
                        setState(() {
                          if (count > 1) {
                            count--;
                            amountController.text = '$count';
                          }
                        });
                      },
                      text: '',
                      alignment: Alignment.center,
                      icon: Icons.remove,
                    ),
                  ),
                  Flexible(
                    flex: 3,
                    child: PrimaryTextField(
                      controller: amountController,
                      textAlign: TextAlign.center,
                      width: 300,
                      hintText: 'Количество этикеток',
                      onChanged: (value) {
                        setState(() {
                          final parsedValue = int.tryParse(value);
                          if (parsedValue != null && parsedValue > 0) {
                            count = parsedValue;
                          } else {
                            amountController.text = '$count';
                          }
                        });
                      },
                      onSubmitted: (value) => editAmount(value),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  Flexible(
                    flex: 2,
                    child: PrimaryButtonIcon(
                      onPressed: () {
                        setState(() {
                          count++;
                          amountController.text = '$count';
                        });
                      },
                      text: '',
                      icon: Icons.add,
                    ),
                  ),
                ],
              ),
              PrimaryButtonIcon(
                text: 'Печатать',
                icon: Icons.print,
                selected: true,
                onPressed: () {
                  startPrint(context);
                },
              ),
            ],
          )),
          const SliverToBoxAdapter(
            child: SizedBox(
              height: 100,
            ),
          )
        ],
      ),
    );
  }

  void editAmount(String value) {
    setState(() {
      final parsedValue = int.tryParse(value);
      if (parsedValue != null && parsedValue > 0) {
        count = parsedValue;
      } else {
        amountController.text = '$count';
      }
    });
  }

  void startPrint(BuildContext context) {
    if (saveMarking) {
      context.read<DBBloc<Marking>>().add(AddItem(Marking(
          product: widget.product,
          user: context.read<DBBloc<User>>().repository.currentItem,
          category: widget.product.category,
          startDate: adjustmentType ? customEndDate : DateTime.now(),
          endDate: PrintingUsecase.setAdjustmentTime(
              adjustmentType ? customEndDate : DateTime.now(),
              widget.product.characteristics[selectedCharacteristic]),
          characteristicIndex: selectedCharacteristic,
          count: count)));
    }
    context.read<PrinterBloc>().add(PrintLabel(
          product: widget.product,
          employee: context.read<DBBloc<User>>().repository.currentItem,
          startDate: adjustmentType ? customEndDate : DateTime.now(),
          characteristicIndex: selectedCharacteristic,
          count: amountController.text,
        ));
  }
}
