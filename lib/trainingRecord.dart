import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/structure.dart';
import 'core/util.dart';
import './logger_wrap.dart';
import './trainingDb.dart';
import './utilWidget.dart';

// ignore: must_be_immutable
class TrainingRecordScreen extends ConsumerStatefulWidget {
  final DateTime paramDate;
  final double bodyWeight;

  const TrainingRecordScreen(
      {
        Key? key,
        required this.paramDate,
        required this.bodyWeight,
      }
    ) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _TrainingRecordScreenState createState() => _TrainingRecordScreenState();
}
class _TrainingRecordScreenState extends ConsumerState<TrainingRecordScreen> {

  final dbHelper = TrainingDatabase.instance;

  // Data fields
  List<Evnet> events = [];
  void _getEventList() async {
     events = await dbHelper.getEvents();
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
        index:    ++index,
        provider: trainingProvider,
        widget:   TrainingSetFormTextList(
          provider:   trainingProvider,
          bodyWeight: widget.bodyWeight,
          weight:     0,
          reps:       0,
          lap:        0,
          mets:       0,
          kcal:       0,
          rm:         0,
        ),
      )
    );
    setState(() {
      _items = _list;
    });
  }

  int selectedEvent = 1;

  @override
  void initState() {
    super.initState();
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
                    items: events.map((event) {
                      return DropdownMenuItem(
                        value: event.id,
                        child: Text(event.name)
                      );
                    }).toList(),
                    value: selectedEvent,
                    onChanged: (int? value) {
                      setState(() {
                        selectedEvent = value!;
                      });
                    },
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
                      // handle add training data button tap here
                      int dayUnix = roundUnixTimeToDays(widget.paramDate.millisecondsSinceEpoch);
                      TrainingTask task = TrainingTask(
                        date: dayUnix,
                        eventId: selectedEvent
                      );
                      int taskId = await dbHelper.insertTrainingTask(task);
                      if (taskId > 0) {
                        logger.i('TrainingTask inserted with taskId: $taskId');
                      } else {
                        logger.i('Failed to insert TrainingTask');
                        // ignore: use_build_context_synchronously
                        Navigator.pop(context);
                      }
                      for (TrainingSetFormTextListKey item in _items) {
                        double weight = ref.watch(item.provider).weight;
                        int reps = ref.watch(item.provider).reps;
                        int lap = ref.watch(item.provider).lap;
                        double mets = ref.watch(item.provider).mets;
                        double rm = ref.watch(item.provider).rm;
                        int kcal = ref.watch(item.provider).kcal;

                        TrainingSet set = TrainingSet(
                          trainingTaskId: taskId,
                          weight: weight,
                          reps: reps,
                          lapTime: lap,
                          intervalTime: 0,
                          mets: mets,
                          rm: rm,
                          kcal: kcal,
                        );
                        int setId = await dbHelper.insertTrainingSet(set);
                        if (setId > 0) {
                          logger.i('TrainingSet inserted with setId: $setId');
                        } else {
                          logger.i('Failed to insert TrainingSet');
                          Navigator.pop(context);
                        }
                      }
                      // check if the insert was successful
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