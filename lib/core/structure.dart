class TrainingTaskItem {
  int id;
  DateTime date;
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
      date: DateTime.parse(json['date']),
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