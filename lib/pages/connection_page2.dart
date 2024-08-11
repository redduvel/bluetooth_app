import 'package:flutter/material.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';

class ConnectionPage extends StatefulWidget {
  const ConnectionPage({super.key});

  @override
  _ConnectionPageState createState() => _ConnectionPageState();
}

class _ConnectionPageState extends State<ConnectionPage> {
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;
  List<BluetoothDevice> devices = [];
  BluetoothDevice? selectedDevice;

  @override
  void initState() {
    super.initState();
    initBluetooth();
  }

  Future<void> initBluetooth() async {
    try {
      bool isConnected = await bluetooth.isConnected ?? false;
      if (!isConnected) {
        devices = await bluetooth.getBondedDevices();
        setState(() {});
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void scanForDevices() async {
    try {
      devices = await bluetooth.getBondedDevices();
      setState(() {});
    } catch (e) {
      print('Error: $e');
    }
  }

  void connectToDevice(BluetoothDevice device) async {
    try {
      await bluetooth.connect(device);
      setState(() {
        selectedDevice = device;
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  void disconnectFromDevice() async {
    try {
      await bluetooth.disconnect();
      setState(() {
        selectedDevice = null;
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  void printLabel() {
    if (selectedDevice != null) {
      String tspl = '''
      SIZE 30 mm, 20 mm
      GAP 3 mm, 0 mm
      CLS

      TEXT 20, 20, "0", 0, 1, 1, "Заголовок"
      TEXT 20, 50, "0", 0, 1, 1, "2024-08-08 23:00"
      TEXT 20, 80, "0", 0, 1, 1, "2024-08-10 15:00"
      TEXT 20, 110, "0", 0, 1, 1, "Фамилия Имя"

      PRINT 1,1
      ''';
      bluetooth.write(tspl);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ТЕСТ ПОДКЛЮЧЕНИЯ И ПЕЧАТИ'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: scanForDevices,
              child: const Text('Сканировать'),
            ),
            const SizedBox(height: 10),
            const Text(
              'Устройства:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: devices.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(devices[index].name ?? ''),
                    subtitle: Text(devices[index].address ?? ''),
                    trailing: selectedDevice == devices[index]
                        ? const Text('Connected', style: TextStyle(color: Colors.green))
                        : null,
                    onTap: () => connectToDevice(devices[index]),
                  );
                },
              ),
            ),
            if (selectedDevice != null) ...[
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: disconnectFromDevice,
                child: const Text('Отключиться'),
                
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: printLabel,
                child: const Text('Печатать этикетку'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}