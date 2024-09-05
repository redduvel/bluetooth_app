#ifndef FLUTTER_PLUGIN_FLUTTER_USB_PRINTER_PLUGIN_H_
#define FLUTTER_PLUGIN_FLUTTER_USB_PRINTER_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace flutter_usb_printer_plugin {

class FlutterUsbPrinterPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  FlutterUsbPrinterPlugin();

  virtual ~FlutterUsbPrinterPlugin();

  // Disallow copy and assign.
  FlutterUsbPrinterPlugin(const FlutterUsbPrinterPlugin&) = delete;
  FlutterUsbPrinterPlugin& operator=(const FlutterUsbPrinterPlugin&) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace flutter_usb_printer_plugin

#endif  // FLUTTER_PLUGIN_FLUTTER_USB_PRINTER_PLUGIN_H_
