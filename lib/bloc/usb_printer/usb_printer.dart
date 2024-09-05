import 'package:flutter/services.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';

class USBPrinterService {
  SerialPort? _printerPort;

  // Метод для поиска и подключения к USB-принтеру
  bool connectToPrinter(String vendorId, String productId) {
    // Получаем список всех доступных устройств
    final availablePorts = SerialPort.availablePorts;

    for (var portName in availablePorts) {
      final port = SerialPort(portName);

      // Проверяем, совпадают ли Vendor ID и Product ID
      final vid = port.vendorId?.toRadixString(16);
      final pid = port.productId?.toRadixString(16);
      
      if (vid == vendorId && pid == productId) {
        _printerPort = port;
        
        if (_printerPort!.openReadWrite()) {
          print('Подключен к принтеру $portName');
          return true;
        }
      }
    }

    print('Принтер не найден');
    return false;
  }

  // Метод для отправки TSPL-команды на принтер
  void sendPrintCommand(String command) {
    if (_printerPort != null && _printerPort!.isOpen) {
      final bytes = Uint8List.fromList(command.codeUnits);
      _printerPort!.write(bytes);
      print('Команда отправлена: $command');
    } else {
      print('Подключение к принтеру не установлено');
    }
  }

  // Метод для закрытия порта после использования
  void disconnect() {
    if (_printerPort != null) {
      _printerPort!.close();
      print('Соединение с принтером закрыто');
    }
  }
}

void main() {
  final printerService = USBPrinterService();
  
  // Подключаемся к принтеру, используя Vendor ID и Product ID
  if (printerService.connectToPrinter('vendor_id', 'product_id')) {
    // Отправляем TSPL-команду на печать
    printerService.sendPrintCommand('SIZE 30 mm, 20 mm\nGAP 3 mm, 0 mm\nTEXT 100,100,"0",0,12,12,"Привет, мир!"\nPRINT 1\n');
    
    // Закрываем соединение
    printerService.disconnect();
  }
}
