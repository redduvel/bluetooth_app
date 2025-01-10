import 'package:bluetooth_app/clean/core/Domain/entities/marking/category.dart';
import 'package:bluetooth_app/clean/core/Domain/entities/marking/product.dart';
import 'package:bluetooth_app/clean/core/Domain/entities/marking/user.dart';
import 'package:bluetooth_app/clean/core/utils/id_generator.dart';
import 'package:hive/hive.dart';

part 'marking.g.dart';

@HiveType(typeId: 6)
enum MarkingStatus {
  @HiveField(0)
  none,
  @HiveField(1)
  normal,
  @HiveField(2)
  warning,
  @HiveField(3)
  expired
}

@HiveType(typeId: 5)
class Marking {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final Product product;
  @HiveField(2)
  final User user;
  @HiveField(3)
  final Category category;
  @HiveField(4)
  final DateTime startDate;
  @HiveField(5)
  final DateTime endDate;
  @HiveField(6)
  final int count;
  @HiveField(7)
  MarkingStatus status = MarkingStatus.normal;
  @HiveField(8)
  final int characteristicIndex;

  Marking(
      {String? id,
      required this.product,
      required this.user,
      required this.category,
      required this.startDate,
      required this.endDate,
      required this.count,
      required this.characteristicIndex,
      MarkingStatus? status})
      : id = id ?? IdGenerator.generate(),
      status = calculateTimeStatus(startDate, endDate);

  Marking copyWith(
      {String? id,
      Product? product,
      User? user,
      Category? category,
      DateTime? startDate,
      DateTime? endDate,
      int? characteristicIndex,
      int? count,
      MarkingStatus? status}) {
    return Marking(
        product: product ?? this.product,
        user: user ?? this.user,
        category: category ?? this.category,
        startDate: startDate ?? this.startDate,
        endDate: endDate ?? this.endDate,
        characteristicIndex: characteristicIndex ?? this.characteristicIndex,
        count: count ?? this.count,
        status: status ?? this.status);
  }

  Marking setStatus(MarkingStatus status) => copyWith(status: status);

  static MarkingStatus calculateTimeStatus(DateTime startDate, DateTime endDate) {
  final currentTime = DateTime.now();

  if (currentTime.isBefore(startDate)) {
    return MarkingStatus.normal;
  }

  if (currentTime.isAfter(endDate)) {
    return MarkingStatus.expired;
  }

  final totalDuration = endDate.difference(startDate).inMilliseconds;
  final elapsedDuration = currentTime.difference(startDate).inMilliseconds;
  final remainingPercentage = 1 - (elapsedDuration / totalDuration);

  if (remainingPercentage >= 0.5) {
    return MarkingStatus.normal;
  } else {
    return MarkingStatus.warning;
  }
}
}
