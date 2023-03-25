// ignore: file_names
import 'dart:async';
import 'dart:developer';
import 'dart:ffi';
import 'dart:io';
// import 'package:logger/logger.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import './logger_wrap.dart';
import './core/structure.dart';

class BodyComposition {
  int? id;
  int date;
  double bodyWeight;
  double bfp;


  BodyComposition({
    this.id,
    required this.date,
    required this.bodyWeight,
    required this.bfp,
  });

  factory BodyComposition.fromJson(Map<String, dynamic> json) {
    return BodyComposition(
      id: json['id'] as int,
      date: json['date'] as int,
      bodyWeight: json['bodyWeight'] as double,
      bfp: json['bfp'] as double,
    );
  }
  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date,
    'bodyWeight': bodyWeight,
    'bfp': bfp,
  };
}
class Evnet {
  int? id;
  String name;
  double defMets;

  Evnet({
    this.id,
    required this.name,
    required this.defMets,
  });

  factory Evnet.fromJson(Map<String, dynamic> json) {
    return Evnet(
      id: json['id'] as int,
      name: json['name'] as String,
      defMets: json['defMets'] as double,
    );
  }
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'defMets': defMets,
  };
}

class TrainingTask {
  int? id;
  int date;
  int eventId;

  TrainingTask({
    this.id,
    required this.date,
    required this.eventId,
  });

  factory TrainingTask.fromJson(Map<String, dynamic> json) {
    return TrainingTask(
      id: json['id'] as int,
      date: json['date'] as int,
      eventId: json['eventId'] as int,
    );
  }
  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date,
        'eventId': eventId,
  };
}

class TrainingSet {
  int? id;
  int trainingTaskId;
  double weight;
  int reps;
  int lapTime;
  int intervalTime;
  double mets;
  int kcal;
  double rm;

  TrainingSet({
    this.id,
    required this.trainingTaskId,
    required this.weight,
    required this.reps,
    required this.lapTime,
    required this.intervalTime,
    required this.mets,
    required this.kcal,
    required this.rm,
  });

  factory TrainingSet.fromJson(Map<String, dynamic> json) {
    return TrainingSet(
      id: json['id'] as int,
      trainingTaskId: json['trainingTaskId'] as int,
      weight: json['weight'] as double,
      reps: json['reps'] as int,
      lapTime: json['lapTime'] as int,
      intervalTime: json['intervalTime'] as int,
      mets: json['mets'] as double,
      kcal: json['kcal'] as int,
      rm: json['rm'] as double,
    );
  }
  Map<String, dynamic> toJson() => {
    'id': id,
    'trainingTaskId': trainingTaskId,
    'weight': weight,
    'reps': reps,
    'lapTime': lapTime,
    'intervalTime': intervalTime,
    'mets': mets,
    'kcal': kcal,
    'rm': rm,
  };
}

class Tag {
  int? id;
  String name;

  Tag({
    this.id,
    required this.name,
  });

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
  };
}

class TagTask {
  int? id;
  int tagId;
  int trainingTaskId;

  TagTask({
    this.id,
    required this.tagId,
    required this.trainingTaskId
  });

  factory TagTask.fromJson(Map<String, dynamic> json) {
    return TagTask(
      id: json['id'] as int,
      tagId: json['tagId'] as int,
      trainingTaskId: json['trainingTaskId'] as int,
    );
  }
  Map<String, dynamic> toJson() => {
    'id': id,
    'tagId': tagId,
    'trainingTaskId': trainingTaskId,
  };
}

class RotineGroup {
  int? id;
  String name;

  RotineGroup({
    this.id,
    required this.name,
  });

  factory RotineGroup.fromJson(Map<String, dynamic> json) {
    return RotineGroup(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
  };
}

class RotineTask {
  int? id;
  int eventId;
  int routineGroupId;

  RotineTask({
    this.id,
    required this.eventId,
    required this.routineGroupId
  });

  factory RotineTask.fromJson(Map<String, dynamic> json) {
    return RotineTask(
      id: json['id'] as int,
      eventId: json['eventId'] as int,
      routineGroupId: json['routineGroupId'] as int,
    );
  }
  Map<String, dynamic> toJson() => {
    'id': id,
    'eventId': eventId,
    'routineGroupId': routineGroupId,
  };
}

class RotineSet {
  int? id;
  int routineITaskd;
  double weight;
  int reps;
  int lapTime;
  int intervalTime;
  double mets;

