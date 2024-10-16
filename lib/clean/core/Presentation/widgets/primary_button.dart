import 'package:bluetooth_app/clean/config/theme/colors.dart';
import 'package:bluetooth_app/clean/config/theme/text_styles.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class PrimaryButtonIcon extends StatelessWidget {
  final String text;
  final IconData icon;
  final Widget toPage;
   Function()? onPressed;
   bool selected;

   PrimaryButtonIcon({
    super.key,
    required this.toPage,
    this.onPressed,
    required this.text,
    required this.icon,
    this.selected = false,
  });


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: ElevatedButton.icon(
        
        style:  ButtonStyle(
            backgroundColor: WidgetStatePropertyAll(selected ? AppColors.primary : AppColors.surface),
            fixedSize: const WidgetStatePropertyAll(Size(167, 40)),
            side: const WidgetStatePropertyAll(BorderSide.none),
            
            shape: const WidgetStatePropertyAll(RoundedRectangleBorder(
              side: BorderSide.none,
              borderRadius: BorderRadius.all(Radius.circular(0)),
            )),
            shadowColor: const WidgetStatePropertyAll(Colors.transparent)),
        onPressed: onPressed,
        label: Text(
          text,
          style: AppTextStyles.bodyMedium16.copyWith(
            color: selected ? AppColors.text : AppColors.secondaryText
          ),
        ),
        icon: Icon(
          icon,
          color: selected ? AppColors.text : AppColors.secondaryText
        ),
      ),
    );
  }
}
