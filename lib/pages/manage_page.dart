import 'package:bluetooth_app/pages/tabs/documents_tab.dart';
import 'package:bluetooth_app/pages/tabs/employee_tab.dart';
import 'package:bluetooth_app/pages/tabs/products_tab.dart';
import 'package:flutter/material.dart';

class ManagePage extends StatefulWidget {
  const ManagePage({super.key});

  @override
  State<ManagePage> createState() => _ManagePageState();
}

class _ManagePageState extends State<ManagePage> {
  int _currentIndex = 2;

  final List<Widget> _children = [
    const ProductsTab(),
    const EmployeeTab(),
    const DocumentsTab(),
  ];

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки'),
      ),
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
          onTap: onTabTapped,
          currentIndex: _currentIndex,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.local_pizza),
              label: 'Ингридиенты',
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.person), label: 'Сотрудники'),
            BottomNavigationBarItem(
                icon: Icon(Icons.category), label: 'Категории')
          ]),
    );
  }
}
