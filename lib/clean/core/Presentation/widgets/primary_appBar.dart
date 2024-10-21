import 'package:bluetooth_app/clean/config/theme/colors.dart';
import 'package:bluetooth_app/clean/config/theme/text_styles.dart';
import 'package:bluetooth_app/clean/core/Presentation/widgets/primary_clock.dart';
import 'package:bluetooth_app/clean/core/Presentation/widgets/primary_textfield.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class PrimaryAppBar extends StatefulWidget implements PreferredSizeWidget {
  List<Widget>? buttons = [];
  final String title;
  final TextStyle? titleStyle;
  
  PrimaryAppBar({super.key, this.buttons, required this.title, this.titleStyle});

  @override
  State<PrimaryAppBar> createState() => _PrimaryAppBarState();
  
  @override
  Size get preferredSize => const Size(double.infinity, 100);
}

class _PrimaryAppBarState extends State<PrimaryAppBar> {
  @override
  AppBar build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.white,
      automaticallyImplyLeading: false,
      bottom: PreferredSize(
          preferredSize: const Size(double.infinity, 60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  widget.title,
                  style: widget.titleStyle ?? AppTextStyles.labelMedium18.copyWith(fontSize: 32),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    PrimaryTextField(
                        controller: TextEditingController(),
                        width: 500,
                        hintText: 'Поиск продуктов'),
                    if (widget.buttons != null)
                    ...widget.buttons!.map((button) => button)
                  ],
                ),
                const PrimaryClock()
              ],
            ),
          )),
    );
  }
}
