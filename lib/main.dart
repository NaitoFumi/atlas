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
  Map _events = LinkedHashMap<DateTime, List>(
    equals: isSameDay,
    hashCode: getHashCode,
  );
  final DateTime _firstDay = DateTime.utc(2020, 1, 1);
  final DateTime _lastDay = DateTime.utc(2030, 12, 31);

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    loadEvent(dbHelper,_focusedDay);
  }

  void loadEvent(TrainingDatabase dbHelper, DateTime dateTime) async {
    DateTime startDate = dateTime.subtract(const Duration(days: 31));
    DateTime endDate = dateTime.add(const Duration(days: 31));
    Map _eventsList = await loadTrainigTasks(dbHelper, startDate, endDate);
    if(_eventsList.isNotEmpty){
      setState(() {
        _events = _eventsList;
      });
    }
  }

  List<TrainingTaskItem> _getEventForDay(DateTime date) {
    return _events[date] ?? [];
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
              loadEvent(dbHelper,_focusedDay);
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
                  onTap: () async {
                    await Navigator.push(
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
                Expanded(child: RegistTrainingTaskBtn(selectDay: _selectedDay, trainingTaskList:_getEventForDay(_selectedDay),dbHelper: dbHelper,callBackFunc: loadEvent,)),
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