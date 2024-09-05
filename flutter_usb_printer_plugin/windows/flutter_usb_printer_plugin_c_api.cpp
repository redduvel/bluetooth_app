#include "include/flutter_usb_printer_plugin/flutter_usb_printer_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "flutter_usb_printer_plugin.h"

void FlutterUsbPrinterPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  flutter_usb_printer_plugin::FlutterUsbPrinterPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
