import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../model/journal_entry.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('journal.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE journal_entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        location TEXT NOT NULL,
        weatherCondition TEXT NOT NULL,
        temperature REAL NOT NULL,
        notes TEXT NOT NULL,
        date TEXT NOT NULL,
        userId TEXT NOT NULL
      )
    ''');
  }

  Future<int> create(JournalEntry entry) async {
    final db = await instance.database;
    return await db.insert('journal_entries', entry.toMap());
  }

  Future<List<JournalEntry>> getEntries(String userId) async {
    final db = await instance.database;
    final maps = await db.query(
      'journal_entries',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
    );

    if (maps.isNotEmpty) {
      return maps.map((json) => JournalEntry(
        id: json['id'] as int,
        location: json['location'] as String,
        weatherCondition: json['weatherCondition'] as String,
        temperature: json['temperature'] as double,
        notes: json['notes'] as String,
        date: DateTime.parse(json['date'] as String),
        userId: json['userId'] as String,
      )).toList();
    } else {
      return [];
    }
  }

// update() ?? delete() ??
}