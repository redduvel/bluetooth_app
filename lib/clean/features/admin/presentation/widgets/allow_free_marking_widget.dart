import 'package:bluetooth_app/clean/config/theme/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:roundcheckbox/roundcheckbox.dart';

// ignore: must_be_immutable
class AllowFreeMarkingWidget extends StatefulWidget {
  late bool allowFreeMarking;
  AllowFreeMarkingWidget({super.key, required this.allowFreeMarking});

  @override
  State<AllowFreeMarkingWidget> createState() => _AllowFreeMarkingWidgetState();
}

class _AllowFreeMarkingWidgetState extends State<AllowFreeMarkingWidget> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Разрешить свободную маркировку?',
          style: AppTextStyles.labelMedium18,
        ),
        const SizedBox(
          width: 10,
        ),
        RoundCheckBox(
          isChecked: widget.allowFreeMarking,
          onTap: (selected) {
          setState(() {
            widget.allowFreeMarking = !widget.allowFreeMarking;
          });
        }),
      ],
    );
  }
}
