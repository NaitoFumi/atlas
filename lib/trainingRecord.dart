import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import './trainingDb.dart';

final logger = Logger();

// Data fields
  // // Form fields
  // String selectedEvent = "Event 1";
  // String selectedPart = "Part 1";

// ignore: must_be_immutable
class TrainingRecordScreen extends StatefulWidget {
  // ignore: prefer_typing_uninitialized_variables
  var paramDate;

  // const TrainingRecordScreen(this.selectedDay);
  // const TrainingRecordScreen(DateTime? selectedDay, {super.key});
  TrainingRecordScreen({Key? key, required this.paramDate}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _TrainingRecordScreenState createState() => _TrainingRecordScreenState();
}
class _TrainingRecordScreenState extends State<TrainingRecordScreen> {
  final dbHelper = TrainingDatabase.instance;
  // Data fields
  List<Evnet> events = [];
  void _getEventList() async {
     events = await dbHelper.getEvents();
    //  for (var value in events) {
    //   logger.d(value.id);
    //   logger.d(value.name);
    // }
  }
  // List<String> events = ["Event 1", "Event 2"];
  int weight = 0;
  int reps = 0;

  // Form fields
  int selectedEvent = 1;

  late DateTime localDate;

  @override
  void initState() {
    super.initState();
    localDate = widget.paramDate;
    _getEventList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Training Task Regist"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            DropdownButtonFormField(
              // Populate list of events
              items: events.map((event) {
                logger.d(event.name);
                return DropdownMenuItem(
                  value: event.id,
                  child: Text(event.name)
                  // child: Text(event.name)
                );
              }).toList(),
              // Set the value
              value: selectedEvent,
              onChanged: (int? value) {
                setState(() {
                  selectedEvent = value!;
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
              ),
            ElevatedButton(
              onPressed: () async {
                // handle add training data button tap here
                // create a new TrainingTask object
                TrainingTask task = TrainingTask(
                  date: localDate,
                  eventId: selectedEvent
                );
                int taskId = await dbHelper.insertTrainingTask(task);
                // check if the insert was successful
                if (taskId > 0) {
                  logger.d('TrainingTask inserted with taskId: $taskId');
                } else {
                  logger.d('Failed to insert TrainingTask');
                  // ignore: use_build_context_synchronously
                  Navigator.pop(context);
                }
                TrainingSet set = TrainingSet(
                  trainingTaskId: taskId,
                  weight: weight.toDouble(),
                  reps: reps,
                  lapTime: 10,
                  intervalTime: 10,
                  mets: 5.0,
                  kcal: 100,
                  rm: 10,
                );
                int setId = await dbHelper.insertTrainingSet(set);
                // check if the insert was successful
                if (setId > 0) {
                  logger.d('TrainingSet inserted with setId: $setId');
                } else {
                  logger.d('Failed to insert TrainingSet');
                  Navigator.pop(context);
                }
                Navigator.pop(context);
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
                    "Regist",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}