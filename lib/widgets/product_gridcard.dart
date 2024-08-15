import 'package:bluetooth_app/bloc/bloc.bloc.dart';
import 'package:bluetooth_app/bloc/printer/printer.bloc.dart';
import 'package:bluetooth_app/bloc/printer/printer.event.dart';
import 'package:bluetooth_app/bloc/tspl/tspl.bloc.dart';
import 'package:bluetooth_app/bloc/tspl/tspl.event.dart';
import 'package:bluetooth_app/models/employee.dart';
import 'package:bluetooth_app/models/product.dart';
import 'package:bluetooth_app/tools/tspl.dart';
import 'package:bluetooth_app/widgets/text_feild.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProductGridItem extends StatefulWidget {
  final Product product;
  final GenericBloc<Product> bloc;

  const ProductGridItem({super.key, required this.product, required this.bloc});

  @override
  State<ProductGridItem> createState() => _ProductGridItemState();
}

class _ProductGridItemState extends State<ProductGridItem> {
  TextEditingController customPrintController = TextEditingController();
  late TsplBloc blocTspl;

  bool selectedDefrosting = true;
  bool selectedClosed = false;
  bool selectedOpened = false;

  @override
  void initState() {
    blocTspl = context.read<TsplBloc>();
    super.initState();
  }

  void startPrint(String count) {
    print(TsplTools.generateTsplCode(
        context.read<GenericBloc<Employee>>().repository.currentItem,
        widget.bloc.repository.currentItem,
        count));

    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$count копий отправленно на печать')));
    Navigator.pop(context);
  }

  AdjustmentType getAdjustmentType() {
    if (selectedDefrosting) {
      return AdjustmentType.defrosting;
    }

    if (selectedClosed) {
      return AdjustmentType.closed;
    }

    if (selectedOpened) {
      return AdjustmentType.opened;
    }

    throw Exception();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          ListTile(
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
                Text(
                  "(р)${widget.product.defrosting.toString()}ч.",
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 16),
                ),
                Text(
                  "(з)${widget.product.closedTime.toString()}ч.",
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 16),
                ),
                Text(
                  "(о)${widget.product.openedTime.toString()}ч.",
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 16),
                )
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  widget.bloc.repository.currentItem = widget.product;
                  context
                      .read<TsplBloc>()
                      .add(SetCurrentProduct(widget.product));
                  showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return BottomSheet(
                        onClosing: () {},
                        builder: (context) {
                          return StatefulBuilder(
                            builder: (context, setState) => Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: CustomScrollView(
                                slivers: [
                                  SliverToBoxAdapter(
                                    child: Text(
                                      'Печать этикетки: ${widget.product.title}',
                                      style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                  const SliverToBoxAdapter(
                                    child: Divider(),
                                  ),
                                  SliverToBoxAdapter(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        ChoiceChip(
                                          label: const Text('Разморозка'),
                                          selected: selectedDefrosting,
                                          onSelected: (value) {
                                            setState(() {
                                              selectedDefrosting = value;
                                              selectedOpened = false;
                                              selectedClosed = false;
                                            });
                                            blocTspl.add(
                                                const SetTimeAdjustment(
                                                    'defrosting'));
                                          },
                                        ),
                                        ChoiceChip(
                                          label: const Text('Открытое'),
                                          selected: selectedOpened,
                                          onSelected: (value) {
                                            setState(() {
                                              selectedOpened = value;
                                              selectedDefrosting = false;
                                              selectedClosed = false;
                                            });
                                            blocTspl.add(
                                                const SetTimeAdjustment(
                                                    'openedTime'));
                                          },
                                        ),
                                        ChoiceChip(
                                          label: const Text('Закрытое'),
                                          selected: selectedClosed,
                                          onSelected: (value) {
                                            setState(() {
                                              selectedDefrosting = false;
                                              selectedOpened = false;
                                              selectedClosed = value;
                                            });
                                            blocTspl.add(
                                                const SetTimeAdjustment(
                                                    'closedTime'));
                                          },
                                        )
                                      ],
                                    ),
                                  ),
                                  const SliverToBoxAdapter(
                                    child: Divider(),
                                  ),
                                  SliverToBoxAdapter(
                                    child: ElevatedButton(
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              return Dialog(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      const Text(
                                                        'Введите количество копий',
                                                        style: TextStyle(
                                                            fontSize: 20,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w400),
                                                      ),
                                                      const Divider(),
                                                      TextInput(
                                                        controller:
                                                            customPrintController,
                                                        hintText: '1',
                                                        labelText:
                                                            'Количество этикеток',
                                                        type: TextInputType
                                                            .number,
                                                      ),
                                                      const SizedBox(
                                                        height: 50,
                                                      ),
                                                      ElevatedButton(
                                                          onPressed: () {
                                                            context
                                                                .read<
                                                                    PrinterBloc>()
                                                                .add(
                                                                    PrintLabel(
                                                                      product: widget.product,
                                                                      employee: context.read<GenericBloc<Employee>>().repository.currentItem,
                                                                      startDate: DateTime.now(),
                                                                      adjustmentType: getAdjustmentType()
                                                                    ));
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          child: const Text(
                                                              'Подтвердить'))
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                        },
                                        child: const Text('Ввести количество')),
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
                icon: const Icon(Icons.print),
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.all(0),
                iconSize: 24,
              ),
            ],
          )
        ],
      ),
    );
  }
}
