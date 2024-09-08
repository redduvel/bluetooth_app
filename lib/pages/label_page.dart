
import 'package:bluetooth_app/bloc/bloc.bloc.dart';
import 'package:bluetooth_app/bloc/printer/printer.bloc.dart';
import 'package:bluetooth_app/bloc/printer/printer.event.dart';
import 'package:bluetooth_app/bloc/printer/printer.state.dart';
import 'package:bluetooth_app/models/employee.dart';
import 'package:bluetooth_app/pages/tabs/products_tab.dart';
import 'package:bluetooth_app/widgets/text_feild.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class LabelPage extends StatefulWidget {
  const LabelPage({super.key});

  @override
  State<LabelPage> createState() => _LabelPageState();
}

class _LabelPageState extends State<LabelPage> {
  late PrinterBloc printerBloc;

  @override
  void initState() {
    super.initState();
      printerBloc = context.read<PrinterBloc>();
      printerBloc.add(InitializePrinter());
    
  }

  @override
  Widget build(BuildContext context) {
    final employeeName =
        context.read<GenericBloc<Employee>>().repository.currentItem.fullName;

    return Scaffold(
      appBar: AppBar(
        title: Text(employeeName),
        centerTitle: false,
        actions: [
          BlocBuilder<PrinterBloc, PrinterState>(
            builder: (context, state) {
              if (state is PrinterLoading) {
                return const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: SpinKitFadingCircle(
                    color: Colors.orange,
                    size: 25.0,
                  ),
                );
              }

              return IconButton(
                onPressed: () => _showPrinterSettings(context),
                icon: Icon(
                  printerBloc.connectedDevice != null
                      ? Icons.print
                      : Icons.print_disabled,
                  color: printerBloc.connectedDevice != null
                      ? Colors.green
                      : Colors.red,
                ),
              );
            },
          ),
        ],
      ),
      body: const ProductsTab(
        showProductTools: false,
        showFloatingActionButton: false,
        showHideEnemies: false,
        isSetting: false,
        gridCrossAxisCount: 2,
        gridChilAspectRatio: 1 / 1,
      ),
    );
  }

  void _showPrinterSettings(BuildContext context) {
    showBarModalBottomSheet(
      context: context,
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height / 2,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: BlocBuilder<PrinterBloc, PrinterState>(
              bloc: printerBloc,
              builder: (context, state) {
                return CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      backgroundColor: Colors.transparent,
                      title: const Text('Настройки Bluetooth'),
                      automaticallyImplyLeading: false,
                      actions: [
                        IconButton(
                            onPressed: () {
                              printerBloc.add(InitializePrinter());
                            },
                            icon: const Icon(Icons.refresh)),
                        IconButton(
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    TextEditingController heightController =
                                        TextEditingController(
                                            text: printerBloc.labelHeigth);
                                    TextEditingController widthController =
                                        TextEditingController(
                                            text: printerBloc.labelWidth);
                                    TextEditingController gapController =
                                        TextEditingController(
                                            text: printerBloc.labelGap);
                                    return AlertDialog(
                                      title: const Text('Настройки этикетки'),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          TextInput(
                                              controller: heightController,
                                              hintText: '20',
                                              labelText:
                                                  'Высота этикетки (mm)'),
                                          TextInput(
                                              controller: widthController,
                                              hintText: '30',
                                              labelText:
                                                  'Ширина этикетки (mm)'),
                                          TextInput(
                                              controller: gapController,
                                              hintText: '2',
                                              labelText:
                                                  'Расстояние между этикетками (mm)'),
                                        ],
                                      ),
                                      actions: [
                                        ElevatedButton(
                                            onPressed: () {
                                              printerBloc.add(SetSettings(
                                                  height: heightController.text,
                                                  width: widthController.text,
                                                  gap: gapController.text));
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(const SnackBar(
                                                      content: Text(
                                                          'Настройки этикетки изменены!')));
                                              Navigator.pop(context);
                                            },
                                            child: const Text('Подтвердить'))
                                      ],
                                    );
                                  });
                            },
                            icon: const Icon(Icons.settings))
                      ],
                    ),
                    if (state is PrinterLoading)
                      const SliverToBoxAdapter(
                        child: Center(
                            child: SpinKitFadingCircle(
                          color: Colors.orange,
                          size: 40,
                        )),
                      ),
                    if (state is DevicesLoaded) _buildDeviceList(state.devices),
                    if (state is PrinterDisconnected)
                      const SliverToBoxAdapter(child: Center(child: Text('Принтер отключен'))),
                    if (state is PrinterConnected)
                      _buildDeviceList(printerBloc.devices)
                  ],
                );

              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildDeviceList(List<BluetoothDevice> devices) {
    final devicess = devices.where((d) => d.platformName != '').toList();

    return 
      SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final device = devicess[index];
            return ListTile(
              title: Text(device.platformName),
              subtitle: Text(device.remoteId.toString()),
              onTap: () => printerBloc.add(ConnectToDevice(device)),
              trailing: printerBloc.connectedDevice == device
                ? const Text(
                    'Подключено',
                    style: TextStyle(color: Colors.green),
                  )
                : null,
            );
          },
          childCount: devicess.length,
        ),
      );
  }
}
