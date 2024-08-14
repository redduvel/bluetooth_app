import 'package:bluetooth_app/bloc/printer/printer.bloc.dart';
import 'package:bluetooth_app/bloc/printer/printer.event.dart';
import 'package:bluetooth_app/bloc/printer/printer.state.dart';
import 'package:bluetooth_app/pages/tspl_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ConnectionPage extends StatefulWidget {
  const ConnectionPage({super.key});

  @override
  State<ConnectionPage> createState() => _ConnectionPageState();
}

class _ConnectionPageState extends State<ConnectionPage> {
  late PrinterBloc bloc;

  @override
  void initState() {
    bloc = context.read<PrinterBloc>()..add(InitializePrinter());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ТЕСТ ПОДКЛЮЧЕНИЯ И ПЕЧАТИ'),
      ),
      body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: CustomScrollView(slivers: [
            SliverToBoxAdapter(
              child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const TsplEditorPage()));
                  },
                  child: const Text('Редактор этикетки')),
            ),
            SliverToBoxAdapter(
              child: BlocBuilder<PrinterBloc, PrinterState>(
                builder: (context, state) {
                  if (state is PrinterLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is DevicesLoaded) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            bloc.add(ScanForDevices());
                          },
                          child: const Text('Сканировать'),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Устройства:',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: state.devices.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                title: Text(state.devices[index].name ?? ''),
                                subtitle:
                                    Text(state.devices[index].address ?? ''),
                                trailing: (state.connectedDevice != null &&
                                        state.connectedDevice ==
                                            state.devices[index])
                                    ? const Text('Подключено',
                                        style: TextStyle(color: Colors.green))
                                    : null,
                                onTap: () {
                                  bloc.add(
                                      ConnectToDevice(state.devices[index]));
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  } else if (state is PrinterConnected) {
                    return Column(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            bloc.add(DisconnectFromDevice());
                          },
                          child: const Text('Отключиться'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            bloc.add(PrintLabel());
                          },
                          child: const Text('Печатать этикетку'),
                        ),
                      ],
                    );
                  } else {
                    return const Center(
                        child: Text('Нет подключенных устройств.'));
                  }
                },
              ),
            ),
          ])),
    );
  }
}
