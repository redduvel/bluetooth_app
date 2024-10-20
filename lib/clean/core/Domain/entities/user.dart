import 'package:bluetooth_app/clean/core/utils/id_generator.dart';
import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 1)
class User extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String fullName;

  User({
    String? id,
    required this.fullName,
  }) : id = id ?? IdGenerator.generate();

  // Метод для копирования объекта
  User copyWith({
    String? id,
    String? fullName,
  }) {
    return User(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
    );
  }

  // Метод для сериализации в JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
    };
  }

  // Метод для десериализации из JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      fullName: json['fullName'],
    );
  }
}
