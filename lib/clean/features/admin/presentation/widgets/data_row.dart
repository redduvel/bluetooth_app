import 'package:bluetooth_app/clean/config/theme/colors.dart';
import 'package:bluetooth_app/clean/config/theme/text_styles.dart';
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

Widget _createTimeOut(MarkerStatus status, int dayOut) {
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
        '$dayOut суток',
        style:
            AppTextStyles.bodyMedium16.copyWith(color: onSurface, fontSize: 12),
      ));
}

DataRow createDataRow(String name, MarkerStatus status, double progressValue,
    double percent, int dayOut, int count) {
  return DataRow(cells: [
    DataCell(Text(
      name,
      overflow: TextOverflow.ellipsis,
      style: AppTextStyles.bodyMedium16,
    )),
    _createStatus(status),
    DataCell(Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: AppColors.surface,
              ),
              width: 100,
              height: 4,
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: AppColors.text,
              ),
              width: progressValue,
              height: 4,
            ),
          ],
        ),
        const SizedBox(
          width: 5,
        ),
        Text('$percent%'),
        const SizedBox(
          width: 5,
        ),
        _createTimeOut(status, dayOut),
      ],
    )),
    DataCell(Text('$count')),
  ]);
}
