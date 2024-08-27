import 'package:bluetooth_app/bloc/bloc.bloc.dart';
import 'package:bluetooth_app/bloc/printer/printer.bloc.dart';
import 'package:bluetooth_app/bloc/printer/printer.event.dart';
import 'package:bluetooth_app/models/characteristic.dart';
import 'package:bluetooth_app/models/employee.dart';
import 'package:bluetooth_app/models/product.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:intl/intl.dart';

class ProductGridItem extends StatefulWidget {
  final Product product;
  final GenericBloc<Product> bloc;

  const ProductGridItem({super.key, required this.product, required this.bloc});

  @override
  State<ProductGridItem> createState() => _ProductGridItemState();
}

class _ProductGridItemState extends State<ProductGridItem> {
  TextEditingController customPrintController =
      TextEditingController(text: '1');
  int count = 1;
  late TextEditingController controller;

  DateTime customEndDate = DateTime.now();

  bool selectedDefrosting = true;
  bool selectedClosed = false;
  bool selectedOpened = false;

  @override
  void initState() {
    controller = TextEditingController(text: '$count');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildListTile(),
          _buildActionRow(context),
        ],
      ),
    );
  }

  Widget _buildListTile() {
    return ListTile(
        minVerticalPadding: 0,
        contentPadding: const EdgeInsets.all(5),
        title: Text(
          widget.product.subtitle,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: widget.product.characteristics
                .map((c) => _buildProductInfo(c))
                .toList()));
  }

  Widget _buildProductInfo(Characteristic characteristic) {
    return Text(
      "${characteristic.toString()}",
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(fontSize: 18),
    );
  }

  Widget _buildActionRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildPrintButton(context),
        _buildScheduleButton(context),
      ],
    );
  }

  Widget _buildPrintButton(BuildContext context) {
    return IconButton(
      onPressed: () => _showPrintBottomSheet(context),
      icon: const Icon(Icons.print),
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.all(0),
      iconSize: 24,
    );
  }

  Widget _buildScheduleButton(BuildContext context) {
    return IconButton(
      onPressed: () => _showScheduleBottomSheet(context),
      icon: const Icon(Icons.schedule),
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.all(0),
      iconSize: 24,
    );
  }

  // шаблон этикетки
  Widget _buildLabelTemplate(
      BuildContext context, Product product, Employee employee,
      {DateTime? startDate}) {
    return SliverToBoxAdapter(
        child: Container(
      height: 20 * 8,
      padding: const EdgeInsets.all(5),
      margin: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width / 6),
      decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          color: Color.fromARGB(255, 255, 255, 255)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            product.subtitle,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
          ),
          Text(
            DateFormat('yyyy-MM-dd HH:mm').format(startDate ?? customEndDate),
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
          ),
          Text(
            DateFormat('yyyy-MM-dd HH:mm').format(_setAdjustmentTime(
                customEndDate, widget.product.characteristics[0])),
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

  // для обычной печати
  void _showPrintBottomSheet(BuildContext context) {
    widget.bloc.repository.currentItem = widget.product;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SizedBox(
            height: MediaQuery.of(context).size.height - 150,
            child: _buildPrintBottomSheetContent(context));
      },
    );
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
              _buildLabelTemplate(context, widget.product,
                  context.read<GenericBloc<Employee>>().repository.currentItem,
                  startDate: DateTime.now()),
              const SliverToBoxAdapter(
                child: Divider(),
              ),
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
    return SliverToBoxAdapter(
      child:  Wrap(
        crossAxisAlignment: WrapCrossAlignment.start,
        alignment: WrapAlignment.start,
        runAlignment: WrapAlignment.start,
        
        spacing: 5,
        runSpacing: -3,
        children: 
        widget.product.characteristics.map((c) => _buildChoiceChip(c.name, false, (value) {})).toList()
         
      ),
    );
  }

  Widget _buildChoiceChip(
      String label, bool selected, ValueChanged<bool> onSelected) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
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
                  context.read<PrinterBloc>().add(PrintLabel(
                        product: widget.product,
                        employee: context
                            .read<GenericBloc<Employee>>()
                            .repository
                            .currentItem,
                        startDate:
                            adjustmentType ? customEndDate : DateTime.now(),
                        count: controller.text,
                      ));
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SizedBox(
            height: MediaQuery.of(context).size.height - 150,
            child: _buildScheduleBottomSheetContent(context));
      },
    );
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
                  context.read<GenericBloc<Employee>>().repository.currentItem),
              const SliverToBoxAdapter(child: Divider()),
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
            });
          }, currentTime: customEndDate, locale: LocaleType.ru);
        },
        child: const Text('Выбрать дату отсчета'),
      ),
    );
  }

  DateTime _setAdjustmentTime(
      DateTime startTime, Characteristic characteristic) {
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
}
