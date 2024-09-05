import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_usb_printer_plugin/flutter_usb_printer_plugin.dart';
import 'package:flutter_usb_printer_plugin/flutter_usb_printer_plugin_platform_interface.dart';
import 'package:flutter_usb_printer_plugin/flutter_usb_printer_plugin_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterUsbPrinterPluginPlatform
    with MockPlatformInterfaceMixin
    implements FlutterUsbPrinterPluginPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final FlutterUsbPrinterPluginPlatform initialPlatform = FlutterUsbPrinterPluginPlatform.instance;

  test('$MethodChannelFlutterUsbPrinterPlugin is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterUsbPrinterPlugin>());
  });

  test('getPlatformVersion', () async {
    FlutterUsbPrinterPlugin flutterUsbPrinterPlugin = FlutterUsbPrinterPlugin();
    MockFlutterUsbPrinterPluginPlatform fakePlatform = MockFlutterUsbPrinterPluginPlatform();
    FlutterUsbPrinterPluginPlatform.instance = fakePlatform;

    expect(await flutterUsbPrinterPlugin.getPlatformVersion(), '42');
  });
}
