import 'package:bluetooth_app/bloc/bloc.bloc.dart';
import 'package:bluetooth_app/models/employee.dart';
import 'package:bluetooth_app/models/product.dart';
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

  void startPrint(String count) {
    String tsplTemplate = '''
    ${widget.bloc.repository.currentItem.title}
    2024-08-08 15:00
    2024-09-08 20:00
    ${context.read<GenericBloc<Employee>>().repository.currentItem.firstName}
    ''';
    print(
      tsplTemplate
    );
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$count копий отправленно на печать')));
    Navigator.pop(context);
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

                  showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return BottomSheet(
                        onClosing: () {},
                        builder: (context) {
                          return Padding(
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
                                  child: ElevatedButton(
                                      onPressed: () {},
                                      child:
                                          const Text('Редактировать шаблон')),
                                ),
                                const SliverToBoxAdapter(
                                  child: Divider(),
                                ),
                                SliverToBoxAdapter(
                                  child: ElevatedButton(
                                      onPressed: () {
                                        startPrint('1');
                                      },
                                      child: const Text('1 копия')),
                                ),
                                SliverToBoxAdapter(
                                  child: ElevatedButton(
                                      onPressed: () {
                                        startPrint('3');
                                      },
                                      child: const Text('3 копии')),
                                ),
                                SliverToBoxAdapter(
                                  child: ElevatedButton(
                                      onPressed: () {
                                        startPrint('5');
                                      },
                                      child: const Text('5 копий')),
                                ),
                                SliverToBoxAdapter(
                                  child: ElevatedButton(
                                      onPressed: () {
                                        startPrint('5');
                                      },
                                      child: const Text('10 копий')),
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
                                                              FontWeight.w400),
                                                    ),
                                                    const Divider(),
                                                    TextInput(
                                                      controller:
                                                          customPrintController,
                                                      hintText: '20',
                                                      labelText:
                                                          'Количество этикеток',
                                                      type:
                                                          TextInputType.number,
                                                    ),
                                                    const SizedBox(
                                                      height: 50,
                                                    ),
                                                    ElevatedButton(
                                                        onPressed: () {
                                                          startPrint(
                                                              customPrintController
                                                                  .text);
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
                                      child: const Text('Свое количество')),
                                )
                              ],
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
