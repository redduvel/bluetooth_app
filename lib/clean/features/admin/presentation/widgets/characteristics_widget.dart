import 'package:bluetooth_app/clean/config/theme/colors.dart';
import 'package:bluetooth_app/clean/core/Domain/entities/characteristic.dart';
import 'package:bluetooth_app/clean/core/Presentation/widgets/primary_button.dart';
import 'package:bluetooth_app/clean/core/Presentation/widgets/primary_textfield.dart';
import 'package:bluetooth_app/clean/features/admin/presentation/pages/main_screens/settings_screen.dart';
import 'package:flutter/material.dart';

class CharacteristicsWidget extends StatefulWidget {
  final List<Characteristic> characteristics;
  final List<TextEditingController> nameControllers;
  final List<TextEditingController> valueControllers;
  final List<MeasurementUnit> units;

  const CharacteristicsWidget(
      {super.key,
      required this.characteristics,
      required this.nameControllers,
      required this.valueControllers,
      required this.units});

  @override
  State<CharacteristicsWidget> createState() => _CharacteristicsWidgetState();
}

class _CharacteristicsWidgetState extends State<CharacteristicsWidget> {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      runSpacing: 10,
      spacing: 10,
      children: [
        ...List.generate(widget.characteristics.length, (index) {
          return SizedBox(
            width: 350,
            height: 155,
            child: Card(
              color: AppColors.surface,
              margin: const EdgeInsets.all(0),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    Row(
                      children: [
                        PrimaryTextField(
                          controller: widget.nameControllers[index],
                          hintText: 'Название',
                          width: 150,
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            setState(() {
                              widget.characteristics.removeAt(index);
                              widget.nameControllers.removeAt(index);
                              widget.valueControllers.removeAt(index);
                              widget.units.removeAt(index);
                            });
                          },
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        PrimaryTextField(
                          controller: widget.valueControllers[index],
                          hintText: 'Значение',
                          width: 150,
                          //type: TextInputType.number,
                        ),
                        const VerticalDivider(),
                        Expanded(
                          flex: 1,
                          child: DropdownButton<MeasurementUnit>(
                            dropdownColor: AppColors.white,
                            value: widget.units[index],
                            padding: EdgeInsets.zero,
                            onChanged: (newUnit) {
                              setState(() {
                                widget.units[index] = newUnit!;
                              });
                            },
                            alignment: Alignment.center,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.black),
                            items: MeasurementUnit.values
                                .map((MeasurementUnit unit) {
                              return DropdownMenuItem<MeasurementUnit>(
                                value: unit,
                                child: Text(
                                  getLocalizedMeasurementUnit(unit),
                                  style: const TextStyle(fontSize: 14),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
        PrimaryButtonIcon(
          toPage: const SettingsScreen(),
          alignment: Alignment.center,
          text: 'Добавить характеристику',
          icon: Icons.add,
          width: 350,
          height: 155,
          radius: const Radius.circular(12),
          padding: EdgeInsets.zero,
          onPressed: () {
            setState(() {
              widget.characteristics.add(
                Characteristic(name: '', value: 0, unit: MeasurementUnit.hours),
              );
              widget.nameControllers.add(TextEditingController());
              widget.valueControllers.add(TextEditingController());
              widget.units.add(MeasurementUnit.hours);
            });
          },
        ),
      ],
    );
  }
}
