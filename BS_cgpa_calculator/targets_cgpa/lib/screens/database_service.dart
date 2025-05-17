import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'cgpa_history.db');

    final db = await openDatabase(
      path,
      version: 6,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );

    await verifyTableSchema(db);
    return db;
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE individual_semester_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        semester TEXT,
        subjects TEXT,
        credits TEXT,
        grades TEXT,
        cgpa REAL,
        timestamp DATETIME
      )
    ''');

    await db.execute('''
      CREATE TABLE target_cgpa_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        current_cgpa REAL,
        target_cgpa REAL,
        current_semester INTEGER,
        subjects TEXT,
        credits TEXT,
        grades TEXT,
        remaining_credits INTEGER,
        required_gpa REAL,
        next_semester_gpa REAL,
        actual_cgpa REAL,
        timestamp DATETIME
      )
    ''');

    await db.execute('''
      CREATE TABLE current_target_cgpa_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        current_cgpa REAL,
        target_cgpa REAL,
        remaining_credits INTEGER,
        required_gpa REAL,
        semester_gpas TEXT,
        target_semester INTEGER,
        timestamp DATETIME
      )
    ''');
  }

  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE current_target_cgpa_history ADD COLUMN remaining_credits INTEGER DEFAULT 0');
    }
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE individual_semester_history RENAME TO temp_individual_semester_history');
      await db.execute('''
      CREATE TABLE individual_semester_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        semester TEXT,
        subjects TEXT,
        credits TEXT,
        grades TEXT,
        cgpa REAL,
        timestamp DATETIME
      )
    ''');
      await db.execute('''
      INSERT INTO individual_semester_history (id, semester, subjects, credits, grades, cgpa, timestamp)
      SELECT id, semester, subjects, CAST(credits AS TEXT), grades, cgpa, timestamp
      FROM temp_individual_semester_history
    ''');
      await db.execute('DROP TABLE temp_individual_semester_history');
    }
    if (oldVersion < 4) {
      await db.execute('ALTER TABLE target_cgpa_history ADD COLUMN current_semester INTEGER');
      await db.execute('ALTER TABLE target_cgpa_history ADD COLUMN subjects TEXT');
      await db.execute('ALTER TABLE target_cgpa_history ADD COLUMN credits TEXT');
      await db.execute('ALTER TABLE target_cgpa_history ADD COLUMN grades TEXT');
    }
    if (oldVersion < 5) {
      await db.execute('ALTER TABLE target_cgpa_history ADD COLUMN next_semester_gpa REAL');
      await db.execute('ALTER TABLE target_cgpa_history ADD COLUMN actual_cgpa REAL');
    }
    if (oldVersion < 6) {
      final tableInfo = await db.rawQuery('PRAGMA table_info(current_target_cgpa_history)');
      final hasSemesterGpas = tableInfo.any((column) => column['name'] == 'semester_gpas');
      if (!hasSemesterGpas) {
        await db.execute('ALTER TABLE current_target_cgpa_history ADD COLUMN semester_gpas TEXT');
      }
      final hasTargetSemester = tableInfo.any((column) => column['name'] == 'target_semester');
      if (!hasTargetSemester) {
        await db.execute('ALTER TABLE current_target_cgpa_history ADD COLUMN target_semester INTEGER');
      }
    }
  }

  static Future<void> verifyTableSchema(Database db) async {
    final tableInfo = await db.rawQuery('PRAGMA table_info(current_target_cgpa_history)');
    for (var column in tableInfo) {
      print('Column: ${column['name']}, Type: ${column['type']}');
    }
  }

  static Future<void> deleteDatabaseFile(String path) async {
    final dbPath = await getDatabasesPath();
    final fullPath = join(dbPath, 'cgpa_history.db');
    await deleteDatabase(fullPath);
  }

  static Future<List<Map<String, dynamic>>> getCombinedHistory() async {
    final db = await database;

    final individualHistory = await db.query('individual_semester_history');
    final targetHistory = await db.query('target_cgpa_history');
    final currentTargetHistory = await db.query('current_target_cgpa_history');

    final combinedHistory = [
      ...individualHistory.map((record) => {
        ...record,
        'module': 'Individual Semester',
        'details': 'Semester: ${record['semester']}, CGPA: ${record['cgpa']}',
      }),
      ...targetHistory.map((record) => {
        ...record,
        'module': 'Achieving Target CGPA',
        'details': 'Current CGPA: ${record['current_cgpa']}, Target CGPA: ${record['target_cgpa']}',
      }),
      ...currentTargetHistory.map((record) => {
        ...record,
        'module': 'Current & Target CGPA',
        'details': 'Current CGPA: ${record['current_cgpa']}, Target CGPA: ${record['target_cgpa']}, Semester GPAs: ${record['semester_gpas'] ?? 'N/A'}',
      }),
    ];

    combinedHistory.sort((a, b) {
      DateTime timestampA = DateTime.tryParse(a['timestamp']?.toString() ?? '') ?? DateTime(1970, 1, 1);
      DateTime timestampB = DateTime.tryParse(b['timestamp']?.toString() ?? '') ?? DateTime(1970, 1, 1);
      return timestampB.compareTo(timestampA);
    });

    return combinedHistory;
  }
}