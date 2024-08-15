import 'package:bluetooth_app/bloc/printer/printer.bloc.dart';
import 'package:bluetooth_app/bloc/printer/printer.event.dart';
import 'package:bluetooth_app/bloc/printer/printer.state.dart';
import 'package:bluetooth_app/bloc/tspl/tspl.bloc.dart';
import 'package:bluetooth_app/bloc/tspl/tspl.event.dart';
import 'package:bluetooth_app/bloc/tspl/tspl.state.dart';
import 'package:bluetooth_app/pages/tabs/products_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';

class LabelPage extends StatefulWidget {
  const LabelPage({super.key});

  @override
  State<LabelPage> createState() => _LabelPageState();
}

class _LabelPageState extends State<LabelPage> {
  late PrinterBloc bloc;

  @override
  void initState() {
    bloc = context.read<PrinterBloc>();
    bloc.add(InitializePrinter());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<TsplBloc, TsplState>(
          builder: (context, state) => ListTile(
            title:
                Text(context.read<TsplBloc>().currentEmployee!.fullName),
            subtitle: Text(
              context.read<TsplBloc>().editTemplate
                  ? 'Измененный шаблон'
                  : 'Стандартный шаблон',
              style: TextStyle(
                  color: context.read<TsplBloc>().editTemplate
                      ? Colors.red
                      : null),
            ),
          ),
        ),
        actions: [
          IconButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) => BottomSheet(
                    onClosing: () {},
                    builder: (context) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: BlocBuilder<PrinterBloc, PrinterState>(
                          bloc: bloc,
                            builder: (context, state) {
                          if (state is DevicesLoaded) {
                            return CustomScrollView(
                              slivers: [
                                SliverAppBar(
                                  backgroundColor: Colors.transparent,
                                  title: const Text('Настройки Bluetooth'),
                                  actions: [
                                    IconButton(
                                        onPressed: () {
                                          bloc.add(InitializePrinter());
                                        },
                                        icon: const Icon(Icons.refresh))
                                  ],
                                  automaticallyImplyLeading: false,
                                ),
                                SliverList(delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    return ListTile(
                                      title: Text(state.devices[index].name),
                                      subtitle: Text(state.devices[index].id.toString()),
                                      onTap: () => bloc.add(ConnectToDevice(state.devices[index])),
                                      trailing: bloc.connectedDevice == state.devices[index]
                                          ? const Text('Подключено',
                                              style: TextStyle(color: Colors.green))
                                          : null,
                                    );
                                  },
                                  childCount: state.devices.length
                                ))
                              ],
                            );
                          }

                          if (state is PrinterLoading) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          if (state is PrinterDisconnected) {
                            return const Center(
                              child: Text('Принтер отключен'),
                            );
                          }

                          if (state is PrinterConnected) {
                            return CustomScrollView(
                              slivers: [
                                SliverAppBar(
                                  backgroundColor: Colors.transparent,
                                  title: const Text('Настройки Bluetooth'),
                                  actions: [
                                    IconButton(
                                        onPressed: () {},
                                        icon: const Icon(Icons.refresh))
                                  ],
                                  automaticallyImplyLeading: false,
                                ),
                                SliverList(delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    return ListTile(
                                      title: Text(bloc.devicesList[index].name),
                                      subtitle: Text(bloc.devicesList[index].id.toString()),
                                      onTap: () => bloc.add(ConnectToDevice(bloc.devicesList[index])),
                                      trailing: bloc.connectedDevice == bloc.devicesList[index]
                                          ? const Text('Подключено',
                                              style: TextStyle(color: Colors.green))
                                          : null,
                                    );
                                  },
                                  childCount: bloc.devicesList.length
                                ))
                              ],
                            );
                          }

                          return const Center(
                            child: Text('Неизвестное состояние'),
                          );
                        }),
                      );
                    },
                  ),
                );
              },
              icon: const Icon(Icons.settings)),
          IconButton(
            onPressed: () {
              DatePicker.showDateTimePicker(context,
                  showTitleActions: true,
                  minTime: DateTime(2024, 1, 1),
                  maxTime: DateTime(2100, 12, 29), onConfirm: (date) {
                context.read<TsplBloc>().add(SetSelectedTime(date));
              },
                  currentTime: context.read<TsplBloc>().adjustmentTime,
                  locale: LocaleType.ru);
            },
            icon: const Icon(Icons.schedule),
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.all(0),
            iconSize: 24,
          )
        ],
      ),
      body: const ProductsTab(
        showProductTools: false,
        showFloatingActionButton: false,
        showHideProducts: false,
        isSetting: false,
        gridCrossAxisCount: 3,
        gridChilAspectRatio: 1 / 1.3,
      ),
    );
  }
}
