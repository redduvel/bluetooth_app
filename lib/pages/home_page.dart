import 'package:bluetooth_app/bloc/bloc.bloc.dart';

import 'package:bluetooth_app/models/employee.dart';
import 'package:bluetooth_app/pages/label_page.dart';
import 'package:bluetooth_app/pages/manage_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late GenericBloc<Employee> bloc;
  TextEditingController passwordController = TextEditingController();
  bool valid = true;


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
          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w600),
        ),
        centerTitle: false,
        actions: [
          PopupMenuButton(
            iconColor: Colors.white,
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                  child: const Text('Настройки'),
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) {
                        return BottomSheet(
                          onClosing: () {},
                          builder: (context) {
                            return StatefulBuilder(
                              builder: (context, setState) {
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Scaffold(
                                    body: SingleChildScrollView(
                                      scrollDirection: Axis.vertical,
                                      child: Align(
                                        alignment: Alignment.topCenter,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            TextField(
                                              controller: passwordController,
                                              obscureText: true,
                                              onSubmitted: (value) {
                                                if (value != "1234") {
                                                  setState(() {
                                                    valid = false;
                                                  });
                                                  return;
                                                }

                                                Navigator.pop(context);
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            const ManagePage()));
                                              },
                                              decoration: InputDecoration(
                                                  hintText: '* * * *',
                                                  errorText: valid
                                                      ? null
                                                      : 'Неверный пароль',
                                                  label: const Text('Пароль')),
                                            ),
                                            const Divider(),
                                            ElevatedButton(
                                                onPressed: () {
                                                  if (passwordController.text !=
                                                      "1234") {
                                                    setState(() {
                                                      valid = false;
                                                    });
                                                    return;
                                                  }
                                                  Navigator.pop(context);
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              const ManagePage()));
                                                },
                                                child: const Text(
                                                    'Войти в настройки'))
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ];
            },
          )
        ],
      ),
      body: const SizedBox(
        
      ),
      floatingActionButton: ElevatedButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              builder: (context) {
                return BlocBuilder<GenericBloc<Employee>,
                    GenericState<Employee>>(
                  bloc: bloc,
                  builder: (context, state) {
                    if (state is ItemsLoaded<Employee>) {
                      List<Employee> employees = state.items;
                      if (employees.isEmpty) {
                        return const CustomScrollView(
                          slivers: [
                            SliverToBoxAdapter(
                              child: Align(
                                alignment: Alignment.center,
                                child: Text('Нет сотрудников'),
                              ),
                            )
                          ],
                        );
                      } else {
                        return CustomScrollView(
                          slivers: [
                            SliverList(
                                delegate: SliverChildBuilderDelegate(
                                    (context, index) {
                              return ListTile(
                                title: Text(
                                    employees[index].fullName),
                                trailing: const Icon(Icons.arrow_forward),
                                leading: const Icon(Icons.person),
                                onTap: () {
                                  bloc.repository.currentItem =
                                      employees[index];
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => const LabelPage()));
                                },
                              );
                            }, childCount: employees.length)),
                          ],
                        );
                      }
                    }
                    if (state is ItemOperationFailed<Employee>) {
                      return const CustomScrollView(
                        slivers: [
                          SliverToBoxAdapter(
                            child: Align(
                                alignment: Alignment.center,
                                child: Text('Ошибка загрузки данных')),
                          )
                        ],
                      );
                    }

                    return const SizedBox.shrink();
                  },
                );
              },
            );
          },
          child: const Text('Маркировка')),
    );
  }
}
