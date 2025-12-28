import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../models/interview.dart';
import '../../models/course.dart';
import '../../models/topic.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('career_tracker.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path, 
      version: 2, 
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE interviews ADD COLUMN companyType INTEGER DEFAULT 0');
    }
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const intType = 'INTEGER NOT NULL';
    const doubleType = 'REAL NOT NULL';

    await db.execute('''
CREATE TABLE interviews ( 
  id $idType, 
  companyName $textType,
  jobRole $textType,
  date $textType,
  location $textType,
  status $intType,
  notes $textType,
  companyType $intType DEFAULT 0
  )
''');

    await db.execute('''
CREATE TABLE courses ( 
  id $idType, 
  title $textType,
  provider $textType,
  status $intType,
  progress $doubleType
  )
''');

    await db.execute('''
CREATE TABLE topics ( 
  id $idType, 
  courseId $intType,
  title $textType,
  status $intType,
  FOREIGN KEY (courseId) REFERENCES courses (id) ON DELETE CASCADE
  )
''');

    await db.execute('''
CREATE TABLE subtopics ( 
  id $idType, 
  topicId $intType,
  title $textType,
  isCompleted $intType,
  FOREIGN KEY (topicId) REFERENCES topics (id) ON DELETE CASCADE
  )
''');

    await db.execute('''
CREATE TABLE goals ( 
  id $idType, 
  title $textType,
  isCompleted $intType,
  date $textType
  )
''');
  }

  // Interview Methods
  Future<Interview> createInterview(Interview interview) async {
    final db = await instance.database;
    final id = await db.insert('interviews', interview.toMap());
    return interview.copyWith(id: id);
  }

  Future<Interview> readInterview(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      'interviews',
      columns: ['id', 'companyName', 'jobRole', 'date', 'location', 'status', 'notes', 'companyType'],
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Interview.fromMap(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<List<Interview>> readAllInterviews() async {
    final db = await instance.database;
    final orderBy = 'date ASC';
    final result = await db.query('interviews', orderBy: orderBy);
    return result.map((json) => Interview.fromMap(json)).toList();
  }

  Future<int> updateInterview(Interview interview) async {
    final db = await instance.database;
    return db.update(
      'interviews',
      interview.toMap(),
      where: 'id = ?',
      whereArgs: [interview.id],
    );
  }

  Future<int> deleteInterview(int id) async {
    final db = await instance.database;
    return await db.delete(
      'interviews',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Course Methods
  Future<Course> createCourse(Course course) async {
    final db = await instance.database;
    final id = await db.insert('courses', course.toMap());
    return Course(
      id: id,
      title: course.title,
      provider: course.provider,
      status: course.status,
      progress: course.progress
    );
  }
  
  Future<List<Course>> readAllCourses() async {
    final db = await instance.database;
    final result = await db.query('courses');
    return result.map((json) => Course.fromMap(json)).toList();
  }

  Future<int> updateCourse(Course course) async {
    final db = await instance.database;
    return await db.update('courses', course.toMap(), where: 'id = ?', whereArgs: [course.id]);
  }

  Future<int> deleteCourse(int id) async {
    final db = await instance.database;
    return await db.delete('courses', where: 'id = ?', whereArgs: [id]);
  }

  // Topic Methods
  Future<Topic> createTopic(Topic topic) async {
    final db = await instance.database;
    final id = await db.insert('topics', topic.toMap());
    return Topic(id: id, courseId: topic.courseId, title: topic.title, status: topic.status);
  }

  Future<List<Topic>> readTopics(int courseId) async {
    final db = await instance.database;
    final result = await db.query('topics', where: 'courseId = ?', whereArgs: [courseId]);
    return result.map((json) => Topic.fromMap(json)).toList();
  }

  Future<int> updateTopic(Topic topic) async {
    final db = await instance.database;
    return await db.update('topics', topic.toMap(), where: 'id = ?', whereArgs: [topic.id]);
  }

  Future<int> deleteTopic(int id) async {
    final db = await instance.database;
    return await db.delete('topics', where: 'id = ?', whereArgs: [id]);
  }
  
  // SubTopic Methods
  Future<SubTopic> createSubTopic(SubTopic subTopic) async {
    final db = await instance.database;
    final id = await db.insert('subtopics', subTopic.toMap());
    return SubTopic(id: id, topicId: subTopic.topicId, title: subTopic.title, isCompleted: subTopic.isCompleted);
  }

  Future<List<SubTopic>> readSubTopics(int topicId) async {
    final db = await instance.database;
    final result = await db.query('subtopics', where: 'topicId = ?', whereArgs: [topicId]);
    return result.map((json) => SubTopic.fromMap(json)).toList();
  }
  
  Future<int> updateSubTopic(SubTopic subTopic) async {
    final db = await instance.database;
    return await db.update('subtopics', subTopic.toMap(), where: 'id = ?', whereArgs: [subTopic.id]);
  }

  // Goal Methods
  Future<int> createGoal(String title) async {
    final db = await instance.database;
    final dateStr = DateTime.now().toIso8601String().split('T')[0];
    return await db.insert('goals', {
      'title': title,
      'isCompleted': 0,
      'date': dateStr
    });
  }

  Future<List<Map<String, dynamic>>> readTodayGoals() async {
    final db = await instance.database;
    final dateStr = DateTime.now().toIso8601String().split('T')[0];
    return await db.query('goals', where: 'date = ?', whereArgs: [dateStr]);
  }

  Future<int> toggleGoal(int id, bool isCompleted) async {
    final db = await instance.database;
    return await db.update('goals', {'isCompleted': isCompleted ? 1 : 0}, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteGoal(int id) async {
    final db = await instance.database;
    return await db.delete('goals', where: 'id = ?', whereArgs: [id]);
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
