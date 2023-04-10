import '../logger_wrap.dart';
import '../utilWidget.dart';
import '../trainingDb.dart';
import './structure.dart';


int roundUnixTimeToDays(int unixTime) {
  int days = unixTime ~/ 86400000;
  int roundedUnixTime = days * 86400000;
  return roundedUnixTime;
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