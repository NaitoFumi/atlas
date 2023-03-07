import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import './logger_wrap.dart';
import './trainingDb.dart';

// ignore: must_be_immutable
class TrainingRecordScreen extends StatefulWidget {
  // ignore: prefer_typing_uninitialized_variables
  var paramDate;

  TrainingRecordScreen({Key? key, required this.paramDate}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _TrainingRecordScreenState createState() => _TrainingRecordScreenState();
}
class _TrainingRecordScreenState extends State<TrainingRecordScreen> {
  final dbHelper = TrainingDatabase.instance;
  TextEditingController _weightTtextController = TextEditingController();
  TextEditingController _repsTtextController = TextEditingController();
  TextEditingController _lapTtextController = TextEditingController();
  TextEditingController _metsTtextController = TextEditingController();
  TextEditingController _bodyWeightTtextController = TextEditingController();
  // Data fields
  List<Evnet> events = [];
  void _getEventList() async {
     events = await dbHelper.getEvents();
     for (var value in events) {
      logger.d(value.id);
      logger.d(value.name);
    }
  }
  double weight = 0;
  int reps = 0;
  double rm = 0;
  double calculateRM(double weight, int reps) {
    return (weight * (1 + (reps / 30)));
  }
  int lap = 0;
  int interval = 0;
  double mets = 0;
  double kcal = 0;
  double bodyWeight = 0;
  double calculateKcal(int lap, double bodyWeight, double mets) {
    return (mets * bodyWeight * (lap / 360) * 1.05);
  }

  int selectedEvent = 1;
  late DateTime localDate;

  @override
  void initState() {
    super.initState();
    localDate = widget.paramDate;
    _getEventList();
    _weightTtextController.addListener(_updateWeight);
    _repsTtextController.addListener(_updateReps);
    _lapTtextController.addListener(_updateLap);
    _metsTtextController.addListener(_updateMets);
    _bodyWeightTtextController.addListener(_updateBodyWeight);
  }
  void _updateWeight() {
    setState(() {
      weight = double.parse(_weightTtextController.text);
      rm = calculateRM(weight, reps);
    });
  }
  void _updateReps() {
    setState(() {
      reps = int.parse(_repsTtextController.text);
      rm = calculateRM(weight, reps);
    });
  }
  void _updateLap() {
    setState(() {
      lap = int.parse(_lapTtextController.text);
      kcal = calculateKcal(lap, bodyWeight, mets);
    });
  }
  void _updateMets(){
    setState(() {
      mets = double.parse(_metsTtextController.text);
      kcal = calculateKcal(lap, bodyWeight, mets);
    });
  }
  void _updateBodyWeight() {
    setState(() {
      bodyWeight = double.parse(_bodyWeightTtextController.text);
      kcal = calculateKcal(lap, bodyWeight, mets);
    });
  }

  @override
  void dispose() {
    _weightTtextController.dispose();
    _repsTtextController.dispose();
    _lapTtextController.dispose();
    _metsTtextController.dispose();
    _bodyWeightTtextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    logger.d(events);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Training Task Regist"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField(
                      // Populate list of events
                      items: events.map((event) {
                        logger.d(event.name);
                        return DropdownMenuItem(
                          value: event.id,
                          child: Text(event.name)
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
                  ),
                  Expanded( //weight
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            controller: _bodyWeightTtextController,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly // Only numbers can be entered
                            ],
                            decoration: const InputDecoration(
                              hintText: 'Enter a number',
                              border: OutlineInputBorder(),
                              labelText: "Body  Weight",
                              suffix: Text('kg'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            SizedBox(height: 16.0),
            Column(
              children: <Widget>[
                Row( //weight reps
                  children: [
                    Expanded( //weight
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              controller: _weightTtextController,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.digitsOnly // Only numbers can be entered
                              ],
                              decoration: const InputDecoration(
                                hintText: 'Enter a number',
                                border: OutlineInputBorder(),
                                labelText: "Weight",
                                suffix: Text('kg'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded( //reps
                      child:Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children:<Widget>[
                          Expanded(
                            child:TextFormField(
                              keyboardType: TextInputType.number,
                              controller: _repsTtextController,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.digitsOnly // Only numbers can be entered
                              ],
                              decoration:const InputDecoration(
                                hintText: 'Enter a number',
                                border: OutlineInputBorder(),
                                labelText: "Reps",
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ]
                ),
                Row( //lap interval mets
                  children: [
                    Expanded( //lap
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              controller: _lapTtextController,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.digitsOnly // Only numbers can be entered
                              ],
                              decoration: const InputDecoration(
                                hintText: 'Enter a time',
                                border: OutlineInputBorder(),
                                labelText: "Lap",
                              ),
                            ),
                          )
                        ]
                      ),
                    ),
                    // Expanded( //interval
                    //   child: Row(
                    //     mainAxisAlignment: MainAxisAlignment.center,
                    //     children: <Widget>[
                    //       Expanded(
                    //         child: TextFormField(
                    //           keyboardType: TextInputType.number,
                    //           inputFormatters: <TextInputFormatter>[
                    //             FilteringTextInputFormatter.digitsOnly // Only numbers can be entered
                    //           ],
                    //           decoration: const InputDecoration(
                    //             hintText: 'Enter a time',
                    //             border: OutlineInputBorder(),
                    //             labelText: "Interval",
                    //           ),
                    //         ),
                    //       )
                    //     ]
                    //   ),
                    // ),
                    Expanded( //mets
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              controller: _metsTtextController,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.digitsOnly // Only numbers can be entered
                              ],
                              decoration: const InputDecoration(
                                hintText: 'Enter a time',
                                border: OutlineInputBorder(),
                                labelText: "mets",
                              ),
                            ),
                          )
                        ]
                      ),
                    ),
                  ],
                ),
                Column( //rm
                  children: [
                    Text(
                      '1RM = ${rm.toStringAsFixed(1)} kg',
                      style: TextStyle(fontSize: 24.0),
                    ),
                    SizedBox(height: 16.0),
                    Text(
                      'Formula: ${weight} kg x (1 + ${reps} / 30)',
                      style: TextStyle(fontSize: 16.0),
                    ),
                  ],
                ),
                Column( //kcal
                  children: [
                    Text(
                      '${kcal.toStringAsFixed(1)} kcal',
                      style: TextStyle(fontSize: 24.0),
                    ),
                    SizedBox(height: 16.0),
                    Text(
                      'Formula: ${mets} x ${bodyWeight} * ( ${lap} / 360 ) * 1.05',
                      style: TextStyle(fontSize: 16.0),
                    ),
                  ],
                ),
              ]
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