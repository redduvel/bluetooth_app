import 'package:bluetooth_app/clean/config/theme/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:roundcheckbox/roundcheckbox.dart';

// ignore: must_be_immutable
class CheckBox extends StatefulWidget {
  final String title;
  late bool value;
  CheckBox({super.key, required this.value, required this.title});

  @override
  State<CheckBox> createState() => _CheckBoxState();
}

class _CheckBoxState extends State<CheckBox> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.title,
          style: AppTextStyles.labelMedium18,
        ),
        const SizedBox(
          width: 10,
        ),
        RoundCheckBox(
          isChecked: widget.value,
          onTap: (selected) {
          setState(() {
            widget.value = !widget.value;
          });
        }),
      ],
    );
  }
}
