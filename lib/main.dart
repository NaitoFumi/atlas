import 'dart:collection';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import './logger_wrap.dart';
import './trainingRecord.dart';
import './trainingDb.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CalendarScreen()
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
  // Map<DateTime, List> _eventsList = {};
  List<TrainingTask> taskList = [];

  final dbHelper = TrainingDatabase.instance;

  //event loader
  // int getHashCode(DateTime key) {
  //   return key.day * 1000000 + key.month * 10000 + key.year;
  // }
  @override
  //event loader
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    //サンプルのイベントリスト
    // _eventsList = {
    //   DateTime.now().subtract(Duration(days: 2)): ['Event A6', 'Event B6'],
    //   DateTime.now(): ['Event A7', 'Event B7', 'Event C7', 'Event D7','Event E7','Event F7','Event G7'],
    //   DateTime.now().add(Duration(days: 1)): [
    //     'Event A8',
    //     'Event B8',
    //     'Event C8',
    //     'Event D8'
    //   ],
    // };
  }

  void _getTrainingTasks() async {
    List<TrainingTask> task = await dbHelper.getTrainingTasks();
    if (task.isNotEmpty) {
      logger.d('TrainingTask select');
    } else {
      logger.d('Failed to select TrainingTask');
    }
    taskList = task;
  }

  @override
  Widget build(BuildContext context) {
    // final _events = LinkedHashMap<DateTime, List>(
    //   equals: isSameDay,
    //   hashCode: getHashCode,
    // )..addAll(_eventsList);

    List _getEventForDay(DateTime day) {
      _getTrainingTasks();
      return taskList;
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
                // eventLoader: _getEventForDay,
              ),
          ),
          SizedBox(
            height: 300,
            child: ListView(
              shrinkWrap: true,
              children: _getEventForDay(_selectedDay!)
                  .map((event) => ListTile(
                        title: Text(event.toString()),
                      ))
                  .toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // handle add training data button tap here
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => TrainingRecordScreen(paramDate: _selectedDay,)),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.add, color: Colors.white),
                        SizedBox(width: 4),
                        Text(
                          "Add",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // handle add training data button tap here
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => TrainingRecordScreen(paramDate: _selectedDay,)),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.add, color: Colors.white),
                        SizedBox(width: 4),
                        Text(
                          "",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
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