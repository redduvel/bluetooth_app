import 'package:bluetooth_app/clean/core/Domain/entities/category.dart';
import 'package:bluetooth_app/clean/core/Domain/entities/characteristic.dart';
import 'package:bluetooth_app/clean/core/Domain/entities/product.dart';
import 'package:bluetooth_app/clean/core/Presentation/widgets/primary_appBar.dart';
import 'package:bluetooth_app/clean/features/printing/Presentation/widgets/product_widget.dart';
import 'package:flutter/material.dart';

class PrintingPage extends StatefulWidget {
  const PrintingPage({super.key});

  @override
  State<PrintingPage> createState() => _PrintingPageState();
}

class _PrintingPageState extends State<PrintingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PrimaryAppBar(),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: EdgeInsets.all(8),
            sliver: SliverToBoxAdapter(
                child: Wrap(
              spacing: 15,
              runSpacing: 15,
              children: List.generate(3, (index) {
                return ProductWidget(product: Product(title: 'Мясо говяжье', subtitle: 'мясо гов.', characteristics: [
                  Characteristic(name: 'Открытое хранение', value: 5, unit: MeasurementUnit.hours),
                  Characteristic(name: 'Закрытое хранение', value: 15, unit: MeasurementUnit.days),
                  Characteristic(name: 'Разморозка', value: 30, unit: MeasurementUnit.minutes),
                ], category: Category(order: 0, name: 'Мясо', isHide: false), isHide: false, allowFreeTime: true),);
              }),
            )),
          )
        ],
      ),
    );
  }
}
