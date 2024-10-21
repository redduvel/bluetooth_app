import 'dart:async';
import 'package:bluetooth_app/clean/config/theme/colors.dart';
import 'package:bluetooth_app/clean/config/theme/text_styles.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

class PrimaryClock extends StatefulWidget {
  const PrimaryClock({super.key});

  @override
  State<PrimaryClock> createState() => _PrimaryClockState();
}

class _PrimaryClockState extends State<PrimaryClock> {
  late DateTime dateTime;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    dateTime = DateTime.now();
    startTimer();
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() {
        dateTime = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
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
          child: Text(
            DateFormat('HH').format(dateTime),
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
          child: Text(
            DateFormat('mm').format(dateTime),
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
            dateTime.hour >= 12 ? 'PM' : 'AM',
            style: AppTextStyles.bodySmall12.copyWith(color: AppColors.white),
          ),
        ),
        Text(
          DateFormat('yyyy/MM/dd').format(dateTime),
          style: AppTextStyles.bodyMedium16,
        ),
      ],
    );
  }
}
