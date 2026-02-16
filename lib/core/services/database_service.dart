import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:student_app/data/models/student_model.dart';
import 'package:student_app/data/models/semester_model.dart';
import 'package:student_app/data/models/subject_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static DatabaseService get instance => _instance;

  static Database? _database;

  DatabaseService._internal();

  Future<Database> get database async {
    // On web, sqflite is not supported. This getter should never be called there.
    if (kIsWeb) {
      throw UnsupportedError('Database is not supported on web');
    }

    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<void> init() async {
    if (kIsWeb) {
      // No-op on web
      return;
    }
    await database;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'student_app.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Student Profile Table
    await db.execute('''
      CREATE TABLE student_profile (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        course TEXT,
        institution TEXT,
        academic_system TEXT NOT NULL,
        grade_scale TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Semesters Table
    await db.execute('''
      CREATE TABLE semesters (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        semester_number INTEGER NOT NULL,
        semester_name TEXT NOT NULL,
        sgpa REAL,
        total_credits REAL,
        completed_credits REAL,
        start_date TEXT,
        end_date TEXT,
        is_completed INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Subjects Table
    await db.execute('''
      CREATE TABLE subjects (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        semester_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        code TEXT,
        credits REAL NOT NULL,
        marks_obtained REAL,
        max_marks REAL DEFAULT 100,
        grade TEXT,
        grade_points REAL,
        is_backlog INTEGER NOT NULL DEFAULT 0,
        attendance_percentage REAL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (semester_id) REFERENCES semesters (id) ON DELETE CASCADE
      )
    ''');

    // Settings Table
    await db.execute('''
      CREATE TABLE settings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        key TEXT UNIQUE NOT NULL,
        value TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // AI API Keys Table
    await db.execute('''
      CREATE TABLE ai_settings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        provider TEXT NOT NULL,
        api_key TEXT NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
  }

  // Student Profile Operations
  Future<int> saveStudentProfile(StudentModel student) async {
    if (kIsWeb) {
      // Persistence via SQLite is not available on web; skip.
      return 0;
    }
    final db = await database;
    return await db.insert('student_profile', student.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<StudentModel?> getStudentProfile() async {
    if (kIsWeb) {
      return null;
    }
    final db = await database;
    final result = await db.query('student_profile', limit: 1);
    if (result.isNotEmpty) {
      return StudentModel.fromJson(result.first);
    }
    return null;
  }

  Future<int> updateStudentProfile(StudentModel student) async {
    if (kIsWeb) {
      return 0;
    }
    final db = await database;
    return await db.update(
      'student_profile',
      student.toJson(),
      where: 'id = ?',
      whereArgs: [student.id],
    );
  }

  // Semester Operations
  Future<int> insertSemester(SemesterModel semester) async {
    if (kIsWeb) {
      return 0;
    }
    final db = await database;
    return await db.insert('semesters', semester.toJson());
  }

  Future<List<SemesterModel>> getAllSemesters() async {
    if (kIsWeb) {
      return [];
    }
    final db = await database;
    final result = await db.query('semesters', orderBy: 'semester_number ASC');
    return result.map((e) => SemesterModel.fromJson(e)).toList();
  }

  Future<SemesterModel?> getSemester(int id) async {
    if (kIsWeb) {
      return null;
    }
    final db = await database;
    final result = await db.query('semesters', where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty) {
      return SemesterModel.fromJson(result.first);
    }
    return null;
  }

  Future<int> updateSemester(SemesterModel semester) async {
    if (kIsWeb) {
      return 0;
    }
    final db = await database;
    return await db.update(
      'semesters',
      semester.toJson(),
      where: 'id = ?',
      whereArgs: [semester.id],
    );
  }

  Future<int> deleteSemester(int id) async {
    if (kIsWeb) {
      return 0;
    }
    final db = await database;
    return await db.delete('semesters', where: 'id = ?', whereArgs: [id]);
  }

  // Subject Operations
  Future<int> insertSubject(SubjectModel subject) async {
    if (kIsWeb) {
      return 0;
    }
    final db = await database;
    return await db.insert('subjects', subject.toJson());
  }

  Future<List<SubjectModel>> getSubjectsBySemester(int semesterId) async {
    if (kIsWeb) {
      return [];
    }
    final db = await database;
    final result = await db.query(
      'subjects',
      where: 'semester_id = ?',
      whereArgs: [semesterId],
      orderBy: 'name ASC',
    );
    return result.map((e) => SubjectModel.fromJson(e)).toList();
  }

  Future<List<SubjectModel>> getAllSubjects() async {
    if (kIsWeb) {
      return [];
    }
    final db = await database;
    final result = await db.query('subjects', orderBy: 'created_at DESC');
    return result.map((e) => SubjectModel.fromJson(e)).toList();
  }

  Future<int> updateSubject(SubjectModel subject) async {
    if (kIsWeb) {
      return 0;
    }
    final db = await database;
    return await db.update(
      'subjects',
      subject.toJson(),
      where: 'id = ?',
      whereArgs: [subject.id],
    );
  }

  Future<int> deleteSubject(int id) async {
    if (kIsWeb) {
      return 0;
    }
    final db = await database;
    return await db.delete('subjects', where: 'id = ?', whereArgs: [id]);
  }

  // Settings Operations
  Future<String?> getSetting(String key) async {
    if (kIsWeb) {
      return null;
    }
    final db = await database;
    final result = await db.query('settings', where: 'key = ?', whereArgs: [key]);
    if (result.isNotEmpty) {
      return result.first['value'] as String;
    }
    return null;
  }

  Future<void> setSetting(String key, String value) async {
    if (kIsWeb) {
      return;
    }
    final db = await database;
    await db.insert(
      'settings',
      {'key': key, 'value': value, 'created_at': DateTime.now().toIso8601String(), 'updated_at': DateTime.now().toIso8601String()},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Close database
  Future<void> close() async {
    if (kIsWeb) {
      _database = null;
      return;
    }

    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
