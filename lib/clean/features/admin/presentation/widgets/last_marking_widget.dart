import 'package:bluetooth_app/clean/config/theme/colors.dart';
import 'package:bluetooth_app/clean/config/theme/text_styles.dart';
import 'package:flutter/material.dart';

class LastMarkingWidget extends StatelessWidget {
  final String name;
  final String startDate;
  final String endDate;
  
  const LastMarkingWidget({super.key, required this.name, required this.startDate, required this.endDate});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 227,
      height: 80,
      decoration: BoxDecoration(
          color: AppColors.greenSurface,
          borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Text(
            name,
            style: const TextStyle(
                color: AppColors.white,
                fontSize: 24,
                fontWeight: FontWeight.w600),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(startDate,
                  style: AppTextStyles.bodySmall12.copyWith(fontSize: 12)),
              Container(
                width: 50,
                height: 2,
                color: AppColors.black,
              ),
              Text(endDate,
                  style: AppTextStyles.bodySmall12.copyWith(fontSize: 12)),
            ],
          )
        ],
      ),
    );
  }
}
