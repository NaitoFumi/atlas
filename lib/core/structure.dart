import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const int defEvent = 1;

class TrainingTaskItem {
  int id;
  int date;
  int eventId;
  String eventName;

  TrainingTaskItem({
    required this.id,
    required this.date,
    required this.eventId,
    required this.eventName,
  });

  factory TrainingTaskItem.fromJson(Map<String, dynamic> json) {
    return TrainingTaskItem(
      id: json['id'] as int,
      date: json['date'] as int,
      eventId: json['eventId'] as int,
      eventName: json['eventName'] as String,
    );
  }
  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date,
    'eventId': eventId,
    'eventName': eventName,
  };
}

class TrainingState {
  double weight;
  int reps;
  double rm;

  TrainingState({
    required this.weight,
    required this.reps,
    required this.rm,
  });
}

class TrainingStateController extends StateNotifier<TrainingState> {
  TrainingStateController({double weight = 0, int reps = 0, double rm = 0}) : super(
    TrainingState(
      weight: weight,
      reps: reps,
      rm: rm,
    )
  );
  void modify(weight,reps,rm) {
    state = TrainingState(
      weight: weight,
      reps: reps,
      rm: rm,
    );
  }
}

class EventSelectState {
  int selectedEventId;

  EventSelectState({
    required this.selectedEventId,
  });
}

class EventSelectStateController extends StateNotifier<EventSelectState> {
  EventSelectStateController() : super(
    EventSelectState(
      selectedEventId: defEvent,
    )
  );
  void modify(selectedEventId) {
    state = EventSelectState(
      selectedEventId: selectedEventId,
    );
  }
}

class TagSelectState {
  int selectedTagId;

  TagSelectState({
    required this.selectedTagId,
  });
}

class TagSelectStateController extends StateNotifier<TagSelectState> {
  TagSelectStateController() : super(
    TagSelectState(
      selectedTagId: 0,
    )
  );
  void modify(selectedTagId) {
    state = TagSelectState(
      selectedTagId: selectedTagId,
    );
  }
}

class TrainingSetFormTextList {
  int index;
  Widget widget;
  StateNotifierProvider<TrainingStateController, TrainingState> provider;
  int setId;

  TrainingSetFormTextList({
    required this.index,
    required this.widget,
    required this.provider,
    required this.setId,
  });
}