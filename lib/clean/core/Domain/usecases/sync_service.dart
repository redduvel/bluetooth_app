import 'dart:async';
import 'package:bluetooth_app/clean/core/Domain/bloc/db.bloc.dart';
import 'package:bluetooth_app/clean/core/Domain/entities/marking/category.dart';
import 'package:bluetooth_app/clean/core/Domain/entities/marking/product.dart';
import 'package:bluetooth_app/clean/core/Domain/entities/marking/template.dart';
import 'package:bluetooth_app/clean/core/Domain/entities/marking/user.dart';

class SyncService {
  Timer? _timer;
  final DBBloc<User> userBloc;
  final DBBloc<Product> productBloc;
  final DBBloc<Category> categoryBloc;
  final DBBloc<Template> templateBloc;

  SyncService({
    required this.userBloc,
    required this.productBloc,
    required this.categoryBloc,
    required this.templateBloc,
  });

  void startSync() {
    _timer = Timer.periodic(const Duration(minutes: 3), (timer) {
      _syncAll();
    });
  }

  void stopSync() {
    _timer?.cancel();
    _timer = null;
  }

  void _syncAll() {
    userBloc.add(Sync<User>());
    productBloc.add(Sync<Product>());
    categoryBloc.add(Sync<Category>());
    templateBloc.add(Sync<Template>());
  }
}