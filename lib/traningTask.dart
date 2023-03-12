import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import './logger_wrap.dart';
import './core/structure.dart';
import './trainingDb.dart';
import './utilWidget.dart';
import './trainingRecord.dart';

class TrainingTaskScreen extends StatefulWidget {

  final paramDate;
  final List<TrainingTaskItem> trainingTaskList;

  TrainingTaskScreen(
    {
      Key? key,
      required this.paramDate,
      required this.trainingTaskList,
    }
  );

  @override
  // ignore: library_private_types_in_public_api
  _TrainingTaskScreenState createState() => _TrainingTaskScreenState();
}

class _TrainingTaskScreenState extends State<TrainingTaskScreen> {

  final dbHelper = TrainingDatabase.instance;
  List<Evnet> eventsList = [];

  void _getTrainingEvents() async {
    List<Evnet> events = await dbHelper.getEvents();
    if (events.isNotEmpty) {
      logger.d('TrainingEvents select');
    } else {
      logger.d('Failed to select TrainingEvents');
    }
    eventsList = events;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.paramDate.toString()),
      ),
      floatingActionButton: Container(
        width: 80,
        height: 80,
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TrainingRecordScreen(paramDate: widget.paramDate,)),
            );
          },
          child: Icon(
            Icons.add_task, color: Colors.white, size: 60,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Row(
              children: [
                Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemBuilder: (BuildContext context, int index){
                      return TrainingTaskList(trainingTaskItem:widget.trainingTaskList[index]);
                    },
                    itemCount: widget.trainingTaskList.length,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}