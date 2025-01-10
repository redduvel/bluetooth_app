import 'package:bluetooth_app/clean/config/theme/colors.dart';
import 'package:bluetooth_app/clean/core/Domain/entities/marking/characteristic.dart';
import 'package:bluetooth_app/clean/core/Presentation/widgets/primary_button.dart';
import 'package:bluetooth_app/clean/core/Presentation/widgets/primary_textfield.dart';
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
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          flex: 7,
                          child: PrimaryTextField(
                            controller: widget.nameControllers[index],
                            hintText: 'Название',
                            width: double.infinity,
                          ),
                        ),
                        const SizedBox(width: 10,),
                        Flexible(
                          flex: 2,
                          child: IconButton(
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
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          flex: 7,
                          child: PrimaryTextField(
                            controller: widget.valueControllers[index],
                            hintText: 'Значение',
                            width: double.infinity,
                            //type: TextInputType.number,
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Flexible(
                          flex: 2,
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
          alignment: Alignment.center,
          text: 'Добавить характеристику',
          icon: Icons.add,
          width: double.infinity,
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
