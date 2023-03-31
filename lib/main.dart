import 'dart:collection';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import './logger_wrap.dart';
import './core/structure.dart';
import './core/util.dart';
import './utilWidget.dart';
import './traningTask.dart';
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
  late DateTime _selectedDay;
  final dbHelper = TrainingDatabase.instance;
  // Map<DateTime, List<TrainingTaskItem>> _eventsList = {};
  Map _events = {};
  final DateTime _firstDay = DateTime.utc(2020, 1, 1);
  final DateTime _lastDay = DateTime.utc(2030, 12, 31);

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadTrainigTasksForMonths(_focusedDay);
  }

  void _loadTrainigTasksForMonths(DateTime date) async {
    DateTime startDate = _focusedDay.subtract(const Duration(days: 31));
    DateTime endDate = _focusedDay.add(const Duration(days: 31));
    Map<DateTime, List<TrainingTaskItem>> _eventsList = {};
    for (DateTime date = startDate; date.isBefore(endDate); date = date.add(const Duration(days: 1))) {
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
    if(_eventsList.isNotEmpty){
      setState(() {
        _events = LinkedHashMap<DateTime, List>(
          equals: isSameDay,
          hashCode: getHashCode,
        )..addAll(_eventsList);
      });
    }
  }

  List<TrainingTaskItem> _getEventForDay(DateTime date) {
    return _events[date] ?? [];
  }

  //To assign a digit to each unit so that they do not cover each other
  int getHashCode(DateTime key) {
    return key.day * 1000000 + key.month * 10000 + key.year;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Calendar"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          TableCalendar(
            firstDay: _firstDay,
            lastDay: _lastDay,
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
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
              _loadTrainigTasksForMonths(_focusedDay);
            },
            eventLoader: _getEventForDay,
          ),
          SizedBox(
            height: 300,
            child: ListView(
              shrinkWrap: true,
              children: _getEventForDay(_selectedDay).map(
                (event) => ListTile(
                  title: Text(event.eventName),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TrainingTaskScreen(
                          paramDate: _selectedDay,
                          trainingTaskList: _getEventForDay(_selectedDay),
                        )
                      ),
                    );
                  },
                )
              )
              .toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(child: RegistTrainingTaskBtn(selectDay: _selectedDay, trainingTaskList:_getEventForDay(_selectedDay))),
                const SizedBox(width: 16),
                Expanded(child: StaticBtn()),
              ],
            ),
          ),
        ]
      )
    );
  }
}