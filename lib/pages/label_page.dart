import 'package:bluetooth_app/pages/tabs/products_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';

class LabelPage extends StatefulWidget {
  const LabelPage({super.key});

  @override
  State<LabelPage> createState() => _LabelPageState();
}

class _LabelPageState extends State<LabelPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        actions: [
          IconButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) => BottomSheet(
                    onClosing: () {},
                    builder: (context) {
                      return const CustomScrollView(
                        slivers: [
                          SliverToBoxAdapter(
                            child: Text(''),
                          )
                        ],
                      );
                    },
                  ),
                );
              },
              icon: const Icon(Icons.settings)),
          IconButton(
            onPressed: () {
              DatePicker.showDateTimePicker(context,
                  showTitleActions: true,
                  minTime: DateTime(2024, 1, 1),
                  maxTime: DateTime(2100, 12, 29), onChanged: (date) {
                print('change $date');
              }, onConfirm: (date) {
                print('confirm $date');
              }, currentTime: DateTime.now(), locale: LocaleType.ru);
            },
            icon: const Icon(Icons.schedule),
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.all(0),
            iconSize: 24,
          )
        ],
      ),
      body: const ProductsTab(
        showProductTools: false,
        showFloatingActionButton: false,
        showHideProducts: false,
        isSetting: false,
        gridCrossAxisCount: 3,
        gridChilAspectRatio: 1 / 1.3,
      ),
    );
  }
}
