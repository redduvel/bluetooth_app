import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:flutter/services.dart' show rootBundle;

class ImageUtils {
  Future<Uint8List> loadAsset(String path) async {
    return await rootBundle
        .load(path)
        .then((byteData) => byteData.buffer.asUint8List());
  }

  Future<List<List<int>>> getImageData(img.Image monoImage) async {
    final widthInBytes = (monoImage.width / 8).ceil();
    final data = List<List<int>>.generate(
      monoImage.height,
      (y) {
        return List<int>.generate(widthInBytes, (b) {
          int byte = 0;
          int mask = 128;

          for (int x = b * 8; x < (b + 1) * 8; x++) {
            if (x >= monoImage.width) break;
            int pixel = monoImage.getPixel(x, y);
            if (pixel == 0xFFFFFFFF) byte = byte ^ mask; // Черный пиксель
            mask >>= 1;
          }

          return byte;
        });
      },
    );

    return data;
  }

  Future<img.BitmapFont> loadCustomFont() async {
    final ByteData data =
        await rootBundle.load('assets/fonts/roboto.ttf.zip');
    final Uint8List bytes = data.buffer.asUint8List();
    final font = img.BitmapFont.fromZip(bytes);
    return font;
  }

  Future<Map<String, dynamic>> createAndPrintLabel(String text) async {
    final font = await loadCustomFont();

    const int dpi = 203; // Типичный DPI для термопринтера
    const int widthMm = 30;
    const int heightMm = 20;

    // Переводим размеры из мм в пиксели
    final int widthPx = (widthMm * dpi / 25.4).round();
    final int heightPx = (heightMm * dpi / 25.4).round();

    // Создаем новое изображение
    final img.Image labelImage = img.Image(widthPx, heightPx);
    img.fill(labelImage, img.getColor(0, 0, 0)); // Заливаем белым цветом

    // Настраиваем стиль текста
    img.drawString(labelImage, font, 25, 25, 'text',
        color: img.getColor(255, 255, 255));

    // Конвертируем изображение в черно-белое
    img.Image monoImage = img.grayscale(labelImage);
    for (int y = 0; y < monoImage.height; y++) {
      for (int x = 0; x < monoImage.width; x++) {
        int pixel = monoImage.getPixel(x, y);
        int luminance = img.getLuminance(pixel);
        monoImage.setPixel(x, y, luminance < 128 ? 0xFF000000 : 0xFFFFFFFF);
      }
    }

    // Получаем данные изображения для печати
    final imageData = await getImageData(monoImage);
    return {'data': imageData, 'image': labelImage};
  }
}
