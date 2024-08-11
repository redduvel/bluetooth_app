// printer.bloc.dart
import 'dart:convert';
import 'package:bluetooth_app/bloc/printer.event.dart';
import 'package:bluetooth_app/bloc/printer.state.dart';
import 'package:bluetooth_app/models/template_item.dart';
import 'package:bluetooth_print/bluetooth_print.dart';
import 'package:bluetooth_print/bluetooth_print_model.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BluetoothBloc extends Bloc<BluetoothEvent, BluetoothState> {
  final BluetoothPrint bluetoothPrint = BluetoothPrint.instance;

  BluetoothBloc() : super(BluetoothInitial()) {
    on<StartScan>((event, emit) async {
      bluetoothPrint.startScan(timeout: Duration(seconds: 4));
      emit(BluetoothScanning());
    });

    on<StopScan>((event, emit) async {
      bluetoothPrint.stopScan();
      emit(BluetoothInitial());
    });

    on<ConnectDevice>((event, emit) async {
      await bluetoothPrint.connect(event.device);
      emit(BluetoothConnected(event.device));
    });

    on<DisconnectDevice>((event, emit) async {
      await bluetoothPrint.disconnect();
      emit(BluetoothDisconnected());
    });

    on<PrintReceipt>((event, emit) async {
      try {
        Map<String, dynamic> config = {};
        List<LineText> list = [
          LineText(
              type: LineText.TYPE_TEXT,
              content: '**********************************************',
              weight: 1,
              align: LineText.ALIGN_CENTER,
              linefeed: 1),
          LineText(
              type: LineText.TYPE_TEXT,
              content: '打印单据头',
              weight: 1,
              align: LineText.ALIGN_CENTER,
              fontZoom: 2,
              linefeed: 1),
          LineText(linefeed: 1),
          LineText(
              type: LineText.TYPE_TEXT,
              content: '----------------------明细---------------------',
              weight: 1,
              align: LineText.ALIGN_CENTER,
              linefeed: 1),
          LineText(
              type: LineText.TYPE_TEXT,
              content: '物资名称规格型号',
              weight: 1,
              align: LineText.ALIGN_LEFT,
              x: 0,
              relativeX: 0,
              linefeed: 0),
          LineText(
              type: LineText.TYPE_TEXT,
              content: '单位',
              weight: 1,
              align: LineText.ALIGN_LEFT,
              x: 350,
              relativeX: 0,
              linefeed: 0),
          LineText(
              type: LineText.TYPE_TEXT,
              content: '数量',
              weight: 1,
              align: LineText.ALIGN_LEFT,
              x: 500,
              relativeX: 0,
              linefeed: 1),
          LineText(
              type: LineText.TYPE_TEXT,
              content: '混凝土C30',
              align: LineText.ALIGN_LEFT,
              x: 0,
              relativeX: 0,
              linefeed: 0),
          LineText(
              type: LineText.TYPE_TEXT,
              content: '吨',
              align: LineText.ALIGN_LEFT,
              x: 350,
              relativeX: 0,
              linefeed: 0),
          LineText(
              type: LineText.TYPE_TEXT,
              content: '12.0',
              align: LineText.ALIGN_LEFT,
              x: 500,
              relativeX: 0,
              linefeed: 1),
          LineText(
              type: LineText.TYPE_TEXT,
              content: '**********************************************',
              weight: 1,
              align: LineText.ALIGN_CENTER,
              linefeed: 1),
          LineText(linefeed: 1),
        ];

        await bluetoothPrint.printReceipt(config, list);
        emit(BluetoothPrintSuccess());
      } catch (e) {
        emit(BluetoothPrintFailure(e.toString()));
      }
    });

    on<PrintLabel>((event, emit) async {
      try {
        Map<String, dynamic> config = {
          'width': 40,
          'height': 70,
          'gap': 2,
        };

        List<LineText> list = [
          LineText(type: LineText.TYPE_TEXT, x: 10, y: 10, content: 'A Title'),
          LineText(
              type: LineText.TYPE_TEXT,
              x: 10,
              y: 40,
              content: 'this is content'),
          LineText(
              type: LineText.TYPE_QRCODE, x: 10, y: 70, content: 'qrcode i\n'),
          LineText(
              type: LineText.TYPE_BARCODE,
              x: 10,
              y: 190,
              content: 'qrcode i\n'),
        ];

        ByteData data = await rootBundle.load("assets/images/guide3.png");
        List<int> imageBytes =
            data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
        String base64Image = base64Encode(imageBytes);
        List<LineText> list1 = [
          LineText(
              type: LineText.TYPE_IMAGE, x: 10, y: 10, content: base64Image)
        ];

        await bluetoothPrint.printLabel(config, list);
        await bluetoothPrint.printLabel(config, list1);
        emit(BluetoothPrintSuccess());
      } catch (e) {
        emit(BluetoothPrintFailure(e.toString()));
      }
    });

    on<PrintTest>((event, emit) async {
      try {
        await bluetoothPrint.printTest();
        emit(BluetoothPrintSuccess());
      } catch (e) {
        emit(BluetoothPrintFailure(e.toString()));
      }
    });

    on<AddTemplateItem>((event, emit) {
      final updatedItems = List<TemplateItem>.from(state.templateItems)
        ..add(event.item);
      emit(state.copyWith(templateItems: updatedItems));
    });

    on<RemoveTemplateItem>((event, emit) {
      final updatedItems = List<TemplateItem>.from(state.templateItems)
        ..removeAt(event.index);
      emit(state.copyWith(templateItems: updatedItems));
    });

    on<PrintTemplate>((event, emit) async {
      if (state.templateItems.isEmpty) {
        emit(BluetoothPrintFailure("No content to print"));
        return;
      }

      try {
        Map<String, dynamic> config = {};
        List<LineText> list = [];

        for (var item in state.templateItems) {
          if (item is TemplateParagraph) {
            list.add(LineText(
                type: LineText.TYPE_TEXT,
                content: item.content,
                align: LineText.ALIGN_LEFT,
                linefeed: 1));
          } else if (item is TemplateImage) {
            ByteData data = await rootBundle.load(item.path);
            List<int> imageBytes =
                data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
            String base64Image = base64Encode(imageBytes);
            list.add(LineText(
                type: LineText.TYPE_IMAGE,
                content: base64Image,
                align: LineText.ALIGN_CENTER,
                linefeed: 1));
          }
        }

        await bluetoothPrint.printReceipt(config, list);
        emit(BluetoothPrintSuccess());
      } catch (e) {
        emit(BluetoothPrintFailure(e.toString()));
      }
    });
  }
}
