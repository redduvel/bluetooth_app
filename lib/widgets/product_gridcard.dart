import 'dart:async';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:bluetooth_app/bloc/bloc.bloc.dart';
import 'package:bluetooth_app/bloc/printer/printer.bloc.dart';
import 'package:bluetooth_app/bloc/printer/printer.event.dart';
import 'package:bluetooth_app/core/constants/ui_const.dart';
import 'package:bluetooth_app/models/characteristic.dart';
import 'package:bluetooth_app/models/employee.dart';
import 'package:bluetooth_app/models/product.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class ProductGridItem extends StatefulWidget {
  final Product product;
  final GenericBloc<Product> bloc;

  const ProductGridItem({super.key, required this.product, required this.bloc});

  @override
  State<ProductGridItem> createState() => _ProductGridItemState();
}

class _ProductGridItemState extends State<ProductGridItem> {
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
      onTap: () {
        _showPrintBottomSheet(context);
      },
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildListTile(),
            _buildActionRow(context),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile() {
    return ListTile(
        minVerticalPadding: 0,
        contentPadding: const EdgeInsets.symmetric(horizontal: 5),
        title: Text(
          widget.product.subtitle,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: widget.product.characteristics
                .map((c) => _buildProductInfo(c))
                .toList()));
  }

  Widget _buildProductInfo(Characteristic characteristic) {
    return Text(
      characteristic.toString(),
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(fontSize: 14),
    );
  }

  Widget _buildActionRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildPrintButton(context),
        if (widget.product.allowFreeTime)
        _buildScheduleButton(context),
      ],
    );
  }

  Widget _buildPrintButton(BuildContext context) {
    return IconButton(
      onPressed: () => _showPrintBottomSheet(context),
      icon: const Icon(Icons.print),
      visualDensity: VisualDensity.comfortable,
      padding: const EdgeInsets.all(5),
      iconSize: 32,
    );
  }

  Widget _buildScheduleButton(BuildContext context) {
    return IconButton(
      onPressed: () => _showScheduleBottomSheet(context),
      icon: const Icon(Icons.schedule),
      visualDensity: VisualDensity.comfortable,
      padding: const EdgeInsets.all(5),
      iconSize: 32,
    );
  }

  // шаблон этикетки
  Widget _buildLabelTemplate(
      BuildContext context, Product product, Employee employee, bool customDate,
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
                        fontSize: 22, fontWeight: FontWeight.w500),
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
                        fontSize: 22, fontWeight: FontWeight.w500),
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

  // для обычной печати
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
        adjustmentDateTime = setAdjustmentTime(adjustmentDateTime,
            widget.product.characteristics[selectedCharacteristic]);
      });
    }
    showBarModalBottomSheet(
      context: context,
      builder: (context) {
        return SizedBox(
            height: MediaQuery.of(context).size.height - 50,
            child: _buildPrintBottomSheetContent(context));
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
              if (widget.product.characteristics.isNotEmpty)
                _buildLabelTemplate(
                    context,
                    widget.product,
                    context
                        .read<GenericBloc<Employee>>()
                        .repository
                        .currentItem,
                    false,
                    startDate: startDate),
              if (widget.product.characteristics.isEmpty)
                _buildEmptyLabelTemplate(
                  context,
                  widget.product,
                  context.read<GenericBloc<Employee>>().repository.currentItem,
                ),
              const SliverToBoxAdapter(
                child: Divider(),
              ),
              if (widget.product.characteristics.isNotEmpty)
                _buildChoiceChips(setState),
              const SliverToBoxAdapter(child: Divider()),
              _buildPrintQuantityButton(context, false),
            ],
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
          alignment: WrapAlignment.start,
          runAlignment: WrapAlignment.start,
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
      label: Text(c.name),
      selected: selectedCharacteristic == thisIndex,
      onSelected: (value) {
        setState(() {
          selectedCharacteristic = thisIndex;
          adjustmentDateTime = setAdjustmentTime(customEndDate, c);
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
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Flexible(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          if (count > 1) {
                            count--;
                            controller.text = '$count';
                          }
                        });
                      },
                      child: const Text(
                        '-',
                        style: TextStyle(fontSize: 26),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 3,
                    child: TextField(
                      controller: controller,
                      decoration: const InputDecoration(
                        label: Text('Количество этикеток'),
                      ),
                      textAlign: TextAlign.center,
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
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          count++;
                          controller.text = '$count';
                        });
                      },
                      child: const Text(
                        '+',
                        style: TextStyle(fontSize: 26),
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(
                height: 30,
              ),
              ElevatedButton(
                onPressed: () {
                  // context.read<PrinterBloc>().add(PrintLabel(
                  //       product: widget.product,
                  //       employee: context
                  //           .read<GenericBloc<Employee>>()
                  //           .repository
                  //           .currentItem,
                  //       startDate:
                  //           adjustmentType ? customEndDate : DateTime.now(),
                  //       characteristicIndex: selectedCharacteristic,
                  //       count: controller.text,
                  //     ));
                },
                child: const Text('Печатать'),
              ),
            ],
          );
        },
      ),
    );
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
        adjustmentDateTime = setAdjustmentTime(adjustmentDateTime,
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
              _buildLabelTemplate(
                  context,
                  widget.product,
                  context.read<GenericBloc<Employee>>().repository.currentItem,
                  true),
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

              adjustmentDateTime = setAdjustmentTime(
                  time, widget.product.characteristics[selectedCharacteristic]);
            });
          }, currentTime: customEndDate, locale: LocaleType.ru);
        },
        child: const Text('Выбрать дату отсчета'),
      ),
    );
  }

  // пустой шаблон
  Widget _buildEmptyLabelTemplate(
      BuildContext context, Product product, Employee employee) {
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
}

DateTime setAdjustmentTime(DateTime startTime, Characteristic characteristic) {
  switch (characteristic.unit) {
    case MeasurementUnit.hours:
      return startTime.add(Duration(hours: characteristic.value));
    case MeasurementUnit.minutes:
      return startTime.add(Duration(minutes: characteristic.value));
    case MeasurementUnit.days:
      return startTime.add(Duration(days: characteristic.value));
    default:
      throw ArgumentError('Unknown MeasurementUnit: ${characteristic.unit}');
  }
}

class ClockWidget extends StatefulWidget {
  final DateTime startDate;
  final Characteristic? characteristic;

  const ClockWidget(
      {super.key, required this.startDate, required this.characteristic});

  @override
  _ClockWidgetState createState() => _ClockWidgetState();
}

class _ClockWidgetState extends State<ClockWidget> {
  DateTime? _currentTime;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _initializeTime();
    _timer =
        Timer.periodic(const Duration(seconds: 1), (Timer t) => _updateTime());
  }

  @override
  void didUpdateWidget(covariant ClockWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.characteristic != oldWidget.characteristic) {
      _initializeTime();
    }
  }

  void _initializeTime() {
    _currentTime = widget.startDate;
    if (widget.characteristic != null) {
      //_currentTime = setAdjustmentTime(_currentTime!, widget.characteristic!);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateTime() {
    setState(() {
      _currentTime = _currentTime!.add(const Duration(seconds: 1));
    });
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _formatDateTime(_currentTime!),
      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
    );
  }
}
