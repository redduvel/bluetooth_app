import 'package:bluetooth_app/bloc/printer.bloc.dart';
import 'package:bluetooth_app/bloc/printer.event.dart';
import 'package:bluetooth_app/bloc/printer.state.dart';
import 'package:bluetooth_app/models/template_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

class TemplateEditorScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bluetoothBloc = BlocProvider.of<BluetoothBloc>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Template Editor'),
      ),
      body: BlocBuilder<BluetoothBloc, BluetoothState>(
        builder: (context, state) {
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: state.templateItems.length,
                  itemBuilder: (context, index) {
                    final item = state.templateItems[index];
                    if (item is TemplateParagraph) {
                      return ListTile(
                          title: Text(item.content),
                          trailing: PopupMenuButton(
                            child: const Icon(Icons.more_vert),
                            itemBuilder: (context) {
                              return [
                                PopupMenuItem(
                                  child: Text('Изменить'),
                                  onTap: () {
                                    showModalBottomSheet(
                                      context: context,
                                      builder: (context) {
                                        return Scaffold(
                                            appBar: AppBar(
                                              title: const Text(
                                                  'Редактирование параграфа'),
                                              centerTitle: true,
                                              automaticallyImplyLeading: false,
                                              actions: [
                                                IconButton(
                                                    onPressed: () {},
                                                    icon:
                                                        const Icon(Icons.save))
                                              ],
                                            ),
                                            body: const CustomScrollView(
                                              slivers: [
                                                SliverToBoxAdapter(
                                                  child: TextField(
                                                    decoration: InputDecoration(
                                                      labelText: 'Контент',
                                                      hintText: 'Контент'
                                                    ),
                                                  ),
                                                ),
                                                SliverToBoxAdapter(
                                                  child: DropdownMenu(
                                                      label: Text(
                                                          'Толщина текста'),
                                                      dropdownMenuEntries: [
                                                        DropdownMenuEntry(
                                                            value: 0,
                                                            label: '1'),
                                                        DropdownMenuEntry(
                                                            value: 1,
                                                            label: '2')
                                                      ]),
                                                )
                                              ],
                                            ));
                                      },
                                    );
                                  },
                                ),
                                PopupMenuItem(
                                  child: Text('Удалить'),
                                  onTap: () {
                                    bluetoothBloc
                                        .add(RemoveTemplateItem(index));
                                  },
                                ),
                              ];
                            },
                          ));
                    } else if (item is TemplateImage) {
                      return ListTile(
                        title: const Text('Image'),
                        subtitle: Text('Image from ${item.path}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            bluetoothBloc.add(RemoveTemplateItem(index));
                          },
                        ),
                      );
                    }
                    return Container();
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          TextEditingController controller =
                              TextEditingController();
                          return AlertDialog(
                            title: const Text('Add Paragraph'),
                            content: TextField(
                              controller: controller,
                              decoration: const InputDecoration(
                                  hintText: 'Enter paragraph text'),
                            ),
                            actions: [
                              ElevatedButton(
                                onPressed: () {
                                  bluetoothBloc.add(AddTemplateItem(
                                      TemplateParagraph(
                                          content: controller.text)));
                                  Navigator.pop(context);
                                },
                                child: const Text('Add'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: const Text('Add Paragraph'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
                      final XFile? image =
                          await picker.pickImage(source: ImageSource.gallery);
                      if (image != null) {
                        bluetoothBloc.add(
                            AddTemplateItem(TemplateImage(path: image.path)));
                      }
                    },
                    child: const Text('Add Image'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  bluetoothBloc.add(PrintTemplate());
                },
                child: const Text('Print Template'),
              ),
            ],
          );
        },
      ),
    );
  }
}
