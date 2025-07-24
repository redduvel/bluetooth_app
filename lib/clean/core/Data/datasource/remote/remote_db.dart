// ignore: file_names
import 'package:bluetooth_app/clean/core/Domain/usecases/sync_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RemoteDB {
  static RemoteDB? _instance;
  RemoteDB._();
  static RemoteDB get instance => _instance ??= RemoteDB._();

  static late SupabaseClient database;

  static Future<void> createDB() async {
    await Supabase.initialize(
      url: '<supabase-url>',
      anonKey:
          '<supabase-anon-key>',
    );
    database = Supabase.instance.client;

  }

  static Future<void> sync() async {
    RemoteDB.database
    .channel('fresh-tag')
    .onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'products',
        callback: (payload) {
          SyncService.instance.sync();
        })
    .subscribe();
  }
}
