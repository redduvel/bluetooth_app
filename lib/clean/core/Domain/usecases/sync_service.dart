import 'dart:async';
import 'package:bluetooth_app/clean/core/Domain/bloc/db.bloc.dart';
import 'package:bluetooth_app/clean/core/Domain/entities/marking/category.dart';
import 'package:bluetooth_app/clean/core/Domain/entities/marking/product.dart';
import 'package:bluetooth_app/clean/core/Domain/entities/marking/user.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:logger/logger.dart';

class SyncService {
  static final SyncService _instance = SyncService._internal();
  
  static SyncService get instance => _instance;
  
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
    await sync();
    _timer = Timer.periodic(const Duration(minutes: 5), (timer) async {
      await sync();
    });
  }

  Future<void> sync() async {
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
