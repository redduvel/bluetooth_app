
import 'flutter_usb_printer_plugin_platform_interface.dart';

class FlutterUsbPrinterPlugin {
  Future<String?> getPlatformVersion() {
    return FlutterUsbPrinterPluginPlatform.instance.getPlatformVersion();
  }
}
