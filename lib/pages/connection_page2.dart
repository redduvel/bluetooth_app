import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'dart:convert';
import 'dart:typed_data';

class BluetoothScreen extends StatefulWidget {
  const BluetoothScreen({super.key});

  @override
  _BluetoothScreenState createState() => _BluetoothScreenState();
}

class _BluetoothScreenState extends State<BluetoothScreen> {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  List<BluetoothDevice> devicesList = [];
  BluetoothDevice? connectedDevice;
  BluetoothCharacteristic? characteristic;

  @override
  void initState() {
    super.initState();
    startScan();
  }

  void startScan() {
    flutterBlue.startScan(timeout: const Duration(seconds: 4));

    flutterBlue.scanResults.listen((results) {
      for (ScanResult r in results) {
        if (!devicesList.contains(r.device)) {
          setState(() {
            devicesList.add(r.device);
          });
        }
      }
    });

    flutterBlue.stopScan();
  }

  void connectToDevice(BluetoothDevice device) async {
    await device.connect();
    setState(() {
      connectedDevice = device;
    });

    discoverServices();
  }

  void discoverServices() async {
    if (connectedDevice == null) return;

    List<BluetoothService> services = await connectedDevice!.discoverServices();
    for (var service in services) {
      for (var char in service.characteristics) {
        if (char.properties.write) {
          setState(() {
            characteristic = char;
          });
        }
      }
    }
  }

  void disconnectFromDevice() async {
    await connectedDevice?.disconnect();
    setState(() {
      connectedDevice = null;
      characteristic = null;
    });
  }

  void printLabel() {
    if (characteristic != null) {
      String tsplCommand = '''
      CLS
      SIZE 30 mm, 20 mm
      GAP 2 mm, 0 mm
      DIRECTION 1
      TEXT 30,15,"2",0,1,1,"Banana"
      TEXT 10,55,"2",0,1,1,"2024-08-15 16:16"
      TEXT 15,95,"2",0,1,1,"2024-08-16 13:16"
      TEXT 30,135,"2",0,1,1,"Ivan Иванов"
      PRINT 1,1
      ''';

      List<int> bytes = utf8.encode(tsplCommand);
      characteristic!.write(Uint8List.fromList(bytes), withoutResponse: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bluetooth Devices'),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: startScan,
            child: const Text('Scan for Devices'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: devicesList.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(devicesList[index].name),
                  subtitle: Text(devicesList[index].id.toString()),
                  onTap: () => connectToDevice(devicesList[index]),
                  trailing: connectedDevice == devicesList[index]
                      ? const Text('Connected',
                          style: TextStyle(color: Colors.green))
                      : null,
                );
              },
            ),
          ),
          if (connectedDevice != null) ...[
            ElevatedButton(
              onPressed: disconnectFromDevice,
              child: const Text('Disconnect'),
            ),
            ElevatedButton(
              onPressed: printLabel,
              child: const Text('Print Label'),
            ),
          ],
        ],
      ),
    );
  }
}
