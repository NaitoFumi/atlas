import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Your other code here
      home: CalendarScreen()
      // home: TrainingRecordScreen()
    );
  }
}

class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}
class _CalendarScreenState extends State<CalendarScreen> {

  // This function is used to listen to the date changes.
  void onSelectedDate(DateTime dateTime) {}
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime? _selectedDay;
  Map<DateTime, List> _eventsList = {};

  // Data fields
  List<String> events = ["Event 1", "Event 2"];
  List<String> parts = ["Part 1", "Part 2"];

  // Form fields
  String selectedEvent = "Event 1";
  String selectedPart = "Part 1";

  //event loader
  int getHashCode(DateTime key) {
    return key.day * 1000000 + key.month * 10000 + key.year;
  }
  @override
  //event loader
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    //サンプルのイベントリスト
    _eventsList = {
      DateTime.now().subtract(Duration(days: 2)): ['Event A6', 'Event B6'],
      DateTime.now(): ['Event A7', 'Event B7', 'Event C7', 'Event D7'],
      DateTime.now().add(Duration(days: 1)): [
        'Event A8',
        'Event B8',
        'Event C8',
        'Event D8'
      ],
      DateTime.now().add(Duration(days: 3)):
          Set.from(['Event A9', 'Event A9', 'Event B9']).toList(),
      DateTime.now().add(Duration(days: 7)): [
        'Event A10',
        'Event B10',
        'Event C10'
      ],
      DateTime.now().add(Duration(days: 11)): ['Event A11', 'Event B11'],
      DateTime.now().add(Duration(days: 17)): [
        'Event A12',
        'Event B12',
        'Event C12',
        'Event D12'
      ],
      DateTime.now().add(Duration(days: 22)): ['Event A13', 'Event B13'],
      DateTime.now().add(Duration(days: 26)): [
        'Event A14',
        'Event B14',
        'Event C14'
      ],
    };
  }

  @override
  Widget build(BuildContext context) {
    final _events = LinkedHashMap<DateTime, List>(
      equals: isSameDay,
      hashCode: getHashCode,
    )..addAll(_eventsList);

    List _getEventForDay(DateTime day) {
      return _events[day] ?? [];
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Calendar"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            child:
              TableCalendar(
                // 以下必ず設定が必要
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                onFormatChanged: (format) {
                  if (_calendarFormat != format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  }
                },
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  if (!isSameDay(_selectedDay, selectedDay)) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  }
                },
                eventLoader: _getEventForDay,
              ),
          ),
          ListView(
            shrinkWrap: true,
            children: _getEventForDay(_selectedDay!)
                .map((event) => ListTile(
                      title: Text(event.toString()),
                    ))
                .toList(),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: DropdownButtonFormField(
                    // Populate list of events
                    items: events.map((event) {
                      return DropdownMenuItem(
                        value: event,
                        child: Text(event)
                      );
                    }).toList(),
                    // Set the value
                    value: selectedEvent,
                    onChanged: (String? value) {
                      setState(() {
                        selectedEvent = value!;
                      });
                    },
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField(
                    // Populate list of parts
                    items: parts.map((part) {
                      return DropdownMenuItem(
                        value: part,
                        child: Text(part)
                      );
                    }).toList(),
                    // Set the value
                    value: selectedPart,
                    onChanged: (String? value) {
                      setState(() {
                        selectedPart = value!;
                      });
                    },
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField(
                    // Populate list of parts
                    items: parts.map((part) {
                      return DropdownMenuItem(
                        value: part,
                        child: Text(part)
                      );
                    }).toList(),
                    // Set the value
                    value: selectedPart,
                    onChanged: (String? value) {
                      setState(() {
                        selectedPart = value!;
                      });
                  },
                  ),
                ),
              ],
            ),
          ),
        ]
      )
    );
  }
}
class TrainingRecordScreen extends StatefulWidget {
  const TrainingRecordScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _TrainingRecordScreenState createState() => _TrainingRecordScreenState();
}
class _TrainingRecordScreenState extends State<TrainingRecordScreen> {
  // Data fields
  List<String> events = ["Event 1", "Event 2"];
  List<String> parts = ["Part 1", "Part 2"];
  int weight = 0;
  int reps = 0;

  // Form fields
  String selectedEvent = "Event 1";
  String selectedPart = "Part 1";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Training Record"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            DropdownButtonFormField(
              // Populate list of events
              items: events.map((event) {
                return DropdownMenuItem(
                  value: event,
                  child: Text(event)
                );
              }).toList(),
              // Set the value
              value: selectedEvent,
              onChanged: (String? value) {
                setState(() {
                  selectedEvent = value!;
                });
             },
            ),
            DropdownButtonFormField(
              // Populate list of parts
              items: parts.map((part) {
                return DropdownMenuItem(
                  value: part,
                  child: Text(part)
                );
              }).toList(),
              // Set the value
              value: selectedPart,
              onChanged: (String? value) {
                setState(() {
                  selectedPart = value!;
                });
             },
            ),
            // Slider for the weight
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text("Weight"),
                SizedBox(
                  width: 100,
                  child: Slider(
                    value: weight.toDouble(),
                    min: 0,
                    max: 200,
                    divisions: 20,
                    label: '$weight kgs',
                    onChanged: (value) {
                      setState(() {
                        weight = value.round();
                      });
                    },
                  ),
                ),
                Text("$weight kg"),
              ],
            ),
            // Slider for the reps
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text("Number of Reps"),
                  SizedBox(
                    width: 100,
                    child: Slider(
                      value: reps.toDouble(),
                      min: 0,
                      max: 25,
                      divisions: 25,
                      label: '$reps reps',
                      onChanged: (value) {
                        setState(() {
                          reps = value.round();
                        });
                      },
                    ),
                  ),
                  Text("$reps reps"),
                ],
              )
          ],
        ),
      ),
    );
  }
}