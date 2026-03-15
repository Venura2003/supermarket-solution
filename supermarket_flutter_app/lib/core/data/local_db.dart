import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class LocalDb {
  static final LocalDb _instance = LocalDb._();
  LocalDb._();
  factory LocalDb() => _instance;

  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    String path;
    if (kIsWeb) {
      path = 'supermarket_local.db';
    } else {
      final dir = await getApplicationDocumentsDirectory();
      path = join(dir.path, 'supermarket_local.db');
    }
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE products (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        categories TEXT,
        images TEXT,
        attributes TEXT,
        skus TEXT,
        isActive INTEGER DEFAULT 1,
        updatedAt INTEGER
      )
    ''');
  }

  Future<void> close() async {
    if (_db != null) {
      await _db!.close();
      _db = null;
    }
  }
}
