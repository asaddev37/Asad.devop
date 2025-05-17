import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    String path = join(await getDatabasesPath(), 'bmi_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE bmi_results (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            bmi REAL,
            weight INTEGER,
            age INTEGER,
            gender TEXT,
            timestamp TEXT
          )
        ''');
      },
    );
  }

  Future<void> insertResult(Map<String, dynamic> result) async {
    final db = await database;
    await db.insert('bmi_results', result);
  }

  Future<List<Map<String, dynamic>>> getResults() async {
    final db = await database;
    return await db.query('bmi_results', orderBy: 'timestamp DESC');
  }

  Future<void> clearResults() async {
    final db = await database;
    await db.delete('bmi_results');
  }
}