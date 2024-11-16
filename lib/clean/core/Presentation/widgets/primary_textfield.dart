import 'package:bluetooth_app/clean/config/theme/colors.dart';
import 'package:flutter/material.dart';

class PrimaryTextField extends StatelessWidget {
  final TextEditingController controller;
  final double width;
  final String hintText;

  final EdgeInsets? margin;
  final IconData? icon;
  final void Function(String)? onSubmitted;
  final void Function(String)? onChanged;
  final TextInputType? keyboardType;
  final TextAlign? textAlign;

  const PrimaryTextField({
    super.key,
    required this.controller,
    required this.width,
    required this.hintText,
    this.margin,
    this.icon,
    this.onSubmitted,
    this.keyboardType,
    this.textAlign,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: margin ?? const EdgeInsets.all(8.0),
        child: TextField(
          textAlign: textAlign ?? TextAlign.left,
          keyboardType: keyboardType,
          controller: controller,
          onSubmitted: onSubmitted,
          onChanged: onChanged,
          decoration: InputDecoration(
              enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(
                    color: AppColors.secondaryButton,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(4))),
              focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(
                    color: AppColors.secondaryText,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(4))),
              filled: true,
              fillColor: AppColors.inputSurface,
              prefixIcon: icon != null ? Icon(icon) : null,
              hintText: hintText),
          cursorColor: AppColors.greenOnSurface,
        ),
      ),
    );
  }
}
