import 'package:bluetooth_app/bloc/bloc.bloc.dart';
import 'package:bluetooth_app/models/nomenclature.dart';
import 'package:bluetooth_app/widgets/text_feild.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DocumentsTab extends StatefulWidget {
  const DocumentsTab({super.key});

  @override
  State<DocumentsTab> createState() => _DocumentsTabState();
}

class _DocumentsTabState extends State<DocumentsTab> {
  late GenericBloc<Nomenclature> bloc;
  TextEditingController nameController = TextEditingController();

  bool valid = false;

  @override
  void initState() {
    bloc = context.read<GenericBloc<Nomenclature>>()
      ..add(LoadItems<Nomenclature>());

    super.initState();
  }

  @override
  void dispose() {
    nameController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<GenericBloc<Nomenclature>, GenericState<Nomenclature>>(
        builder: (context, state) {
          if (state is ItemsLoaded<Nomenclature>) {
            var nomenclatures = state.items;
            if (nomenclatures.isEmpty) {
              return const Center(
                child: Text('Нет категорий'),
              );
            } else {
              return CustomScrollView(
                slivers: [
                  SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                    return ListTile(
                      leading: const Icon(Icons.category),
                      title: Text(nomenclatures[index].name),
                      trailing: PopupMenuButton(
                        itemBuilder: (context) {
                          return [
                            PopupMenuItem(
                              child: const Text('Удалить'),
                              onTap: () {
                                bloc.add(DeleteItem<Nomenclature>(
                                    state.items[index].id));
                              },
                            ),
                          ];
                        },
                      ),
                    );
                  }, childCount: nomenclatures.length))
                ],
              );
            }
          }

          if (state is ItemOperationFailed<Nomenclature>) {
            return Center(
              child: Text('Ошибка загрузки данных: ${state.error}'),
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
                                title: Text('Добавление категории'),
                                centerTitle: true,
                                automaticallyImplyLeading: false,
                              ),
                              SliverToBoxAdapter(
                                  child: TextInput(
                                      controller: nameController,
                                      hintText: 'Специи',
                                      labelText: 'Название')),
                              const SliverToBoxAdapter(
                                child: SizedBox(
                                  height: 30,
                                ),
                              ),
                              SliverToBoxAdapter(
                                child: ElevatedButton(
                                    onPressed: () {
                                      if (nameController.text.isEmpty) {
                                        setState(() {
                                          valid = true;
                                        });
                                        return;
                                      }
                                      bloc.add(AddItem<Nomenclature>(
                                          Nomenclature(
                                              name: nameController.text, isHide: false)));
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
        child: Icon(Icons.add),
      ),
    );
  }
}
