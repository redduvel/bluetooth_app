
import 'package:bluetooth_app/clean/config/theme/colors.dart';
import 'package:bluetooth_app/clean/config/theme/text_styles.dart';
import 'package:bluetooth_app/clean/core/Presentation/widgets/primary_button.dart';
import 'package:bluetooth_app/clean/core/Presentation/widgets/primary_textfield.dart';
import 'package:bluetooth_app/clean/features/printing/Presentation/bloc/printer.bloc.dart';
import 'package:bluetooth_app/clean/features/printing/Presentation/bloc/printer.event.dart';
import 'package:bluetooth_app/clean/features/printing/Presentation/bloc/printer.state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:universal_io/io.dart';

class PrintingSettingPage extends StatefulWidget {
  const PrintingSettingPage({super.key});

  @override
  State<PrintingSettingPage> createState() => _PrintingSettingPageState();
}

class _PrintingSettingPageState extends State<PrintingSettingPage> {
  late PrinterBloc printerBloc;

  @override
  void initState() {
    super.initState();
    printerBloc = context.read<PrinterBloc>();
    printerBloc.add(InitializePrinter());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: BlocBuilder<PrinterBloc, PrinterState>(builder: (context, state) {
        return CustomScrollView(
          slivers: [
            if (Platform.isIOS || Platform.isAndroid)
            SliverAppBar(
              
              backgroundColor: AppColors.white,
              title: Text(
                'Управление принтером',
                style: AppTextStyles.labelMedium18.copyWith(fontSize: 24),
              ),
              centerTitle: false,
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
                                    text:  printerBloc.labelHeigth);
                            TextEditingController widthController =
                                TextEditingController(
                                    text:  printerBloc.labelWidth);
                            TextEditingController gapController =
                                TextEditingController(
                                    text:  printerBloc.labelGap);
                            return AlertDialog(
                              title: const Text('Настройка этикетки', style: AppTextStyles.labelMedium18,),
                              backgroundColor: AppColors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4)
                              ),
                              contentPadding: const EdgeInsets.all(2),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  PrimaryTextField(
                                      controller: heightController,
                                      hintText: '20',
                                      width: double.infinity,
                                      ),
                                  PrimaryTextField(
                                      controller: widthController,
                                      hintText: '30',
                                      width: double.infinity,),
                                  PrimaryTextField(
                                      controller: gapController,
                                      hintText: '2',
                                      width: double.infinity,),
                                ],
                              ),
                              actions: [
                                PrimaryButtonIcon(text: 'Сохранить', icon: Icons.save, onPressed: () {
                                       printerBloc.add(SetSettings(
                                          height: heightController.text,
                                          width: widthController.text,
                                          gap: gapController.text));
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                              content: Text(
                                                  'Настройки этикетки изменены!')));
                                      Navigator.pop(context);
                                    },)
                                
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
              const SliverToBoxAdapter(
                  child: Center(child: Text('Принтер отключен'))),
            if (state is PrinterConnected) _buildDeviceList(printerBloc.devices)
          ],
        );
      }),
    );
  }

  Widget _buildDeviceList(List<BluetoothDevice> devices) {
    final devicess = devices.where((d) => d.platformName != '').toList();

    return SliverList(
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
