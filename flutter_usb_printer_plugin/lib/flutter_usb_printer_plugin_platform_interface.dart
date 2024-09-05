import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_usb_printer_plugin_method_channel.dart';

abstract class FlutterUsbPrinterPluginPlatform extends PlatformInterface {
  /// Constructs a FlutterUsbPrinterPluginPlatform.
  FlutterUsbPrinterPluginPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterUsbPrinterPluginPlatform _instance = MethodChannelFlutterUsbPrinterPlugin();

  /// The default instance of [FlutterUsbPrinterPluginPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterUsbPrinterPlugin].
  static FlutterUsbPrinterPluginPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterUsbPrinterPluginPlatform] when
  /// they register themselves.
  static set instance(FlutterUsbPrinterPluginPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
