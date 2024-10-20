import 'package:bluetooth_app/clean/config/theme/colors.dart';
import 'package:bluetooth_app/clean/config/theme/text_styles.dart';
import 'package:bluetooth_app/clean/core/Presentation/widgets/primary_textfield.dart';
import 'package:flutter/material.dart';

class PrimaryAppBar extends StatefulWidget implements PreferredSizeWidget {
  List<IconButton>? buttons = [];
  PrimaryAppBar({super.key, this.buttons});

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
                  'Печать этикеток',
                  style: AppTextStyles.labelMedium18.copyWith(fontSize: 32),
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
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(5),
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      decoration: BoxDecoration(
                          color: AppColors.surface,
                          border: Border.all(
                            color: AppColors.secondaryText,
                          ),
                          borderRadius: BorderRadius.circular(8)),
                      child: const Text(
                        '10',
                        style: AppTextStyles.bodySmall12,
                      ),
                    ),
                    const Text(
                      ':',
                      style: AppTextStyles.bodySmall12,
                    ),
                    Container(
                      padding: const EdgeInsets.all(5),
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      decoration: BoxDecoration(
                          color: AppColors.surface,
                          border: Border.all(
                            color: AppColors.secondaryText,
                          ),
                          borderRadius: BorderRadius.circular(8)),
                      child: const Text(
                        '10',
                        style: AppTextStyles.bodySmall12,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(5),
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      decoration: BoxDecoration(
                          color: AppColors.greenOnSurface,
                          border: Border.all(
                            color: AppColors.secondaryText,
                          ),
                          borderRadius: BorderRadius.circular(8)),
                      child: Text(
                        'PM',
                        style: AppTextStyles.bodySmall12
                            .copyWith(color: AppColors.white),
                      ),
                    ),
                    const Text(
                      '11/05/2024',
                      style: AppTextStyles.bodyMedium16,
                    ),
                  ],
                )
              ],
            ),
          )),
    );
  }
}
