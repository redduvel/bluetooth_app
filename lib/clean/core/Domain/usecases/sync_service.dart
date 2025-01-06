import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart' as f;
import 'package:bluetooth_app/clean/core/Domain/bloc/db.bloc.dart';
import 'package:bluetooth_app/clean/core/Domain/entities/marking/category.dart';
import 'package:bluetooth_app/clean/core/Domain/entities/marking/product.dart';
import 'package:bluetooth_app/clean/core/Domain/entities/marking/template.dart';
import 'package:bluetooth_app/clean/core/Domain/entities/marking/user.dart';

class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;

  SyncService._internal();

  Timer? _timer;
  late DBBloc<User> userBloc;
  late DBBloc<Product> productBloc;
  late DBBloc<Category> categoryBloc;
  late DBBloc<Template> templateBloc;

  static Future<SyncService> initialize({
    required DBBloc<User> userBloc,
    required DBBloc<Product> productBloc,
    required DBBloc<Category> categoryBloc,
    required DBBloc<Template> templateBloc,
  }) async {
    _instance.userBloc = userBloc;
    _instance.productBloc = productBloc;
    _instance.categoryBloc = categoryBloc;
    _instance.templateBloc = templateBloc;
    return _instance;
  }

  void startSync() {
    _timer = Timer.periodic(const Duration(minutes: 3), (timer) async {
      await _syncInBackground();
    });
  }

  Future<bool> _checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  Future<void> _syncInBackground() async {
    try {
      final hasInternet = await _checkInternetConnection();
      if (!hasInternet) {
        print('Нет подключения к интернету. Синхронизация отложена.');
        return;
      }
      
      await f.compute(_backgroundSync, null);
      _syncAll();
    } catch (e) {
      print('Ошибка при синхронизации: $e');
    }
  }

  static Future<void> _backgroundSync(_) async {
    await Future.delayed(const Duration(seconds: 1));
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