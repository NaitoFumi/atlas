import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/structure.dart';
import './logger_wrap.dart';
import './trainingDb.dart';
import './utilWidget.dart';

List<StateNotifierProvider> providerList = [];

// ignore: must_be_immutable
class TrainingRecordScreen extends ConsumerStatefulWidget {
  // ignore: prefer_typing_uninitialized_variables
  final paramDate;

  const TrainingRecordScreen({Key? key, required this.paramDate}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _TrainingRecordScreenState createState() => _TrainingRecordScreenState();
}
class _TrainingRecordScreenState extends ConsumerState<TrainingRecordScreen> {

  final dbHelper = TrainingDatabase.instance;

  final TextEditingController _bodyWeightTtextController = TextEditingController();

  // Data fields
  List<Evnet> events = [];
  void _getEventList() async {
     events = await dbHelper.getEvents();
    //  for (var value in events) {
    //   logger.d(value.id);
    //   logger.d(value.name);
    // }
  }

  int index = 0;
  List<TrainingSetFormTextListKey> _items = <TrainingSetFormTextListKey>[];
  List<TrainingSetFormTextListKey> _list = <TrainingSetFormTextListKey>[];
  // void addWidgetList(BuildContext context) {
  void addWidgetList() {
    GlobalObjectKey<TrainingSetFormTextListState> trainingSetFromTextListKey = GlobalObjectKey<TrainingSetFormTextListState>(context);
    final StateNotifierProvider<TrainingStateController, TrainingState> trainingProvider = StateNotifierProvider<TrainingStateController, TrainingState>((ref) => TrainingStateController());

    _list.add(
      TrainingSetFormTextListKey(
        index: ++index,
        widget: TrainingSetFormTextList(
          provider: trainingProvider,
        ),
        provider: trainingProvider,
      )
    );
    setState(() {
      _items = _list;
    });
  }

  int lap = 0;
  int interval = 0;
  double mets = 0;
  double kcal = 0;

  double calculateKcal(int lap, double bodyWeight, double mets) {
    return (mets * bodyWeight * (lap / 360) * 1.05);
  }

  int selectedEvent = 1;
  late DateTime localDate;
  String a = "a";

  @override
  void initState() {
    super.initState();
    localDate = widget.paramDate;
    _getEventList();
  }

  @override
  Widget build(BuildContext context) {
    _getEventList();
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
                        // logger.d(event.name);
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
            const SizedBox(height: 16.0),
            ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemBuilder: (BuildContext context, int index){
                return _items[index].widget;
              },
              itemCount: _items.length,
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                Expanded(
                  flex: 1,
                  child: ElevatedButton(
                    onPressed: () async {
                      // addWidgetList(context);
                      addWidgetList();
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
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                Expanded(
                  flex: 1,
                  child: ElevatedButton(
                    onPressed: () async {
                      for (TrainingSetFormTextListKey item in _items) {
                        logger.d(ref.watch(item.provider).weight);
                        logger.d(ref.watch(item.provider).reps);
                        logger.d(ref.watch(item.provider).lap);
                        logger.d(ref.watch(item.provider).mets);
                      }
                      // handle add training data button tap here
                      // TrainingTask task = TrainingTask(
                      //   date: localDate,
                      //   eventId: selectedEvent
                      // );
                      // int taskId = await dbHelper.insertTrainingTask(task);
                      // if (taskId > 0) {
                      //   logger.d('TrainingTask inserted with taskId: $taskId');
                      // } else {
                      //   logger.d('Failed to insert TrainingTask');
                      //   // ignore: use_build_context_synchronously
                      //   Navigator.pop(context);
                      // }
                      // for (Widget item in _items) {
                      //     //ループ処理
                      //     item.weight
                      // }
                      // TrainingSet set = TrainingSet(
                      //   trainingTaskId: taskId,
                      //   weight: weight,
                      //   reps: reps,
                      //   lapTime: 10,
                      //   intervalTime: 10,
                      //   mets: 5.0,
                      //   kcal: 100,
                      //   rm: 10,
                      // );
                      // int setId = await dbHelper.insertTrainingSet(set);
                      // // check if the insert was successful
                      // if (setId > 0) {
                      //   logger.d('TrainingSet inserted with setId: $setId');
                      // } else {
                      //   logger.d('Failed to insert TrainingSet');
                      //   Navigator.pop(context);
                      // }
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
                        Icon(Icons.done_outlined, color: Colors.white),
                        SizedBox(width: 4),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}