import 'package:bluetooth_app/bloc/bloc.bloc.dart';
import 'package:bluetooth_app/bloc/printer/printer.bloc.dart';
import 'package:bluetooth_app/bloc/printer/printer.event.dart';
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
  DateTime customEndDate = DateTime.now();

  bool selectedDefrosting = true;
  bool selectedClosed = false;
  bool selectedOpened = false;

  @override
  void initState() {
    super.initState();
  }

  AdjustmentType getAdjustmentType() {
    if (selectedDefrosting) return AdjustmentType.defrosting;
    if (selectedClosed) return AdjustmentType.closed;
    if (selectedOpened) return AdjustmentType.opened;
    throw Exception('Invalid Adjustment Type');
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: Column(
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
      contentPadding: const EdgeInsets.all(10),
      title: Text(
        widget.product.subtitle,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProductInfo("(р)", widget.product.defrosting),
          _buildProductInfo("(з)", widget.product.closedTime),
          _buildProductInfo("(о)", widget.product.openedTime),
        ],
      ),
    );
  }

  Widget _buildProductInfo(String label, int time) {
    return Text(
      "$label${time.toString()}ч.",
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(fontSize: 16),
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
                  widget.product, customEndDate, getAdjustmentType())),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildChoiceChip('Разморозка', selectedDefrosting, (value) {
            setState(() {
              selectedDefrosting = true;
              selectedOpened = false;
              selectedClosed = false;
            });
          }),
          _buildChoiceChip('Открытое', selectedOpened, (value) {
            setState(() {
              selectedOpened = true;
              selectedDefrosting = false;
              selectedClosed = false;
            });
          }),
          _buildChoiceChip('Закрытое', selectedClosed, (value) {
            setState(() {
              selectedDefrosting = false;
              selectedOpened = false;
              selectedClosed = true;
            });
          }),
        ],
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
    int count = 1;
    TextEditingController controller = TextEditingController(text: '$count');
    return SliverToBoxAdapter(
      child: StatefulBuilder(
        builder: (context, setSate) => Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Flexible(
                    flex: 2,
                    child: ElevatedButton(
                        onPressed: () {
                          setSate(() {
                            count--;
                            controller.text = '$count';
                          });
                        },
                        child: const Text(
                          '-',
                          style: TextStyle(fontSize: 32),
                        ))),
                Flexible(
                  flex: 2,
                  child: TextField(
                  controller: controller,
                    decoration: const InputDecoration(
                        label: Text('Количество этикеток')),
                    textAlign: TextAlign.center,
                    readOnly: false,
                    keyboardType: TextInputType.number,
                ),
                ),
                Flexible(
                    flex: 2,
                    child: ElevatedButton(
                        onPressed: () {
                          setSate(() {
                            count++;
                            controller.text = '$count';
                          });
                          print(count);
                        },
                        child: const Text(
                          '+',
                          style: TextStyle(fontSize: 32),
                        )))
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
                          adjustmentType: getAdjustmentType(),
                          count: controller.text,
                        ));
                  },
              child: const Text('Печатать'),
                ),
              ],
            ),
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

  DateTime _setAdjustmentTime(Product currentProduct, DateTime selectedTime,
      AdjustmentType adjustmentType) {
    switch (adjustmentType) {
      case AdjustmentType.defrosting:
        return selectedTime.add(Duration(hours: currentProduct.defrosting));
      case AdjustmentType.closed:
        return selectedTime.add(Duration(hours: currentProduct.closedTime));
      case AdjustmentType.opened:
        return selectedTime.add(Duration(hours: currentProduct.openedTime));
      default:
        return selectedTime;
    }
  }
}
