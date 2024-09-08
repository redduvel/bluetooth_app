import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'dart:ui' as ui;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;

class ImageUtils {
  Future<Map<String, dynamic>> createLabelWithText(
      String product, String name, {String? startDate, String? endDate}) async {
    const int dpi = 203;
    const double widthMm = 30.0;
    const double heightMm = 20.0;

    final int widthPx = (widthMm * dpi / 25.4).round();
    final int heightPx = (heightMm * dpi / 25.4).round();

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(
        recorder,
        Rect.fromPoints(const Offset(0, 0),
            Offset(widthPx.toDouble(), heightPx.toDouble())));

    final paint = Paint()..color = Colors.black;
    canvas.drawRect(
        Rect.fromLTWH(0, 0, widthPx.toDouble(), heightPx.toDouble()), paint);

    const textStyle = TextStyle(
      color: Colors.white,
      fontSize: 23,
      fontWeight: FontWeight.w700,
      fontFamily: 'Roboto',
    );

    if (startDate == null && endDate == null) {
      final texts = [product, name];

      double offsetY = 30;
      for (var txt in texts) {
        final textSpan = TextSpan(text: txt, style: textStyle);
        final textPainter = TextPainter(
          text: textSpan,
          textAlign: TextAlign.left,
          textDirection: TextDirection.ltr,
        );
        textPainter.layout(minWidth: 0, maxWidth: widthPx.toDouble());
        final offsetX = (widthPx - textPainter.width) / 2;
        textPainter.paint(canvas, Offset(offsetX, offsetY));
        offsetY += textPainter.height + 25;
      }
    } else {
      final texts = [product, startDate, endDate, name];

      double offsetY = 0;
      for (var txt in texts) {
        final textSpan = TextSpan(text: txt, style: textStyle);
        final textPainter = TextPainter(
          text: textSpan,
          textAlign: TextAlign.left,
          textDirection: TextDirection.ltr,
        );
        textPainter.layout(minWidth: 0, maxWidth: widthPx.toDouble());
        final offsetX = (widthPx - textPainter.width) / 2;
        textPainter.paint(canvas, Offset(offsetX, offsetY));
        offsetY += textPainter.height + 10;
      }
    }



    final picture = recorder.endRecording();
    final image = await picture.toImage(widthPx, heightPx);

    final ByteData? byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List imageData = byteData!.buffer.asUint8List();
    final img.Image labelImage = img.decodePng(imageData)!;

    img.Image monoImage = img.grayscale(labelImage);
    for (int y = 0; y < monoImage.height; y++) {
      for (int x = 0; x < monoImage.width; x++) {
        int pixel = monoImage.getPixel(x, y);
        int luminance = img.getLuminance(pixel);
        monoImage.setPixel(x, y, luminance < 128 ? 0xFF000000 : 0xFFFFFFFF);
      }
    }

    final bmpPath = await saveBmpImage(monoImage, 'label.bmp');
    final bmpData = await loadBmpImageData(bmpPath);
    final imageDataForPrinting = await getImageDataFromBmp(bmpData);

    return {'data': imageDataForPrinting, 'image': monoImage};
  }

  Future<List<List<int>>> getImageDataFromBmp(Uint8List bmpData) async {
    final image = img.decodeBmp(bmpData);
    if (image == null) {
      throw Exception('Не удалось декодировать BMP изображение.');
    }

    final widthInBytes = (image.width / 8).ceil();
    final data = List<List<int>>.generate(
      image.height,
      (y) {
        return List<int>.generate(widthInBytes, (b) {
          int byte = 0;
          int mask = 128;
          for (int x = b * 8; x < (b + 1) * 8; x++) {
            if (x >= image.width) break;
            int pixel = image.getPixel(x, y);
            int luminance = img.getLuminance(pixel);
            if (luminance < 128) byte = byte ^ mask;
            mask >>= 1;
          }

          return byte;
        });
      },
    );

    return data;
  }

  Future<String> saveBmpImage(img.Image image, String filename) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/$filename';
    final file = File(path);

    final bmpData = img.encodeBmp(image);
    await file.writeAsBytes(bmpData);

    return path;
  }

  Future<Uint8List> loadBmpImageData(String path) async {
    final file = File(path);
    return file.readAsBytesSync();
  }

  Future<pw.Document> generatePdf(String subtitle, String fullName, {String? startDate, String? endDate}) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Product: $subtitle', style: const pw.TextStyle(fontSize: 18)),
              pw.Text('Employee: $fullName', style: const pw.TextStyle(fontSize: 18)),
              if (startDate != null) pw.Text('Start: $startDate', style: const pw.TextStyle(fontSize: 18)),
              if (endDate != null) pw.Text('End: $endDate', style: const pw.TextStyle(fontSize: 18)),
            ],
          );
        },
      ),
    );

    return pdf;
  }
}
