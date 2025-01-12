import 'package:bluetooth_app/clean/config/theme/colors.dart';
import 'package:bluetooth_app/clean/core/Presentation/widgets/primary_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DateTimePickerSheet extends StatefulWidget {
  final DateTime initialDateTime;
  final Function(DateTime) onDateTimeChanged;
  const DateTimePickerSheet(
      {super.key,
      required this.initialDateTime,
      required this.onDateTimeChanged});

  @override
  State<DateTimePickerSheet> createState() => _DateTimePickerSheetState();
}

class _DateTimePickerSheetState extends State<DateTimePickerSheet> {
  void _onDateTimeChanged(DateTime date) {
    widget.onDateTimeChanged(date);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 50),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                height: 400,
                child: CupertinoDatePicker(
                  initialDateTime: widget.initialDateTime,
                  mode: CupertinoDatePickerMode.dateAndTime,
                  use24hFormat: true,
                  showDayOfWeek: true,
                  onDateTimeChanged: _onDateTimeChanged,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const SizedBox(width: 10),
                  Flexible(
                    flex: 1,
                    child: PrimaryButtonIcon(
                        text: 'Отмена',
                        width: double.infinity,
                        type: ButtonType.delete,
        
                        onPressed: () => Navigator.pop(context),
                        icon: Icons.close),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    flex: 1,
                    child: PrimaryButtonIcon(
                        text: 'Сохранить',
                        selected: true,
                        width: double.infinity,
                        type: ButtonType.normal,
                        onPressed: () => Navigator.pop(context),
                        icon: Icons.save),
                  ),
                  const SizedBox(width: 10),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }
}
