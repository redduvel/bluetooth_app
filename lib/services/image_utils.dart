import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class ImageUtils {
  Future<Map<String, dynamic>> createLabelWithText(String text) async {
    const int dpi = 203; // DPI для термопринтера
    const double widthMm = 30.0;
    const double heightMm = 20.0;

    final int widthPx = (widthMm * dpi / 25.4).round();
    final int heightPx = (heightMm * dpi / 25.4).round();

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(
        recorder,
        Rect.fromPoints(
            const Offset(0, 0), Offset(widthPx.toDouble(), heightPx.toDouble())));

    // Заливка фона белым цветом
    final paint = Paint()..color = Colors.white;
    paint.color = Colors.amber;
    canvas.drawRect(
        Rect.fromLTWH(0, 0, widthPx.toDouble(), heightPx.toDouble()), paint);

    // Настройка текста
    const textStyle = TextStyle(
      color: Colors.black,
      fontSize: 24,
      fontFamily: 'Roboto',
    );

    // Рисование текстов
    final texts = [
      text,
      '2024-08-08 15:00',
      '2024-08-08 20:00',
      'Ivan Иванов',
    ];

    double offsetY = 0;
    for (var txt in texts) {
      final textSpan = TextSpan(text: txt, style: textStyle);
      final textPainter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout(minWidth: 0, maxWidth: widthPx.toDouble());
      final offsetX = (widthPx - textPainter.width) / 2;
      textPainter.paint(canvas, Offset(offsetX, offsetY));
      offsetY += textPainter.height + 5;
    }

    // Завершение работы с canvas и создание изображения
    final picture = recorder.endRecording();
    final image = await picture.toImage(widthPx, heightPx);

    // Конвертация изображения в байты
    final ByteData? byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List imageData = byteData!.buffer.asUint8List();

    // Преобразование в формат image.dart для дальнейшей обработки
    final img.Image labelImage = img.decodePng(imageData)!;

    // Конвертируем изображение в черно-белое
    img.Image monoImage = img.grayscale(labelImage);
    for (int y = 0; y < monoImage.height; y++) {
      for (int x = 0; x < monoImage.width; x++) {
        int pixel = monoImage.getPixel(x, y);
        int luminance = img.getLuminance(pixel);
        monoImage.setPixel(x, y, luminance < 128 ? 0xFF000000 : 0xFFFFFFFF);
      }
    }

    final bmpPath = await saveBmpImage(monoImage, 'label.bmp');

    // Считываем BMP данные изображения
    final bmpData = await loadBmpImageData(bmpPath);

    
    // Получаем данные изображения для печати
    final imageDataForPrinting = await getImageDataFromBmp(bmpData);

    return {'data': imageDataForPrinting, 'image': monoImage};
  }

  Future<List<List<int>>> getImageDataFromBmp(Uint8List bmpData) async {
    // Конвертируем BMP изображение в формат пригодный для печати (8 бит на пиксель)
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
            if (luminance < 128) byte = byte ^ mask; // Черный пиксель
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

    // Сохраняем изображение в формате BMP
    final bmpData = img.encodeBmp(image);
    await file.writeAsBytes(bmpData);

    print('Изображение сохранено для отладки по пути: $path');
    return path;
  }

  Future<Uint8List> loadBmpImageData(String path) async {
    final file = File(path);
    return file.readAsBytesSync();
  }
}
