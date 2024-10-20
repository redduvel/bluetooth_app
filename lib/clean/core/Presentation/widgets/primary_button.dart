import 'package:bluetooth_app/clean/config/theme/colors.dart';
import 'package:bluetooth_app/clean/config/theme/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

// ignore: must_be_immutable
class PrimaryButtonIcon extends StatelessWidget {
  final String text;
  final IconData icon;
  final Widget toPage;

  double? width;
  double? height;

  Radius? radius;
  Alignment? alignment;
  EdgeInsets? padding;

  Function()? onPressed;
  bool selected;

  PrimaryButtonIcon(
      {super.key,
      required this.toPage,
      this.onPressed,
      required this.text,
      required this.icon,
      this.selected = false,
      this.width,
      this.height,
      this.radius,
      this.alignment,
      this.padding});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? 50,
      child: Padding(
        padding: padding ?? const EdgeInsets.symmetric(vertical: 5),
        child: ElevatedButton.icon(
          style: ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(
                  selected ? AppColors.primary : AppColors.surface),
              //fixedSize:  WidgetStatePropertyAll(Size(width, height ?? 40)),
              side: const WidgetStatePropertyAll(BorderSide.none),
              alignment: alignment ?? Alignment.centerLeft,
              shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                side: BorderSide.none,
                borderRadius:
                    BorderRadius.all(radius ?? const Radius.circular(4)),
              )),
              shadowColor: const WidgetStatePropertyAll(Colors.transparent)),
          onPressed: onPressed,
          label: Text(
            text,
            style: AppTextStyles.bodyMedium16.copyWith(
                color: selected ? AppColors.text : AppColors.secondaryText),
          ),
          icon: Icon(icon,
              color: selected ? AppColors.text : AppColors.secondaryText),
        ),
      ),
    );
  }
}
