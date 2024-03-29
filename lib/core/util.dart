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

Future<bool> registTrainingRecodes(int taskId, List<MapEntry<int, TrainingSetFormTextWidget>> trainingSetFormList, DateTime date, int eventId, TrainingDatabase dbHelper, ref ) async {

  int dayUnix = roundUnixTimeToDays(date.millisecondsSinceEpoch);
  logger.d(taskId);

  if (taskId == 0) {
    TrainingTask task = TrainingTask(
      date: dayUnix,
      eventId: eventId
    );
    int _taskId = await dbHelper.insertTrainingTask(task);
    if (_taskId > 0) {
      logger.i('TrainingTask inserted with taskId: $_taskId');
    } else {
      logger.i('Failed to insert TrainingTask');
      return false;
    }
  }
  else {
    TrainingTask task = TrainingTask(
      id: taskId,
      date: dayUnix,
      eventId: eventId
    );
    int _taskId = await dbHelper.updateTrainingTask(task);
    if (_taskId > 0) {
      logger.i('TrainingTask updated with taskId: $_taskId');
    } else {
      logger.i('Failed to updated TrainingTask');
      return false;
    }
  }
  trainingSetFormList.forEach((trainingSetForm) async {
    double weight = ref.watch(trainingSetForm.value.provider).weight;
    int reps = ref.watch(trainingSetForm.value.provider).reps;
    double rm = ref.watch(trainingSetForm.value.provider).rm;
    if (trainingSetForm.value.setId != 0) {
      if(reps != 0 || weight != 0) {
        TrainingSet set = TrainingSet(
          id: trainingSetForm.value.setId,
          trainingTaskId: taskId,
          weight: weight,
          reps: reps,
          rm: rm,
        );
        int setId = await dbHelper.updateTrainingSet(set);
        if (setId > 0) {
          logger.i('TrainingSet update with setId: $setId');
        } else {
          logger.i('Failed to update TrainingSet');
        }
      } else {
        int setId = await dbHelper.deleteTrainingSet(trainingSetForm.value.setId);
        if (setId > 0) {
          logger.i('TrainingSet delete with setId: $setId');
        } else {
          logger.i('Failed to delete TrainingSet');
        }
      }
    }
    else {
      if(reps != 0 || weight != 0) {
        TrainingSet set = TrainingSet(
          trainingTaskId: taskId,
          weight: weight,
          reps: reps,
          rm: rm,
        );
        int setId = await dbHelper.insertTrainingSet(set);
        if (setId > 0) {
          logger.i('TrainingSet inserted with setId: $setId');
        } else {
          logger.i('Failed to insert TrainingSet');
        }
      }
    }
  });

  List<TrainingSet> setList = [];
  setList = await dbHelper.getTrainingSets(taskId);
  if(setList.isEmpty) {
    int _taskId = await dbHelper.deleteTrainingTask(taskId);
    if (_taskId > 0) {
      logger.i('TrainingTask delete with taskId: $_taskId');
    } else {
      logger.i('Failed to delete TrainingTask');
    }
  }
  return true;
}