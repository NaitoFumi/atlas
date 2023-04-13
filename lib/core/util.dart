import 'dart:collection';
import 'package:table_calendar/table_calendar.dart';

import '../logger_wrap.dart';
import '../utilWidget.dart';
import '../trainingDb.dart';
import './structure.dart';


int roundUnixTimeToDays(int unixTime) {
  int days = unixTime ~/ 86400000;
  int roundedUnixTime = days * 86400000;
  return roundedUnixTime;
}

//To assign a digit to each unit so that they do not cover each other
int getHashCode(DateTime key) {
  return key.day * 1000000 + key.month * 10000 + key.year;
}

Future<Map> loadTrainigTasks(TrainingDatabase dbHelper, DateTime startDate, DateTime endDate) async {

  Map<DateTime, List<TrainingTaskItem>> _eventsList = {};
  Map _events = {};

  for (DateTime date = startDate; date.isBefore(endDate) || date.isAtSameMomentAs(endDate); date = date.add(const Duration(days: 1))) {
    List<TrainingTaskItem> taskList = await dbHelper.getTrainingTasks(roundUnixTimeToDays(date.millisecondsSinceEpoch));
    if (taskList.isNotEmpty) {
      // logger.i('TrainingTask select');
      for (TrainingTaskItem task in taskList) {
        DateTime taskDay = DateTime.fromMillisecondsSinceEpoch(task.date);
        if(_eventsList[taskDay] == null){
          _eventsList[taskDay] = [];
        }
        _eventsList[taskDay]!.add(task);
      }
    } else {
      // logger.i('Failed to select TrainingTask');
    }
  }
   _events = LinkedHashMap<DateTime, List>(
      equals: isSameDay,
      hashCode: getHashCode,
    )..addAll(_eventsList);
  return _events;
}

Future<bool> registTrainingRecodes(int taskId, List<TrainingSetFormTextList> items, DateTime date, int eventId, TrainingDatabase dbHelper, ref ) async {

  int dayUnix = roundUnixTimeToDays(date.millisecondsSinceEpoch);

  if (taskId == 0) {
    TrainingTask task = TrainingTask(
      date: dayUnix,
      eventId: eventId
    );
    taskId = await dbHelper.insertTrainingTask(task);
    if (taskId > 0) {
      logger.i('TrainingTask inserted with taskId: $taskId');
    } else {
      logger.i('Failed to insert TrainingTask');
      return false;
    }
  }

  for (TrainingSetFormTextList item in items) {
    double weight = ref.watch(item.provider).weight;
    int reps = ref.watch(item.provider).reps;
    int lap = ref.watch(item.provider).lap;
    double mets = ref.watch(item.provider).mets;
    double rm = ref.watch(item.provider).rm;
    int kcal = ref.watch(item.provider).kcal;

    if (item.setId != 0) {
      TrainingSet set = TrainingSet(
        id: item.setId,
        trainingTaskId: taskId,
        weight: weight,
        reps: reps,
        lapTime: lap,
        intervalTime: 0,
        mets: mets,
        rm: rm,
        kcal: kcal,
      );
      int setId = await dbHelper.updateTrainingSet(set);
      if (setId > 0) {
        logger.i('TrainingSet update with setId: $setId');
      } else {
        logger.i('Failed to update TrainingSet');
      }
    }
    else {
      TrainingSet set = TrainingSet(
        trainingTaskId: taskId,
        weight: weight,
        reps: reps,
        lapTime: lap,
        intervalTime: 0,
        mets: mets,
        rm: rm,
        kcal: kcal,
      );
      int setId = await dbHelper.insertTrainingSet(set);
      if (setId > 0) {
        logger.i('TrainingSet inserted with setId: $setId');
      } else {
        logger.i('Failed to insert TrainingSet');
      }
    }
  }
  return true;
}