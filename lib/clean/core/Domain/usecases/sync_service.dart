import 'dart:async';
import 'package:bluetooth_app/clean/core/Domain/bloc/db.bloc.dart';
import 'package:bluetooth_app/clean/core/Domain/entities/marking/category.dart';
import 'package:bluetooth_app/clean/core/Domain/entities/marking/product.dart';
import 'package:bluetooth_app/clean/core/Domain/entities/marking/user.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:logger/logger.dart';

class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;

  SyncService._internal();

  Timer? _timer;
  late Logger logger;
  late DBBloc<User> userBloc;
  late DBBloc<Product> productBloc;
  late DBBloc<Category> categoryBloc;
  late InternetConnection internetConnection;

  static Future<SyncService> initialize({
    required DBBloc<User> userBloc,
    required DBBloc<Product> productBloc,
    required DBBloc<Category> categoryBloc,
  }) async {
    _instance.logger = Logger();
    _instance.userBloc = userBloc;
    _instance.productBloc = productBloc;
    _instance.categoryBloc = categoryBloc;
    _instance.internetConnection = InternetConnection();
    _instance.logger.d('SyncService successfully created');
    return _instance;
  }

  void startSync() async {
    await _syncInBackground();
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) async {
      await _syncInBackground();
    });
  }

  Future<void> _syncInBackground() async {
    try {
      bool internetConnection = await InternetConnection().hasInternetAccess;

      if (internetConnection) {
        _syncAll();
        logger.i('Sync was successful');
      } else {
        logger.w('No internet connection. Sync postponed.');
        return;
      }
    } catch (e) {
      logger.e('Sync error: $e');
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
  }
}
