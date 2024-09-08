import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ImageUtils {
  Future<List<List<int>>> getImageDataFromBmp(Uint8List bmpData) async {
    // Считываем заголовок BMP (54 байта)
    const headerSize = 54;
    if (bmpData.length < headerSize) {
      throw Exception('Недостаточно данных для заголовка BMP.');
    }

    final width = bmpData.buffer.asByteData().getInt32(18, Endian.little);
    final height = bmpData.buffer.asByteData().getInt32(22, Endian.little);

    const bytesPerPixel = 3;
    final rowSize = ((width * bytesPerPixel + 3) ~/ 4) * 4;

    const pixelArrayStart = headerSize;

    final data = List<List<int>>.generate(
      height,
      (y) {
        return List<int>.generate((width / 8).ceil(), (b) {
          int byte = 0;
          int mask = 128;

          for (int x = b * 8; x < (b + 1) * 8; x++) {
            if (x >= width) break;

            final pixelIndex = pixelArrayStart +
                (height - y - 1) * rowSize +
                x * bytesPerPixel;

            final blue = bmpData[pixelIndex];
            final green = bmpData[pixelIndex + 1];
            final red = bmpData[pixelIndex + 2];

            final luminance =
                (0.299 * red + 0.587 * green + 0.114 * blue).toInt();

            if (luminance < 128) byte |= mask;

            mask >>= 1;
          }

          return byte;
        });
      },
    );

    return data;
  }

  Future<pw.Document> generatePdf(
      PdfPageFormat format, String subtitle, String fullName,
      {String? startDate, String? endDate}) async {
    final pdf = pw.Document(version: PdfVersion.pdf_1_5, compress: true);
    final ttf = await fontFromAssetBundle('assets/fonts/roboto.ttf');

    pdf.addPage(
      pw.Page(
        margin: const pw.EdgeInsets.all(2),
        pageFormat: format,
        build: (pw.Context context) {
          return pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text(
                subtitle,  style: pw.TextStyle(font: ttf, fontSize: 10)
              ),
              if (startDate != null)
              pw.Text(
                startDate, style: pw.TextStyle(font: ttf, fontSize: 10)
              ),
              if (endDate != null)
              pw.Text(
                endDate, style: pw.TextStyle(font: ttf, fontSize: 10)
              ),
              pw.Text(
                fullName, style: pw.TextStyle(font: ttf, fontSize: 10)
              )
            ],
          );
        },
      ),
    );

    return pdf;
  }
}
