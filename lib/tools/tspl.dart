import 'package:bluetooth_app/models/employee.dart';
import 'package:bluetooth_app/models/product.dart';
import 'package:intl/intl.dart';

class TsplTools {
  static String generateTsplCode(
    Employee currentUser, Product currentProduct, String count
  ) {
    String width = '30';
    String height = '20';
    String gap = '3';
    String dateTimeNow = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());
    String date = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now().add(Duration(hours: currentProduct.openedTime)));

    StringBuffer tsplCode = StringBuffer();

    tsplCode.writeln('SIZE $width mm, $height mm');
    tsplCode.writeln('GAP $gap mm, 0 mm');
    //tsplCode.writeln('CLS');

    tsplCode.writeln('TEXT 100, 10, "0", 0, 1, 1, "${currentProduct.subtitle}"');
    tsplCode.writeln('TEXT 100, 10, "0", 0, 1, 1, "$dateTimeNow"');
    tsplCode.writeln('TEXT 100, 10, "0", 0, 1, 1, "$date"');
    tsplCode.writeln('TEXT 100, 10, "0", 0, 1, 1, "${currentUser.fullName}"');

    tsplCode.writeln('PRINT $count,1');

    return tsplCode.toString();
  }
}