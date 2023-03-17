import 'dart:collection';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import './logger_wrap.dart';
import './traningTask.dart';
import './core/structure.dart';
import './trainingRecord.dart';
import './trainingDb.dart';

void main() => runApp(
    const ProviderScope(
      child: MyApp()
    ),
  );

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: CalendarScreen()
    );
  }
}

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

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
  List<TrainingTaskItem> taskList = [];

  final dbHelper = TrainingDatabase.instance;

  @override
  //event loader
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  void _getTrainingTasks(DateTime start, DateTime end) async {
    List<TrainingTaskItem> task = await dbHelper.getTrainingTasks(start, end);
    if (task.isNotEmpty) {
      logger.d('TrainingTask select');
    } else {
      logger.d('Failed to select TrainingTask');
    }

    taskList = task;
  }

  @override
  Widget build(BuildContext context) {
    List _getEventForDay(DateTime day) {
      DateTime start = DateTime(day.year, day.month, 1);
      DateTime end = DateTime(day.year, day.month + 1, 0);
      _getTrainingTasks(start, end);
      return taskList;
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Calendar"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
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
                        // MaterialPageRoute(builder: (context) => TrainingRecordScreen(paramDate: _selectedDay,)),
                        MaterialPageRoute(
                          builder: (context) =>
                          TrainingTaskScreen(
                            paramDate: _selectedDay,
                            trainingTaskList: taskList,
                          )
                        ),
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
                        Icon( Icons.add_task, color: Colors.white, size: 35,),
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
                        // MaterialPageRoute(builder: (context) => TrainingRecordScreen(paramDate: _selectedDay,)),
                        MaterialPageRoute(
                          builder: (context) =>
                          TrainingTaskScreen(
                            paramDate: _selectedDay,
                            trainingTaskList: taskList,
                          )
                        ),
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
                        Icon( Icons.analytics, color: Colors.white, size: 35,),
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