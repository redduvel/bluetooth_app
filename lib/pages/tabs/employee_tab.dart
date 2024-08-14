import 'package:bluetooth_app/bloc/bloc.bloc.dart';
import 'package:bluetooth_app/models/employee.dart';
import 'package:bluetooth_app/widgets/text_feild.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EmployeeTab extends StatefulWidget {
  const EmployeeTab({super.key});

  @override
  State<EmployeeTab> createState() => _EmployeeTabState();
}

class _EmployeeTabState extends State<EmployeeTab> {
  late GenericBloc<Employee> bloc;
  TextEditingController firstNameController = TextEditingController();

  @override
  void initState() {
    bloc = context.read<GenericBloc<Employee>>()..add(LoadItems<Employee>());

    super.initState();
  }

  @override
  void dispose() {
    firstNameController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<GenericBloc<Employee>, GenericState<Employee>>(
        bloc: bloc,
        builder: (context, state) {
          if (state is ItemsLoaded<Employee>) {
            if (state.items.isEmpty) {
              return const Center(
                child: Text('Нет сотрудников'),
              );
            } else {
              return CustomScrollView(
                slivers: [
                  SliverList(
                      delegate: SliverChildBuilderDelegate(
                          childCount: state.items.length, (context, index) {
                    return ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(
                          "${state.items[index].firstName} ${state.items[index].lastName}"),
                      trailing: PopupMenuButton(
                        itemBuilder: (context) {
                          return [
                            PopupMenuItem(
                              child: const Text('Удалить'),
                              onTap: () {
                                bloc.add(DeleteItem<Employee>(
                                    state.items[index].id));
                              },
                            ),
                          ];
                        },
                      ),
                    );
                  }))
                ],
              );
            }
          }

          if (state is ItemOperationFailed<Employee>) {
            return Center(
              child: Text("Ошибка загрузки данных: ${state.error}"),
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (context) {
              return BottomSheet(
                onClosing: () {},
                builder: (context) {
                  return StatefulBuilder(
                    builder: (context, setState) {
                      return Scaffold(
                        body: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CustomScrollView(
                            slivers: [
                              const SliverAppBar(
                                title: Text('Добавление сотрудника'),
                                centerTitle: true,
                                automaticallyImplyLeading: false,
                              ),
                              SliverToBoxAdapter(
                                  child: TextInput(
                                      controller: firstNameController,
                                      hintText: 'Иванов Иван',
                                      labelText: 'Фамилия и имя сотрудника')),
                              const SliverToBoxAdapter(
                                child: SizedBox(
                                  height: 30,
                                ),
                              ),
                              SliverToBoxAdapter(
                                child: ElevatedButton(
                                    onPressed: () {
                                      bloc.add(AddItem<Employee>(Employee(
                                          firstName: firstNameController.text.split(' ')[0],
                                          lastName: '')));
                                              Navigator.pop(context);

                                    },
                                    child: const Text('Добавить')),
                              )
                            ],
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
        child: const Icon(Icons.add),
      ),
    );
  }
}
