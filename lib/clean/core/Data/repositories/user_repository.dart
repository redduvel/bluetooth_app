import 'package:bluetooth_app/clean/core/Data/datasource/remote/remote_db.dart';
import 'package:bluetooth_app/clean/core/Data/repository.dart';
import 'package:bluetooth_app/clean/core/Domain/entities/marking/user.dart';
import 'package:hive_flutter/hive_flutter.dart';

class UserRepository implements IRepository<User> {
  User? currentUser;
  @override
  get currentItem => currentUser;

  @override
  set currentItem(currentItem) => currentUser = currentItem;

  final String repositoryName;

  UserRepository({required this.repositoryName});

  @override
  Future<List<User>> sync() async {
    try {
      List<User> localData = getAll();

      RemoteDB.database
          .from(repositoryName)
          .select()
          .asStream()
          .listen((List<Map<String, dynamic>> data) async {
        List<User> remoteData = [];

        remoteData = data.map((map) {
          return User.fromJson(map);
        }).toList();

        final localUserMap = {for (User user in localData) user.id: user};

        final supabaseUserMap = {for (User user in remoteData) user.id: user};

        for (User user in remoteData) {
          if (localUserMap.containsKey(user.id)) {
            final localCategory = localUserMap[user.id];
            if (localCategory != user) {
              await update(user);
            }
          } else {
            await save(user);
          }
        }

        for (var user in localData) {
          if (!supabaseUserMap.containsKey(user.id)) {
            await delete(user.id);
          }
        }
      });
      
      await Future.delayed(const Duration(seconds: 1)).whenComplete(() {
        localData = getAll();
      });

      return localData;
    } catch (e) {
      Exception(e);
      return [];
    }
  }

  @override
  List<User> getAll() {
    try {
      var userBox = Hive.box<User>(repositoryName);
      List<User> users = userBox.values.toList();

      return users;
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<void> save(User item, {bool sync = false}) async {
    try {
      var userBox = Hive.box<User>('users');
      await userBox.put(item.id, item).whenComplete(() async {
        if (sync) {
          await RemoteDB.database.from(repositoryName).insert(item.toJson());
        }
      });
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<bool> update(User item, {bool sync = false}) async {
    try {
      await Hive.box<User>(repositoryName)
          .put(item.id, item)
          .whenComplete(() async {
        if (sync) {
          await RemoteDB.database
              .from(repositoryName)
              .update(item.toJson())
              .eq('id', item.id);
        }
      });
      return true;
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<void> delete(String id, {bool sync = false}) async {
    try {
      var userBox = Hive.box<User>(repositoryName);
      await userBox.delete(id).whenComplete(() async {
        if (sync) {
          await RemoteDB.database.from(repositoryName).delete().eq('id', id);
        }
      });
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<void> reorderList(int newIndex, int oldIndex,
      {bool sync = false}) async {
    try {
      //var employeeBox = Hive.box<Employee>('users');
      //User employee = employeeBox.getAt(oldIndex)!;
      //employeeBox.deleteAt(oldIndex);
      //employeeBox.putAt(newIndex, employee);
    } catch (e) {
      throw Exception(e);
    }
  }
}
