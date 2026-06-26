import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class LocalDBService {
  static final LocalDBService instance = LocalDBService._init();
  static Database? _database;

  LocalDBService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('motolab_local.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    if (Platform.isWindows) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    final dbDir = await getApplicationDocumentsDirectory();
    final path = join(dbDir.path, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    // Local Offline Job Card Buffer Cache
    await db.execute('''
      CREATE TABLE local_job_cards (
        id TEXT PRIMARY KEY,
        workshop_id TEXT,
        assigned_mechanic_id TEXT,
        customer_name TEXT,
        bike_plate TEXT,
        bike_model TEXT,
        status TEXT,
        is_synced INTEGER DEFAULT 0
      )
    ''');

    // Local Sync Transaction Queue File
    await db.execute('''
      CREATE TABLE sync_queue (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        action_type TEXT,
        table_name TEXT,
        payload TEXT,
        created_at TEXT
      )
    ''');
  }

  Future<void> queueOfflineAction(String action, String table, String jsonPayload) async {
    final db = await instance.database;
    await db.insert('sync_queue', {
      'action_type': action,
      'table_name': table,
      'payload': jsonPayload,
      'created_at': DateTime.now().toIso8601String(),
    });
  }
}
