import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Список данных
  List<String> _items = List.generate(10, (index) => 'Item ${index + 1}');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reorderable ListView Example'),
      ),
      body: ReorderableListView(
        // Данный метод вызывается при перетаскивании элемента
        onReorder: (int oldIndex, int newIndex) {
          setState(() {
            if (newIndex > oldIndex) {
              newIndex -= 1;
            }
            final String item = _items.removeAt(oldIndex);
            _items.insert(newIndex, item);
          });
        },
        // Отображение элементов списка
        children: _items.map((item) {
          return ListTile(
            key: ValueKey(item),
            title: Text(item),
          );
        }).toList(),
      ),
    );
  }
}