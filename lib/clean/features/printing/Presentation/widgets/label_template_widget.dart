import 'package:auto_size_text/auto_size_text.dart';
import 'package:bluetooth_app/clean/core/Domain/bloc/db.bloc.dart';
import 'package:bluetooth_app/clean/core/Domain/entities/product.dart';
import 'package:bluetooth_app/clean/core/Domain/entities/user.dart';
import 'package:bluetooth_app/clean/features/printing/Presentation/widgets/clock_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:universal_io/io.dart';

class LabelTemplateWidget extends StatefulWidget {
    final Product product;

  const LabelTemplateWidget({super.key, required this.product});

  @override
  State<LabelTemplateWidget> createState() => _LabelTemplateWidgetState();
}

class _LabelTemplateWidgetState extends State<LabelTemplateWidget> {
  DateTime customEndDate = DateTime.now();
  DateTime startDate = DateTime.now();
  DateTime adjustmentDateTime = DateTime.now();

  bool customDate = false;
    int selectedCharacteristic = 0;


  late User currentUser;

  @override
  void initState() {
    currentUser = context.read<DBBloc<User>>().repository.currentItem ?? User(fullName: 'fullName');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
            widget.product.subtitle,
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
            currentUser.fullName,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
            maxLines: 1,
            maxFontSize: 22,
            minFontSize: 14,
          )
        ],
      ),
    );
  }
}
