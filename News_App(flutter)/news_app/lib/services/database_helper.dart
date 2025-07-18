import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/news_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'settings.db');
    print('Initializing database at: $path');
    try {
      return await openDatabase(
        path,
        version: 2, // Increased version to 2
        onCreate: (db, version) async {
          print('Creating settings and favorites tables');
          await db.execute('''
            CREATE TABLE settings (
              id INTEGER PRIMARY KEY,
              nickname TEXT,
              carousel_topic TEXT
            )
          ''');
          await db.execute('''
            CREATE TABLE favorites (
              newsUrl TEXT PRIMARY KEY,
              newsHeading TEXT,
              newsDescription TEXT,
              newsImgUrl TEXT,
              isFavorite INTEGER
            )
          ''');
          // Insert default settings
          await db.insert('settings', {
            'id': 1,
            'nickname': 'Star',
            'carousel_topic': 'Dragon Ball',
          });
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          print('Upgrading database from $oldVersion to $newVersion');
          if (oldVersion == 1 && newVersion == 2) {
            await db.execute('''
              CREATE TABLE favorites (
                newsUrl TEXT PRIMARY KEY,
                newsHeading TEXT,
                newsDescription TEXT,
                newsImgUrl TEXT,
                isFavorite INTEGER
              )
            ''');
          }
        },
        onOpen: (db) async {
          print('Database opened, verifying tables');
          final tables = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table'");
          print('Tables found: $tables');
          final tableNames = tables.map((map) => map['name'] as String).toList();
          if (tableNames.contains('favorites')) {
            final favorites = await db.query('favorites');
            print('Favorites table initial contents: $favorites');
          } else {
            print('Favorites table does not exist yet.');
          }
        },
      );
    } catch (e) {
      print('Error initializing database: $e');
      rethrow;
    }
  }

  Future<void> initDatabase() async {
    await database; // Ensure database is initialized
  }

  Future<Map<String, dynamic>> getSettings() async {
    try {
      final db = await database;
      final result = await db.query('settings', where: 'id = ?', whereArgs: [1]);
      print('Settings fetched: $result');
      return result.isNotEmpty ? result.first : {'nickname': 'Star', 'carousel_topic': 'Dragon Ball'};
    } catch (e) {
      print('Error fetching settings: $e');
      return {'nickname': 'Star', 'carousel_topic': 'Dragon Ball'};
    }
  }

  Future<void> updateSettings(String nickname, String carouselTopic) async {
    try {
      final db = await database;
      await db.update(
        'settings',
        {'nickname': nickname, 'carousel_topic': carouselTopic},
        where: 'id = ?',
        whereArgs: [1],
      );
      print('Settings updated: nickname=$nickname, carousel_topic=$carouselTopic');
    } catch (e) {
      print('Error updating settings: $e');
    }
  }

  Future<void> addFavorite(NewsModel news) async {
    try {
      final db = await database;
      final map = news.toSqlMap();
      // Ensure no null values
      if (map['newsUrl'] == null || map['newsHeading'] == null || map['newsImgUrl'] == null) {
        print('Invalid favorite data: $map');
        return;
      }
      print('Adding favorite: ${map['newsUrl']}, data: $map');
      await db.insert('favorites', map, conflictAlgorithm: ConflictAlgorithm.replace);
      final favorites = await db.query('favorites');
      print('After adding, favorites count: ${favorites.length}, contents: $favorites');
    } catch (e) {
      print('Error adding favorite: $e');
    }
  }

  Future<void> removeFavorite(String newsUrl) async {
    try {
      final db = await database;
      print('Removing favorite: $newsUrl');
      await db.delete('favorites', where: 'newsUrl = ?', whereArgs: [newsUrl]);
      final favorites = await db.query('favorites');
      print('After removing, favorites count: ${favorites.length}, contents: $favorites');
    } catch (e) {
      print('Error removing favorite: $e');
    }
  }

  Future<List<NewsModel>> getFavorites() async {
    try {
      final db = await database;
      final result = await db.query('favorites');
      print('Fetched favorites: ${result.length} items, contents: $result');
      return result.map((map) => NewsModel.fromSqlMap(map)).toList();
    } catch (e) {
      print('Error fetching favorites: $e');
      return [];
    }
  }
}

class SettingsProvider with ChangeNotifier {
  String _nickname = 'Star';
  String _carouselTopic = 'Dragon Ball';

  String get nickname => _nickname;
  String get carouselTopic => _carouselTopic;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await DatabaseHelper().getSettings();
    _nickname = settings['nickname'] as String;
    _carouselTopic = settings['carousel_topic'] as String;
    print('Loaded settings: nickname=$_nickname, carouselTopic=$_carouselTopic');
    notifyListeners();
  }

  Future<void> updateSettings(String nickname, String carouselTopic) async {
    _nickname = nickname.isEmpty ? 'Star' : nickname;
    _carouselTopic = carouselTopic;
    await DatabaseHelper().updateSettings(_nickname, _carouselTopic);
    notifyListeners();
  }
}