import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:image/image.dart' as img;

class ImageService {
  Future<Map<String, dynamic>> createLabelWithText(String product, String name, double width, double height,
      {String? startDate, String? endDate}) async {
    const int dpi = 203;
    double widthMm = width;
    double heightMm = height;
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
        img.Pixel pixel = monoImage.getPixel(x, y);
        num luminance = img.getLuminance(pixel);
        monoImage.setPixel(
            x,
            y,
            luminance < 128
                ? img.ColorRgba8(0, 0, 0, 255)
                : img.ColorRgba8(255, 225, 255, 255));
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
            img.Pixel pixel = image.getPixel(x, y);
            num luminance = img.getLuminance(pixel);
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

  Future<pw.Document> generatePdf(
      int count, PdfPageFormat format, String subtitle, String fullName,
      {String? startDate, String? endDate}) async {
    final pdf = pw.Document(version: PdfVersion.pdf_1_5, compress: true);
    final ttf = await fontFromAssetBundle('assets/fonts/roboto.ttf');

    for (var i = 0; i < count; i++) {
      pdf.addPage(
        pw.Page(
          margin: const pw.EdgeInsets.all(2),
          pageFormat: format,
          build: (pw.Context context) {
            return pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text(subtitle, style: pw.TextStyle(font: ttf, fontSize: 10)),
                if (startDate != null)
                  pw.Text(startDate,
                      style: pw.TextStyle(font: ttf, fontSize: 10)),
                if (endDate != null)
                  pw.Text(endDate,
                      style: pw.TextStyle(font: ttf, fontSize: 10)),
                pw.Text(fullName, style: pw.TextStyle(font: ttf, fontSize: 10))
              ],
            );
          },
        ),
      );
    }

    return pdf;
  }
}
