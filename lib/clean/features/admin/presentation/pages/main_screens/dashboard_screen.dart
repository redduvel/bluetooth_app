import 'package:bluetooth_app/clean/config/theme/colors.dart';
import 'package:bluetooth_app/clean/config/theme/text_styles.dart';
import 'package:bluetooth_app/clean/features/admin/presentation/widgets/other/data_row.dart';
import 'package:bluetooth_app/clean/features/admin/presentation/widgets/other/last_marking_widget.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: AppColors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const TextField(
                decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.secondaryButton)),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.secondaryText)),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.secondaryButton)),
                    filled: true,
                    fillColor: AppColors.inputSurface,
                    hintText: 'Поиск категорий, маркировок...'),
                cursorColor: AppColors.primary,
              ),
              const SizedBox(
                height: 80,
              ),
              const Text(
                'Последние за 30 дней',
                style: AppTextStyles.labelMedium18,
              ),
              const SizedBox(
                height: 30,
              ),
              const Wrap(
                runSpacing: 10,
                spacing: 10,
                children: [
                  LastMarkingWidget(
                      name: 'name', startDate: 'startDate', endDate: 'endDate'),
                  LastMarkingWidget(
                      name: 'name', startDate: 'startDate', endDate: 'endDate'),
                  LastMarkingWidget(
                      name: 'name', startDate: 'startDate', endDate: 'endDate'),
                ],
              ),
              const SizedBox(
                height: 30,
              ),
              DataTable(
                headingRowColor: const WidgetStatePropertyAll(AppColors.surface),
                headingRowHeight: 40,
                dividerThickness: 0,
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(50)),
                columns: const [
                  DataColumn(label: Text('Название')),
                  DataColumn(label: Text('Статус')),
                  DataColumn(label: Text('Осталось времени')),
                  DataColumn(label: Text('Распечатано')),
                ],
                rows: [
                  createDataRow('Мясо говяжье', MarkerStatus.normal, 78, 78, 15, 15),
                  createDataRow('Мясо баранье', MarkerStatus.warning, 15, 15, 9, 5),
                  createDataRow('Грибы шампиньоны', MarkerStatus.warning, 8, 8, 3, 23),
                  createDataRow('name', MarkerStatus.timeIsUp, 0, 0, 0, 67),
                  createDataRow('name', MarkerStatus.none, 0, 0, 0, 12),
                  createDataRow('name', MarkerStatus.timeIsUp, 0, 0, 0, 3),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
