import 'dart:io';

import 'package:bluetooth_app/bloc/bloc.bloc.dart';
import 'package:bluetooth_app/models/employee.dart';
import 'package:bluetooth_app/pages/label_page.dart';
import 'package:bluetooth_app/pages/manage_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late GenericBloc<Employee> bloc;
  TextEditingController passwordController = TextEditingController();
  bool valid = true;
  final String correctPassword = "1234";

  @override
  void initState() {
    bloc = context.read<GenericBloc<Employee>>()..add(LoadItems<Employee>());
    super.initState();
  }

  @override
  void dispose() {
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: const Text(
          'Fresh Tag',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          PopupMenuButton(
            iconColor: Colors.white,
            itemBuilder: (context) => [
              PopupMenuItem(
                child: const Text('Настройки'),
                onTap: () => navigateToSettings(context),
              ),
            ],
          ),
        ],
      ),
      body: const SizedBox(),
      floatingActionButton: ElevatedButton(
        onPressed: _onMarkingButtonPressed,
        child: const Text('Маркировка'),
      ),
    );
  }

  void navigateToSettings(BuildContext context) {
    if (Platform.isMacOS || Platform.isWindows) {
      _showPasswordDialog(context);
    } else {
      _showPasswordModal(context);
    }
  }

  void _showPasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return _buildPasswordDialog(setState);
        },
      ),
    );
  }

  Widget _buildPasswordDialog(void Function(void Function()) setState) {
    return AlertDialog(
      title: const Text('Вход в настройки'),
      content: _buildPasswordField(setState),
      actions: [
        _buildEnterButton(setState),
      ],
    );
  }

  Widget _buildPasswordField(void Function(void Function()) setState) {
    return TextField(
      controller: passwordController,
      obscureText: true,
      onSubmitted: (value) => _validatePassword(setState),
      decoration: InputDecoration(
        hintText: '* * * *',
        errorText: valid ? null : 'Неверный пароль',
        label: const Text('Пароль'),
      ),
    );
  }

  ElevatedButton _buildEnterButton(void Function(void Function()) setState) {
    return ElevatedButton(
      onPressed: () => _validatePassword(setState),
      child: const Text('Войти в настройки'),
    );
  }

  void _validatePassword(void Function(void Function()) setState) {
    if (passwordController.text != correctPassword) {
      setState(() => valid = false);
      return;
    }
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ManagePage()),
    );
  }

  void _showPasswordModal(BuildContext context) {
    showBarModalBottomSheet(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return _buildPasswordModal(setState);
        },
      ),
    );
  }

  Widget _buildPasswordModal(void Function(void Function()) setState) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildPasswordField(setState),
            const Divider(),
            _buildEnterButton(setState),
          ],
        ),
      ),
    );
  }

  void _onMarkingButtonPressed() {
    showBarModalBottomSheet(
      context: context,
      builder: (context) {
        return SizedBox(
          height: 500,
          child: BlocBuilder<GenericBloc<Employee>, GenericState<Employee>>(
            bloc: bloc,
            builder: (context, state) {
              if (state is ItemsLoaded<Employee>) {
                return _buildEmployeeList(state.items);
              } else if (state is ItemOperationFailed<Employee>) {
                return _buildErrorState();
              }
              return const SizedBox.shrink();
            },
          ),
        );
      },
    );
  }

  Widget _buildEmployeeList(List<Employee> employees) {
    if (employees.isEmpty) {
      return _buildEmptyState();
    } else {
      return CustomScrollView(
        slivers: [
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return ListTile(
                  title: Text(employees[index].fullName),
                  trailing: const Icon(Icons.arrow_forward),
                  leading: const Icon(Icons.person),
                  onTap: () {
                    bloc.repository.currentItem = employees[index];
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LabelPage()),
                    );
                  },
                );
              },
              childCount: employees.length,
            ),
          ),
        ],
      );
    }
  }

  Widget _buildEmptyState() {
    return const CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Align(
            alignment: Alignment.center,
            child: Text('Нет сотрудников'),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return const CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Align(
            alignment: Alignment.center,
            child: Text('Ошибка загрузки данных'),
          ),
        ),
      ],
    );
  }
}
