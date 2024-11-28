import 'package:auto_route/auto_route.dart';
import 'package:auto_size_text/auto_size_text.dart';
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
import 'package:bluetooth_app/clean/features/printing/Presentation/widgets/clock_widget.dart';
import 'package:bluetooth_app/clean/config/constants/ui_const.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:intl/intl.dart';
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

  TextEditingController customPrintController = TextEditingController();
  int count = 1;
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
    return InkWell(
      onHover: (value) {
        setState(() {
          if (value) {
            backgroundColor = AppColors.onSurface;
          } else {
            backgroundColor = AppColors.surface;
          }
        });
      },
      onTap: () {
        _showPrintBottomSheet(context);
      },
      child: Container(
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
                          'Изменить данные',
                          style: AppTextStyles.bodyMedium16,
                        ),
                        onTap: () {},
                      ),
                      PopupMenuItem(
                        child: const Text(
                          'Изменить оформление',
                          style: AppTextStyles.bodyMedium16,
                        ),
                        onTap: () {
                          showDialog(
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
                                        children: List.generate(
                                            AppColors.backgroundColors.length,
                                            (index) {
                                          Color backgroundColor =
                                              AppColors.backgroundColors[index];

                                          return InkWell(
                                            onTap: () {
                                              widget.product.setColor(
                                                  backgroundColor.value);
                                              widget.bloc.add(UpdateItem(
                                                  widget.product.copyWith(
                                                      backgroundColor:
                                                          backgroundColor
                                                              .value)));
                                              context.router.popForced();
                                            },
                                            child: Card(
                                              color: backgroundColor,
                                              child: Container(
                                                width: 100,
                                                height: 100,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                  color: backgroundColor,
                                                ),
                                              ),
                                            ),
                                          );
                                        }),
                                      ),
                                    ),
                                  ));
                        },
                      ),
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
                PrimaryButtonIcon(
                  text: 'Печать',
                  icon: Icons.print,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void _showPrintBottomSheet(BuildContext context) {
    widget.bloc.repository.currentItem = widget.product;
    if (widget.product.characteristics.isNotEmpty) {
      if (selectedCharacteristic >= widget.product.characteristics.length) {
        setState(() {
          selectedCharacteristic = 0;
        });
      }
      setState(() {
        adjustmentDateTime = startDate;
        adjustmentDateTime = PrintingUsecase.setAdjustmentTime(
            adjustmentDateTime,
            widget.product.characteristics[selectedCharacteristic]);
      });
    }
    showDialog(
      context: context,
      builder: (context) {
        return _buildPrintBottomSheetContent(context);
      },
    ).whenComplete(() {
      startDate = DateTime.now();
      customEndDate = DateTime.now();
      adjustmentDateTime = DateTime.now();
    });
  }

  Widget _buildPrintBottomSheetContent(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) {
        return Dialog(
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          child: Center(
            child: CustomScrollView(
              shrinkWrap: (Platform.isIOS || Platform.isAndroid),
              slivers: [
                SliverAppBar(
                  backgroundColor: AppColors.white,
                  automaticallyImplyLeading: false,
                  title: Text(
                    'Печать этикетки: ${widget.product.title}',
                    style: AppTextStyles.labelMedium18
                        .copyWith(fontSize: 22, fontWeight: FontWeight.w500),
                  ),
                ),
                if (widget.product.characteristics.isNotEmpty)
                  _buildLabelTemplate(
                      context,
                      widget.product,
                      context.read<DBBloc<User>>().repository.currentItem,
                      false,
                      startDate: startDate),
                if (widget.product.characteristics.isEmpty)
                  _buildEmptyLabelTemplate(
                    context,
                    widget.product,
                    context.read<DBBloc<User>>().repository.currentItem,
                  ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 10),
                ),
                if (widget.product.characteristics.isNotEmpty)
                  _buildChoiceChips(setState),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 10),
                ),
                SliverToBoxAdapter(
                  child: Center(
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
                  )),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(
                    height: 10,
                  ),
                ),
                _buildPrintQuantityButton(context, false),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildChoiceChips(void Function(void Function()) setState) {
    if (widget.product.characteristics.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverToBoxAdapter(
      child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.start,
          alignment: WrapAlignment.center,
          runAlignment: WrapAlignment.center,
          spacing: 5,
          runSpacing: -3,
          children:
              List.generate(widget.product.characteristics.length, (index) {
            Characteristic c = widget.product.characteristics[index];
            return _buildChoiceChip(c, setState, index);
          })),
    );
  }

  Widget _buildChoiceChip(
      Characteristic c, void Function(void Function()) setState, int index) {
    int thisIndex = index;
    return ChoiceChip(
      backgroundColor: AppColors.white,
      selectedColor: AppColors.greenSurface,
      checkmarkColor: AppColors.greenOnSurface,
      label: Text(c.name),
      selected: selectedCharacteristic == thisIndex,
      onSelected: (value) {
        setState(() {
          selectedCharacteristic = thisIndex;
          adjustmentDateTime =
              PrintingUsecase.setAdjustmentTime(customEndDate, c);
        });
      },
    );
  }

  Widget _buildPrintQuantityButton(BuildContext context, bool adjustmentType) {
    return SliverToBoxAdapter(
      child: StatefulBuilder(
        builder: (context, setState) {
          return Column(
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
                            controller.text = '$count';
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
                      controller: controller,
                      textAlign: TextAlign.center,
                      width: 300,
                      hintText: 'Количество этикеток',
                      onChanged: (value) {
                        setState(() {
                          final parsedValue = int.tryParse(value);
                          if (parsedValue != null && parsedValue > 0) {
                            count = parsedValue;
                          } else {
                            controller.text = '$count';
                          }
                        });
                      },
                      onSubmitted: (value) {
                        setState(() {
                          final parsedValue = int.tryParse(value);
                          if (parsedValue != null && parsedValue > 0) {
                            count = parsedValue;
                          } else {
                            controller.text = '$count';
                          }
                        });
                      },
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  Flexible(
                    flex: 2,
                    child: PrimaryButtonIcon(
                      onPressed: () {
                        setState(() {
                          count++;
                          controller.text = '$count';
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
                  if (saveMarking) {
                    context.read<DBBloc<Marking>>().add(AddItem(Marking(
                        product: widget.product,
                        user:
                            context.read<DBBloc<User>>().repository.currentItem,
                        category: widget.product.category,
                        startDate:
                            adjustmentType ? customEndDate : DateTime.now(),
                        endDate: PrintingUsecase.setAdjustmentTime(
                            adjustmentType ? customEndDate : DateTime.now(),
                            widget.product
                                .characteristics[selectedCharacteristic]),
                        count: count)));
                  }
                  context.read<PrinterBloc>().add(PrintLabel(
                        product: widget.product,
                        employee:
                            context.read<DBBloc<User>>().repository.currentItem,
                        startDate:
                            adjustmentType ? customEndDate : DateTime.now(),
                        characteristicIndex: selectedCharacteristic,
                        count: controller.text,
                      ));
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLabelTemplate(
      BuildContext context, Product product, User employee, bool customDate,
      {DateTime? startDate}) {
    return SliverToBoxAdapter(
        child: Container(
      height: 20 * 8,
      padding: const EdgeInsets.all(5),
      margin: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width /
              (Platform.isMacOS || Platform.isMacOS ? 2.5 : 6)),
      decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          border: Border.all(color: Colors.black, width: 2),
          color: Colors.white),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AutoSizeText(
            product.subtitle,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
            maxLines: 1,
            maxFontSize: 22,
            minFontSize: 14,
          ),
          if (widget.product.characteristics.isNotEmpty)
            customDate
                ? AutoSizeText(
                    DateFormat('yyyy-MM-dd HH:mm').format(customEndDate),
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w500),
                    maxLines: 1,
                    maxFontSize: 22,
                    minFontSize: 14,
                  )
                : ClockWidget(
                    startDate: startDate!,
                    characteristic: null,
                  ),
          if (widget.product.characteristics.isNotEmpty)
            customDate
                ? AutoSizeText(
                    DateFormat('yyyy-MM-dd HH:mm').format(adjustmentDateTime),
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w500),
                    maxLines: 1,
                    maxFontSize: 22,
                    minFontSize: 14,
                  )
                : ClockWidget(
                    key: ValueKey(selectedCharacteristic),
                    startDate: adjustmentDateTime,
                    characteristic:
                        widget.product.characteristics[selectedCharacteristic]),
          AutoSizeText(
            employee.fullName,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
            maxLines: 1,
            maxFontSize: 22,
            minFontSize: 14,
          )
        ],
      ),
    ));
  }

  Widget _buildEmptyLabelTemplate(
      BuildContext context, Product product, User employee) {
    return SliverToBoxAdapter(
        child: Container(
      height: 20 * 8,
      padding: const EdgeInsets.all(5),
      margin: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width /
              (Platform.isMacOS || Platform.isWindows
                  ? UIConst.desktop_labelTemplate_horMarginFacotr
                  : UIConst.mobile_labelTemplate_horMarginFactor)),
      decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          border: Border.all(color: Colors.black, width: 2),
          color: Colors.white),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            product.subtitle,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
          ),
          Text(
            employee.fullName,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
          )
        ],
      ),
    ));
  }

  // для печати с отложенной датой
  void _showScheduleBottomSheet(BuildContext context) {
    if (selectedCharacteristic >= widget.product.characteristics.length) {
      setState(() {
        selectedCharacteristic = 0;
      });
    }
    if (widget.product.characteristics.isNotEmpty) {
      setState(() {
        adjustmentDateTime = startDate;
        adjustmentDateTime = PrintingUsecase.setAdjustmentTime(
            adjustmentDateTime,
            widget.product.characteristics[selectedCharacteristic]);
      });
    }
    showBarModalBottomSheet(
      context: context,
      builder: (context) {
        return SizedBox(
            height: MediaQuery.of(context).size.height - 50,
            child: _buildScheduleBottomSheetContent(context));
      },
    ).whenComplete(() {
      startDate = DateTime.now();
      customEndDate = DateTime.now();
      adjustmentDateTime = DateTime.now();
    });
  }

  Widget _buildScheduleBottomSheetContent(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Text(
                  'Печать этикетки: ${widget.product.title}',
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.w500),
                ),
              ),
              const SliverToBoxAdapter(child: Divider()),
              _buildLabelTemplate(context, widget.product,
                  context.read<DBBloc<User>>().repository.currentItem, true),
              const SliverToBoxAdapter(child: Divider()),
              if (widget.product.characteristics.isNotEmpty)
                _buildChoiceChips(setState),
              const SliverToBoxAdapter(child: Divider()),
              _buildDatePickerButton(context, setState),
              const SliverToBoxAdapter(child: Divider()),
              _buildPrintQuantityButton(context, true),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDatePickerButton(
      BuildContext context, void Function(void Function()) setState) {
    return SliverToBoxAdapter(
      child: ElevatedButton(
        onPressed: () {
          DatePicker.showDateTimePicker(context,
              showTitleActions: true,
              minTime: DateTime(2024, 1, 1),
              maxTime: DateTime(2100, 12, 29), onConfirm: (date) {
            setState(() {
              customEndDate = date;
            });
          }, onChanged: (time) {
            setState(() {
              customEndDate = time;

              adjustmentDateTime = PrintingUsecase.setAdjustmentTime(
                  time, widget.product.characteristics[selectedCharacteristic]);
            });
          }, currentTime: customEndDate, locale: LocaleType.ru);
        },
        child: const Text('Выбрать дату отсчета'),
      ),
    );
  }
}
