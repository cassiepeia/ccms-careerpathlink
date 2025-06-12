import 'package:path/path.dart';
import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init() {
    if (kIsWeb) {
      // Initialize for web
      databaseFactory = databaseFactoryFfiWeb;
      databaseFactory = databaseFactoryFfiWeb;
    } else {
      // Initialize for mobile/desktop
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('final_careercoaching.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    if (kIsWeb) {
      // For web, use indexedDB as persistent storage
      try {
        return await databaseFactoryFfiWeb.openDatabase(
          filePath,
          options: OpenDatabaseOptions(
            version: 1,
            onConfigure: (db) async {
              await db.execute('PRAGMA foreign_keys = ON');
            },
          ),
        );
      } catch (e) {
        debugPrint('Failed to open web database: $e');
        rethrow;
      }
    } else {
      // For mobile/desktop
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, filePath);
      return await openDatabase(
        path,
        version: 1,
        onCreate: _createDB,
        onConfigure: (db) async {
          await db.execute('PRAGMA foreign_keys = ON');
        },
      );
    }
  }

  Future<void> _createDB(Database db, int version) async {
    // Create your tables here if needed
    // This is only called when the database is first created
  }

  Future<List<Map<String, dynamic>>> queryView(String viewName) async {
    final db = await instance.database;
    try {
      return await db.rawQuery('SELECT * FROM $viewName');
    } catch (e) {
      debugPrint('Error querying view $viewName: $e');
      rethrow;
    }
  }

  Future<void> close() async {
    final db = await instance.database;
    await db.close();
    _database = null;
  }
}