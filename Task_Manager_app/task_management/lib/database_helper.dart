import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('tasks.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 4,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE tasks (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT NOT NULL,
      description TEXT,
      dueDate TEXT,
      isCompleted INTEGER DEFAULT 0,
      isRepeated INTEGER DEFAULT 0,
      repeatDays TEXT,
      progress REAL DEFAULT 0.0,
      subtasks TEXT,
      categoryId INTEGER,
      FOREIGN KEY (categoryId) REFERENCES categories(id) ON DELETE SET NULL
    )
    ''');

    await db.execute('''
    CREATE TABLE categories (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL
    )
    ''');

    await db.execute('''
    CREATE TABLE task_instances (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      taskId INTEGER,
      dueDate TEXT NOT NULL,
      isCompleted INTEGER DEFAULT 0,
      FOREIGN KEY (taskId) REFERENCES tasks(id) ON DELETE CASCADE
    )
    ''');
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE tasks ADD COLUMN subtasks TEXT');
    }
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE tasks ADD COLUMN categoryId INTEGER');
      await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL
      )
      ''');
    }
    if (oldVersion < 4) {
      await db.execute('''
      CREATE TABLE task_instances (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        taskId INTEGER,
        dueDate TEXT NOT NULL,
        isCompleted INTEGER DEFAULT 0,
        FOREIGN KEY (taskId) REFERENCES tasks(id) ON DELETE CASCADE
      )
      ''');
    }
  }

  // Task Methods
  Future<int?> insertTask(Map<String, dynamic> task) async {
    final db = await database;
    try {
      final id = await db.insert('tasks', task);
      print('Task inserted with ID: $id');
      return id;
    } catch (e) {
      print('Error inserting task: $e');
      print('Task data: $task');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getTasks() async {
    final db = await database;
    return await db.query('tasks');
  }

  Future<Map<String, dynamic>?> getTaskById(int id) async {
    final db = await database;
    final result = await db.query('tasks', where: 'id = ?', whereArgs: [id]);
    return result.isNotEmpty ? result.first : null;
  }

  Future<void> updateTask(Map<String, dynamic> task) async {
    final db = await database;
    await db.update('tasks', task, where: 'id = ?', whereArgs: [task['id']]);
  }

  Future<void> deleteTask(int id) async {
    final db = await database;
    await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteTasksByCategory(int categoryId) async {
    final db = await database;
    await db.delete('tasks', where: 'categoryId = ?', whereArgs: [categoryId]);
  }

  // Task Instance Methods
  Future<void> insertTaskInstance(Map<String, dynamic> instance) async {
    final db = await database;
    await db.insert('task_instances', instance);
  }

  Future<List<Map<String, dynamic>>> getTaskInstances([int? taskId]) async {
    final db = await database;

    if (taskId != null) {

      return await db.query('task_instances', where: 'taskId = ?', whereArgs: [taskId]);
    }
    return await db.query('task_instances');
  }

  Future<void> markTaskInstanceCompleted(int taskId, DateTime instanceDate) async {
    final db = await database;
    await db.update(
      'task_instances',
      {'isCompleted': 1},
      where: 'taskId = ? AND dueDate = ?',
      whereArgs: [taskId, instanceDate.toIso8601String()],
    );
  }

  Future<void> markTaskInstanceUncompleted(int taskId, DateTime instanceDate) async {
    final db = await database;
    await db.update(
      'task_instances',
      {'isCompleted': 0},
      where: 'taskId = ? AND dueDate = ?',
      whereArgs: [taskId, instanceDate.toIso8601String()],
    );
  }

  Future<void> deleteTaskInstances(int taskId) async {
    final db = await database;
    await db.delete('task_instances', where: 'taskId = ?', whereArgs: [taskId]);
  }

  Future<void> deleteTaskInstance(int taskId, String dueDate) async {
    final db = await database;
    await db.delete(
      'task_instances',
      where: 'taskId = ? AND dueDate = ?',
      whereArgs: [taskId, dueDate],
    );
  }

  // Category Methods
  Future<int> insertCategory(Map<String, dynamic> category) async {
    final db = await database;
    try {
      return await db.insert('categories', category);
    } catch (e) {
      print('Error inserting category: $e');
      return -1;
    }
  }

  Future<List<Map<String, dynamic>>> getCategories() async {
    final db = await database;
    return await db.query('categories');
  }

  Future<void> updateCategory(Map<String, dynamic> category) async {
    final db = await database;
    await db.update('categories', category, where: 'id = ?', whereArgs: [category['id']]);
  }

  Future<void> deleteCategory(int id) async {
    final db = await database;
    await db.update('tasks', {'categoryId': null}, where: 'categoryId = ?', whereArgs: [id]);
    await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }
}