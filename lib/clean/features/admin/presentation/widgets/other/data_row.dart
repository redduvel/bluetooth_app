import 'package:bluetooth_app/clean/config/theme/colors.dart';
import 'package:bluetooth_app/clean/config/theme/text_styles.dart';
import 'package:bluetooth_app/clean/core/Domain/entities/marking_db/marking.dart';
import 'package:flutter/material.dart';

enum MarkerStatus { normal, warning, timeIsUp, none }

DataCell _createStatus(MarkerStatus status) {
  switch (status) {
    case MarkerStatus.normal:
      return DataCell(Container(
          decoration: BoxDecoration(
            color: AppColors.greenSurface,
            borderRadius: BorderRadius.circular(4),
          ),
          padding: const EdgeInsets.all(4),
          child: Text(
            'Нормальный',
            style: AppTextStyles.bodyMedium16
                .copyWith(color: AppColors.greenOnSurface, fontSize: 12),
          )));
    case MarkerStatus.warning:
      return DataCell(Container(
          decoration: BoxDecoration(
            color: AppColors.yellowSurface,
            borderRadius: BorderRadius.circular(4),
          ),
          padding: const EdgeInsets.all(4),
          child: Text(
            'Скоро истечет',
            style: AppTextStyles.bodyMedium16
                .copyWith(color: AppColors.yellowOnSurface, fontSize: 12),
          )));
    case MarkerStatus.timeIsUp:
      return DataCell(Container(
          decoration: BoxDecoration(
            color: AppColors.redSurface,
            borderRadius: BorderRadius.circular(4),
          ),
          padding: const EdgeInsets.all(4),
          child: Text(
            'Истекло',
            style: AppTextStyles.bodyMedium16
                .copyWith(color: AppColors.redOnSurface, fontSize: 12),
          )));

    default:
      return DataCell(Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(4),
          ),
          padding: const EdgeInsets.all(4),
          child: Text(
            'Неизвестно',
            style: AppTextStyles.bodyMedium16
                .copyWith(color: AppColors.text, fontSize: 12),
          )));
  }
}

MarkerStatus calculateTimeStatus(DateTime startDate, DateTime endDate) {
  final currentTime = DateTime.now();

  if (currentTime.isBefore(startDate)) {
    return MarkerStatus.normal;
  }

  if (currentTime.isAfter(endDate)) {
    return MarkerStatus.timeIsUp;
  }

  final totalDuration = endDate.difference(startDate).inMilliseconds;
  final elapsedDuration = currentTime.difference(startDate).inMilliseconds;
  final remainingPercentage = 1 - (elapsedDuration / totalDuration);

  if (remainingPercentage >= 0.5) {
    return MarkerStatus.normal;
  } else {
    return MarkerStatus.warning;
  }
}

Widget _createTimeOut(
    MarkerStatus status, int dayOut, DateTime startDate, DateTime endDate) {
  Color surface = switch (status) {
    MarkerStatus.normal => AppColors.greenSurface,
    MarkerStatus.warning => AppColors.yellowSurface,
    MarkerStatus.timeIsUp => AppColors.redSurface,
    MarkerStatus.none => AppColors.surface
  };

  Color onSurface = switch (status) {
    MarkerStatus.normal => AppColors.greenOnSurface,
    MarkerStatus.warning => AppColors.yellowOnSurface,
    MarkerStatus.timeIsUp => AppColors.redOnSurface,
    MarkerStatus.none => AppColors.text
  };

  return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(4),
      ),
      padding: const EdgeInsets.all(4),
      child: Text(
        calculateRemainingTime(startDate, endDate),
        style:
            AppTextStyles.bodyMedium16.copyWith(color: onSurface, fontSize: 12),
      ));
}

double calculateRemainingPercentage(DateTime startDate, DateTime endDate) {
  final currentTime = DateTime.now();

  if (currentTime.isBefore(startDate)) {
    // Если текущая дата еще до начала периода, возвращаем 100%
    return 100.0;
  }

  if (currentTime.isAfter(endDate)) {
    // Если текущая дата после окончания периода, возвращаем 0%
    return 0.0;
  }

  // Вычисляем процент оставшегося времени
  final totalDuration = endDate.difference(startDate).inMilliseconds;
  final elapsedDuration = currentTime.difference(startDate).inMilliseconds;
  final remainingPercentage =
      ((totalDuration - elapsedDuration) / totalDuration) * 100;

  return remainingPercentage;
}

String calculateRemainingTime(DateTime startDate, DateTime endDate) {
  final currentTime = DateTime.now();

  DateTime effectiveStartDate =
      currentTime.isBefore(startDate) ? startDate : currentTime;

  if (currentTime.isAfter(endDate)) {
    return "0 мин.";
  }

  final remainingDuration = endDate.difference(effectiveStartDate);

  if (remainingDuration.inDays >= 1) {
    return "${remainingDuration.inDays} дн.";
  } else if (remainingDuration.inHours >= 1) {
    return "${remainingDuration.inHours} ч.";
  } else {
    return "${remainingDuration.inMinutes} мин.";
  }
}

DataRow createDataRow(Marking m) {
  return DataRow(cells: [
    DataCell(Text(
      m.product.title,
      overflow: TextOverflow.ellipsis,
      style: AppTextStyles.bodyMedium16,
    )),
    _createStatus(calculateTimeStatus(m.startDate, m.endDate)),
    DataCell(Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: AppColors.surface,
              ),
              width: 100 / 2,
              height: 4,
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: AppColors.text,
              ),
              width: calculateRemainingPercentage(m.startDate, m.endDate) / 2,
              height: 4,
            ),
          ],
        ),
        const SizedBox(
          width: 5,
        ),
        Text(
            '${calculateRemainingPercentage(m.startDate, m.endDate).toStringAsFixed(0)}%'),
        const SizedBox(
          width: 5,
        ),
        _createTimeOut(calculateTimeStatus(m.startDate, m.endDate), 100,
          m.startDate, m.endDate),
      ],
    )),
    
    DataCell(Text('${m.count}')),
  ]);
}
