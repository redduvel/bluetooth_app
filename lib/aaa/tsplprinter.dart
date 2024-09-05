import 'dart:ffi';  // FFI библиотека
import 'package:ffi/ffi.dart';  // Для работы с указателями
import 'dart:io';

typedef ConnectToPrinterNative = Int32 Function(Pointer<Utf8>);
typedef ConnectToPrinterDart = int Function(Pointer<Utf8>);

typedef SendTSPLCommandNative = Int8 Function(Int32, Pointer<Utf8>);
typedef SendTSPLCommandDart = int Function(int, Pointer<Utf8>);

typedef DisconnectPrinterNative = Void Function(Int32);
typedef DisconnectPrinterDart = void Function(int);

class TSPLPrinter {
  late DynamicLibrary _library;
  late ConnectToPrinterDart _connectToPrinter;
  late SendTSPLCommandDart _sendTSPLCommand;
  late DisconnectPrinterDart _disconnectPrinter;

  TSPLPrinter() {
    if (Platform.isWindows) {
      _library = DynamicLibrary.open('fusbprinter.dll'); // Подключение библиотеки
    } else {
      throw UnsupportedError('Платформа не поддерживается');
    }

    _connectToPrinter = _library
        .lookup<NativeFunction<ConnectToPrinterNative>>('connect_to_printer')
        .asFunction();

    _sendTSPLCommand = _library
        .lookup<NativeFunction<SendTSPLCommandNative>>('send_tspl_command')
        .asFunction();

    _disconnectPrinter = _library
        .lookup<NativeFunction<DisconnectPrinterNative>>('disconnect_printer')
        .asFunction();
  }

  int connect(String printerPort) {
    final portPointer = printerPort.toNativeUtf8();
    final printerHandle = _connectToPrinter(portPointer);
    malloc.free(portPointer);
    return printerHandle;
  }

  bool sendCommand(int printerHandle, String command) {
    final commandPointer = command.toNativeUtf8();
    final result = _sendTSPLCommand(printerHandle, commandPointer);
    malloc.free(commandPointer);
    return result == 1;
  }

  void disconnect(int printerHandle) {
    _disconnectPrinter(printerHandle);
  }
}
