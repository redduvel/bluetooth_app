import 'package:bluetooth_app/bloc/printer/printer.bloc.dart';
import 'package:bluetooth_app/bloc/printer/printer.event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TsplEditorPage extends StatefulWidget {
  const TsplEditorPage({super.key});

  @override
  _TsplEditorPageState createState() => _TsplEditorPageState();
}

class _TsplEditorPageState extends State<TsplEditorPage> {
  final TextEditingController widthController = TextEditingController(text: "30");
  final TextEditingController heightController = TextEditingController(text: "20");
  final TextEditingController gapController = TextEditingController(text: "3");

  List<Map<String, TextEditingController>> contentFields = [];

  @override
  void initState() {
    super.initState();
    // Инициализируем первым полем
    addNewContentField();
  }

  void addNewContentField() {
    setState(() {
      contentFields.add({
        'x': TextEditingController(text: "10"),
        'y': TextEditingController(text: "${100 + contentFields.length * 30}"),
        'text': TextEditingController(text: "текст ${contentFields.length + 1}")
      });
    });
  }

  String generateTsplCode() {
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TSPL Редактор')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: widthController,
                decoration: const InputDecoration(labelText: 'Ширина этикетки (mm)'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: heightController,
                decoration: const InputDecoration(labelText: 'Высота этикетки (mm)'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: gapController,
                decoration: const InputDecoration(labelText: 'Расстояние между этикетками (mm)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              ...contentFields.map((field) {
                return Column(
                  children: [
                    TextField(
                      controller: field['x'],
                      decoration: const InputDecoration(labelText: 'X позиция'),
                      keyboardType: TextInputType.number,
                    ),
                    TextField(
                      controller: field['y'],
                      decoration: const InputDecoration(labelText: 'Y позиция'),
                      keyboardType: TextInputType.number,
                    ),
                    TextField(
                      controller: field['text'],
                      decoration: const InputDecoration(labelText: 'Текст'),
                    ),
                    const SizedBox(height: 20),
                  ],
                );
              }),
              ElevatedButton(
                onPressed: addNewContentField,
                child: const Text('Добавить линию'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  String tsplCode = generateTsplCode();
                  context.read<PrinterBloc>().add(UpdateTsplCode(tsplCode));
                  Navigator.pop(context);
                },
                child: const Text('Сохранить и вернуться'),
              )

            ],
          ),
        ),
      ),
    );
  }
}
