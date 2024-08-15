import 'package:bluetooth_app/bloc/printer/printer.bloc.dart';
import 'package:bluetooth_app/bloc/tspl/tspl.bloc.dart';
import 'package:bluetooth_app/bloc/tspl/tspl.event.dart';
import 'package:bluetooth_app/bloc/tspl/tspl.state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:intl/intl.dart';

class TsplEditorPage extends StatefulWidget {
  const TsplEditorPage({super.key});

  @override
  _TsplEditorPageState createState() => _TsplEditorPageState();
}

class _TsplEditorPageState extends State<TsplEditorPage> {
  late TsplBloc blocTspl;
  late PrinterBloc blocPrinter;

  bool selectedDefrosting = true;
  bool selectedClosed = false;
  bool selectedOpened = false;

  @override
  void initState() {
    blocTspl = context.read<TsplBloc>();
    blocPrinter = context.read<PrinterBloc>();
    super.initState();
  }

  /*String generateTsplCode() {
    String width = widthController.text;
    String height = heightController.text;
    String gap = gapController.text;

    StringBuffer tsplCode = StringBuffer();

    tsplCode.writeln('SIZE $width mm, $height mm');
    tsplCode.writeln('GAP $gap mm, 0 mm');
    tsplCode.writeln('CLS');

    for (var field in contentFields) {
      String x = field['x']!.text;
      String y = field['y']!.text;
      String text = field['text']!.text;

      tsplCode.writeln('TEXT $x, $y, "0", 0, 1, 1, "$text"');
    }

    tsplCode.writeln('PRINT 20,1');

    return tsplCode.toString();
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Редактор шаблона')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Center(
            child: BlocBuilder<TsplBloc, TsplState>(
              builder: (context, state) {
                if (state is LabelSettingsUpdated) {
                  return Column(
                    children: [
                      Container(
                        width: 30 * 8,
                        height: 20 * 8,
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                            color: Color.fromARGB(255, 207, 207, 207)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              state.currentProduct.subtitle,
                              style: const TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.w500),
                            ),
                            Text(
                              DateFormat('yyyy-MM-dd HH:mm')
                                  .format(state.selectedTime),
                              style: const TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.w500),
                            ),
                            Text(
                              DateFormat('yyyy-MM-dd HH:mm')
                                  .format(state.adjustmentTime),
                              style: const TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.w500),
                            ),
                            Text(
                              state.currentEmployee.fullName,
                              style: const TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.w500),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ChoiceChip(
                            label: const Text('Разморозка'),
                            selected: selectedDefrosting,
                            onSelected: (value) {
                              setState(() {
                                selectedDefrosting = value;
                                selectedOpened = false;
                                selectedClosed = false;
                              });
                              blocTspl.add(const SetTimeAdjustment('defrosting'));
                            },
                          ),
                          ChoiceChip(
                            label: const Text('Открытое'),
                            selected: selectedOpened,
                            onSelected: (value) {
                              setState(() {
                                selectedOpened = value;
                                selectedDefrosting = false;
                                selectedClosed = false;
                              });
                              blocTspl.add(const SetTimeAdjustment('openedTime'));
                            },
                          ),
                          ChoiceChip(
                            label: const Text('Закрытое'),
                            selected: selectedClosed,
                            onSelected: (value) {
                              setState(() {
                                selectedDefrosting = false;
                                selectedOpened = false;
                                selectedClosed = value;
                              });
                              blocTspl.add(const SetTimeAdjustment('closedTime'));
                            },
                          )
                        ],
                      ),
                      ElevatedButton(
                          onPressed: () {
                            DatePicker.showDateTimePicker(context,
                                showTitleActions: true,
                                minTime: DateTime(2024, 1, 1),
                                maxTime: DateTime(2100, 12, 29),
                                onChanged: (date) {}, onConfirm: (date) {
                              blocTspl.add(SetSelectedTime(date));
                            },
                                currentTime: DateTime.now(),
                                locale: LocaleType.ru);
                          },
                          child: const Text('Выбрать другую даты отсчета')),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          //String tsplCode = generateTsplCode();
                          //context
                          //.read<PrinterBloc>()
                          //.add(UpdateTsplCode(tsplCode));
                          Navigator.pop(context);
                        },
                        child: const Text('Сохранить и вернуться'),
                      )
                    ],
                  );
                }

                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
