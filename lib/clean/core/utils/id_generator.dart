import 'package:uuid/uuid.dart';

class IdGenerator {
  static var uuid = const Uuid();

  static String generate() => uuid.v4();
}