  RotineSet({
    this.id,
    required this.routineITaskd,
    required this.weight,
    required this.reps,
    required this.lapTime,
    required this.intervalTime,
    required this.mets,
  });
  factory RotineSet.fromJson(Map<String, dynamic> json) {
    return RotineSet(
      id: json['id'] as int,
      routineITaskd: json['routineITaskd'] as int,
      weight: json['weight'] as double,
      reps: json['reps'] as int,
      lapTime: json['lapTime'] as int,
      intervalTime: json['intervalTime'] as int,
      mets: json['mets'] as double,
    );
  }
  Map<String, dynamic> toJson() => {
    'id': id,
    'routineITaskd': routineITaskd,
    'weight': weight,
    'reps': reps,
    'lapTime': lapTime,
    'intervalTime': intervalTime,
    'mets': mets,
  };
}

class TrainingDatabase {
  static final TrainingDatabase instance = TrainingDatabase._init();

  static Database? _database;

  TrainingDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('training.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    // logger.i("_initDB");
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE body_composition(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date INTEGER NOT NULL UNIQUE,
        bodyWeight REAL NOT NULL,
        bfp REAL NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE event(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        defMets REAL NOT NULL
      )
    ''');
    await db.rawQuery('''
      INSERT INTO event (name, defMets)
      VALUES
       ('Running', 8.0),
       ('Squat', 6.0),
       ('Dead Lift', 6.0),
       ('Bench Press', 3.0)
    ''');
    await db.execute('''
      CREATE TABLE training_task(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date INTEGER NOT NULL,
        eventId INTEGER NOT NULL,
        FOREIGN KEY(eventId) REFERENCES evnet(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE TABLE training_set(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        trainingTaskId INTEGER NOT NULL,
        weight REAL NOT NULL,
        reps INTEGER NOT NULL,
        lapTime INTEGER NOT NULL,
        intervalTime INTEGER NOT NULL,
        mets REAL NOT NULL,
        kcal INTEGER NOT NULL,
        rm REAL NOT NULL,
        FOREIGN KEY(trainingTaskId) REFERENCES training_task(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE TABLE tag(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE tag_task(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tagId INTEGER NOT NULL,
        trainingTaskId INTEGER NOT NULL,
        FOREIGN KEY(tagId) REFERENCES tag(id) ON DELETE CASCADE,
        FOREIGN KEY(trainingTaskId) REFERENCES training_task(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE TABLE routine_group(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE routine_task(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        eventId INTEGER NOT NULL,
        routineGroupId INTEGER NOT NULL,
        FOREIGN KEY(eventId) REFERENCES evnet(id) ON DELETE CASCADE,
        FOREIGN KEY(routineGroupId) REFERENCES routine_group(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE TABLE routine_set(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        routineITaskd INTEGER NOT NULL,
        weight REAL NOT NULL,
        reps INTEGER NOT NULL,
        lapTime INTEGER NOT NULL,
        intervalTime INTEGER NOT NULL,
        mets REAL NOT NULL,
        FOREIGN KEY(routineITaskd) REFERENCES routine_task(id) ON DELETE CASCADE
      )
    ''');
  }

  Future<List<BodyComposition>> getBodyComposition(int date) async {
    // logger.i("getBodyComposition");
    final db = await instance.database;
    final result = await db.rawQuery(
      'SELECT * FROM body_composition WHERE date= ?',[date],
    );
    return result.map((json) => BodyComposition.fromJson(json)).toList();
  }
  Future<int> insertBodyComposition(BodyComposition data) async {
    // logger.i("insertBodyComposition");
    final db = await instance.database;
    return await db.insert('body_composition', data.toJson());
  }
  Future<int> updateBodyComposition(BodyComposition data) async {
    final db = await instance.database;
    return await db.update(
      'body_composition',
      data.toJson(),
      where: 'id = ?',
      whereArgs: [data.id],
    );
  }
  Future<List<Evnet>> getEvents() async {
    // logger.i("getEvents");
    final db = await instance.database;
    final result = await db.rawQuery(
      'SELECT * FROM event'
    );
    return result.map((json) => Evnet.fromJson(json)).toList();
  }
  // Future<List<TrainingTaskItem>> getTrainingTasks(int start, int end) async {
  Future<List<TrainingTaskItem>> getTrainingTasks(int day) async {
    final db = await instance.database;
    final result = await db.rawQuery(
      // 'SELECT * FROM training_task WHERE date BETWEEN ? AND ?',[start, end],
      // 'SELECT * FROM training_task WHERE date BETWEEN ? AND ? AND eventId IN (SELECT id AS eventId, name AS eventName, defMets AS eventDefMets FROM event)',[start.toIso8601String(), end.toIso8601String()],
      // '  SELECT training_task.*, event.name AS eventName, event.defMets AS eventDefMets FROM training_task WHERE date BETWEEN ? AND ?JOIN event ON training_task.eventId = event.id', [start, end],
      // '''
      //   SELECT
      //     training_task.*,
      //     event.name AS eventName,
      //     event.defMets AS eventDefMets
      //   FROM training_task
      //   JOIN event ON training_task.eventId = event.id
      //   WHERE
      //     training_task.date >= ?
      //     AND training_task.date <= ?
      // ''',
      // [start, end],
      '''
        SELECT
          training_task.*,
          event.name AS eventName,
          event.defMets AS eventDefMets
        FROM training_task
        JOIN event ON training_task.eventId = event.id
        WHERE
          training_task.date = ?
      ''',
      [day],
    );
    // logger.d(day);
    return result.map((json) => TrainingTaskItem.fromJson(json)).toList();
  }
  Future<int> insertTrainingTask(TrainingTask task) async {
    logger.d(task);
    final db = await instance.database;
    return await db.insert('training_task', task.toJson());
  }
  Future<int> updateTrainingTask(TrainingTask task) async {
    final db = await instance.database;
    return await db.update(
      'training_task',
      task.toJson(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }
  Future<int> deleteTrainingTask(int id) async {
    final db = await instance.database;
    return await db.delete(
      'training_task',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<TrainingSet>> getTrainingSets(int taskId) async {
    final db = await instance.database;

    final result = await db.query(
      'training_set',
      where: 'task_id = ?',
      whereArgs: [taskId],
    );

    return result.map((json) => TrainingSet.fromJson(json)).toList();
  }
  Future<int> insertTrainingSet(TrainingSet set) async {
    final db = await instance.database;

    return await db.insert('training_set', set.toJson());
  }
  Future<int> updateTrainingSet(TrainingSet set) async {
    final db = await instance.database;
    return await db.update(
      'training_set',
      set.toJson(),
      where: 'id = ?',
      whereArgs: [set.id],
    );
  }
  Future<int> deleteTrainingSet(int id) async {
    final db = await instance.database;
    return await db.delete(
      'training_set',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Tag>> getTag() async {
    final db = await instance.database;
    final result = await db.query('tag');
    return result.map((json) => Tag.fromJson(json)).toList();
  }
  Future<int> insertTag(Tag tag) async {
    final db = await instance.database;
    return await db.insert('tag', tag.toJson());
  }
  Future<int> updateTag(Tag tag) async {
    final db = await instance.database;
    return await db.update(
      'tag',
      tag.toJson(),
      where: 'id = ?',
      whereArgs: [tag.id],
    );
  }
  Future<int> deleteTag(int id) async {
    final db = await instance.database;
    return await db.delete(
      'tag',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<TagTask>> getTaskTag(int taskId) async {
    final db = await instance.database;
    final result = await db.query(
      'tag_task',
      where: 'task_id = ?',
      whereArgs: [taskId],
    );
    return result.map((json) => TagTask.fromJson(json)).toList();
  }
  Future<int> insertTaskTag(TagTask tag_task) async {
    final db = await instance.database;
    return await db.insert('tag_task', tag_task.toJson());
  }
  Future<int> updateTaskTag(TagTask tag_task) async {
    final db = await instance.database;
    return await db.update(
      'tag_task',
      tag_task.toJson(),
      where: 'id = ?',
      whereArgs: [tag_task.id],
    );
  }
  Future<int> deleteTaskTag(int id) async {
    final db = await instance.database;
    return await db.delete(
      'tag_task',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}