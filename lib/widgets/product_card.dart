import 'package:bluetooth_app/bloc/bloc.bloc.dart';
import 'package:bluetooth_app/models/nomenclature.dart';
import 'package:bluetooth_app/models/product.dart';
import 'package:bluetooth_app/widgets/text_feild.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProductCard extends StatefulWidget {
  final Product product;
  final GenericBloc<Product> bloc;
  final bool showTools;
  
  const ProductCard({super.key, required this.product, required this.bloc, this.showTools = false});

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  late TextEditingController nameController;
  late TextEditingController subnameController;
  late TextEditingController categoryController;
  late TextEditingController defrostingController;
  late TextEditingController closedTimeController;
  late TextEditingController openedTimeController;
  
  bool validCategory = true;

  @override
  void initState() {
    nameController = TextEditingController(text: widget.product.title);
    subnameController = TextEditingController(text: widget.product.subtitle);
    categoryController = TextEditingController(text: widget.product.category);
    defrostingController = TextEditingController(text: widget.product.defrosting.toString());
    closedTimeController = TextEditingController(text: widget.product.closedTime.toString());
    openedTimeController = TextEditingController(text: widget.product.openedTime.toString());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          //Text(widget.product.id),
          ListTile(
            leading: widget.product.isHide ? const Icon(Icons.visibility_off, size: 24,) : null,
            title: Text(widget.product.title),
            subtitle: Text(widget.product.subtitle),
            trailing: widget.showTools ? PopupMenuButton(itemBuilder: (context) {
              return [
                PopupMenuItem(child: const Text('Изменить'), onTap: () {
                  showDialog(context: context, builder:(context) {
                    return Center(
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        margin: const EdgeInsets.all(15),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(12))
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(widget.product.id),
                              Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      TextInput(
                                          controller: nameController,
                                          hintText: 'Морковь',
                                          labelText: 'Название'),
                                      TextInput(
                                          controller: subnameController,
                                          hintText: 'Морковь очищеная',
                                          labelText: 'Короткое название'),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: BlocBuilder<GenericBloc<Nomenclature>,
                                          GenericState<Nomenclature>>(
                                      builder: (context, state) {
                                    if (state is ItemsLoaded<Nomenclature>) {
                                      return DropdownMenu(
                                          controller: categoryController,
                                          onSelected: (value) => setState(() {
                                                validCategory = true;
                                              }),
                                          hintText: 'Выберете категорию',
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              70,
                                          leadingIcon:
                                              const Icon(Icons.category),
                                          dropdownMenuEntries: List.generate(
                                              state.items.length, (index) {
                                            return DropdownMenuEntry(
                                                value: index,
                                                label: state.items[index].name);
                                          }));
                                    }
                              
                                    return const SizedBox.shrink();
                                  }),
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      const Text('Сроки указываются в часах'),
                                      TextInput(
                                          controller: defrostingController,
                                          hintText: '100',
                                          labelText: 'Разморозка',
                                          type: TextInputType.number,
                                          icon: Icons.ac_unit),
                                      TextInput(
                                          controller: closedTimeController,
                                          hintText: '100',
                                          labelText: 'Срок закрытого хранения',
                                          type: TextInputType.number,
                                          icon: Icons.close_fullscreen),
                                      TextInput(
                                          controller: openedTimeController,
                                          hintText: '100',
                                          labelText: 'Срок открытого хранения',
                                          type: TextInputType.number,
                                          icon: Icons.open_with),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              ElevatedButton(
                                  onPressed: () {
                                    Product newProduct = Product(
                                      id: widget.product.id,
                                      title: nameController.text, 
                                      subtitle: subnameController.text, 
                                      defrosting: int.parse(defrostingController.text), 
                                      closedTime: int.parse(closedTimeController.text), 
                                      openedTime: int.parse(openedTimeController.text), 
                                      category: categoryController.text,
                                      isHide: widget.product.isHide
                                    );

                                    widget.bloc.add(UpdateItem<Product>(newProduct));
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Данные обновлены.')));
                                    
                                    Navigator.pop(context);
                                    dispose();
                                  },
                                  child: const Text('Сохранить изменения'))
                            ],
                          ),
                      ),
                    );
                  },);
                },),
                PopupMenuItem(child:  Text(widget.product.isHide ? 'Убрать из скрытых' : 'Скрыть'), onTap: () {
                  widget.bloc.add(UpdateItem<Product>(widget.product.copyWith(
                    isHide: !widget.product.isHide
                  )));
                },),
                PopupMenuItem(child: const Text('Удалить'), onTap: () {
                  widget.bloc.add(DeleteItem<Product>(widget.product.id));  
                },)
              ];
            }) : null,
          ),
          ListTile(
            title: Text(widget.product.category),
            trailing:
                IconButton(onPressed: () {}, icon: const Icon(Icons.print)),
            subtitle: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Разморозка: ${widget.product.defrosting}ч."),
                Text('Хранение (о): ${widget.product.openedTime}ч.'),
                Text('Хранение (з): ${widget.product.closedTime}ч.'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
