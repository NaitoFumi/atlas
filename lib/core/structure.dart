import 'package:flutter_riverpod/flutter_riverpod.dart';

class TrainingTaskItem {
  int id;
  int date;
  int eventId;
  String eventName;
  double eventDefMets;

  TrainingTaskItem({
    required this.id,
    required this.date,
    required this.eventId,
    required this.eventName,
    required this.eventDefMets,
  });

  factory TrainingTaskItem.fromJson(Map<String, dynamic> json) {
    return TrainingTaskItem(
      id: json['id'] as int,
      date: json['date'] as int,
      eventId: json['eventId'] as int,
      eventName: json['eventName'] as String,
      eventDefMets: json['eventDefMets'] as double,
    );
  }
  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date,
    'eventId': eventId,
    'eventName': eventName,
    'eventDefMets': eventDefMets,
  };
}

class TrainingState {
  double weight;
  double mets;
  int reps;
  int lap;
  double rm;
  int kcal;

  TrainingState({
    required this.weight,
    required this.mets,
    required this.reps,
    required this.lap,
    required this.rm,
    required this.kcal,
  });
}

class TrainingStateController extends StateNotifier<TrainingState> {
  TrainingStateController() : super(
    TrainingState(
      weight: 0,
      mets: 0,
      reps: 0,
      lap: 0,
      rm: 0,
      kcal: 0,
    )
  );
  void modify(weight,mets,reps,lap,rm,kcal) {
    state = TrainingState(
      weight: weight,
      mets: mets,
      reps: reps,
      lap: lap,
      rm: rm,
      kcal: kcal,
    );
  }
}