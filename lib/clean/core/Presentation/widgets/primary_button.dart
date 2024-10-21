import 'package:bluetooth_app/clean/config/theme/colors.dart';
import 'package:bluetooth_app/clean/config/theme/text_styles.dart';
import 'package:flutter/material.dart';

enum ButtonType {
  normal, 
  warning,
  delete
}
// ignore: must_be_immutable
class PrimaryButtonIcon extends StatelessWidget {
  final String text;
  final IconData icon;
  final Widget? toPage;
  final ButtonType? type;

  double? width;
  double? height;

  Radius? radius;
  Alignment? alignment;
  EdgeInsets? padding;

  Function()? onPressed;
  bool selected;

  PrimaryButtonIcon(
      {super.key,
      this.toPage,
      this.onPressed,
      this.type,
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
    Color backgroundColor = switch (type) {
      ButtonType.normal => AppColors.surface,
      ButtonType.warning => AppColors.yellowSurface,
      ButtonType.delete => AppColors.redSurface,
      null => AppColors.surface,
    };

    Color foregroundColor = switch (type) {
      ButtonType.normal => AppColors.secondaryText,
      ButtonType.warning => AppColors.yellowOnSurface,
      ButtonType.delete => AppColors.redOnSurface,
      null => AppColors.secondaryText,
    };

    return SizedBox(
      width: width,
      height: height,
      child: Padding(
        padding: padding ?? const EdgeInsets.symmetric(vertical: 5),
        child: ElevatedButton.icon(
          style: ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(
                  selected ? AppColors.primary : backgroundColor),
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
                color: selected ? AppColors.text : foregroundColor),
          ),
          icon: Icon(icon,
              color: selected ? AppColors.text : foregroundColor),
        ),
      ),
    );
  }
}
