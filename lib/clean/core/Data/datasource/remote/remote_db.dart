// ignore: file_names
import 'package:bluetooth_app/clean/core/Domain/entities/product.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RemoteDB {
  static RemoteDB? _instance;
  RemoteDB._();
  static RemoteDB get instance => _instance ??= RemoteDB._();

  static late SupabaseClient database;

  static Future<void> createDB() async {
    await Supabase.initialize(
      url: 'https://uywhgtbxtxbrqmlawdzi.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InV5d2hndGJ4dHhicnFtbGF3ZHppIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjkxODI4NzcsImV4cCI6MjA0NDc1ODg3N30.HyXLbheeZwFSJccZLvYf1ws5wmFckMj4m9BfA3_Z1jE',
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
          print('Change received: ${payload.toString()}');
        })
    .subscribe();


    RemoteDB.database
        .from('products')
        .select()
        .eq('isHide', 'False')
        .asStream()
        .listen((List<Map<String, dynamic>> data) {
          for (var p in data) {
            RemoteDB.database.from('categories').select().eq('id', p['category']).asStream().listen((d) {
              for (var b in d) {
                p['category'] = b;
                print(Product.fromJson(p));
              }
            });
          }
    });
  }
}
