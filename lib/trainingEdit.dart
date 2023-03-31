import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/structure.dart';
import 'core/util.dart';
import './logger_wrap.dart';
import './trainingDb.dart';
import './utilWidget.dart';

// ignore: must_be_immutable
class TrainingEditScreen extends ConsumerStatefulWidget {
  final TrainingTaskItem task;
  final double bodyWeight;

  const TrainingEditScreen(
      {
        Key? key,
        required this.task,
        required this.bodyWeight,
      }
    ) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _TrainingEditScreenState createState() => _TrainingEditScreenState();
}
class _TrainingEditScreenState extends ConsumerState<TrainingEditScreen> {

  final dbHelper = TrainingDatabase.instance;

  // Data fields
  List<Evnet> events = [];
  void _getEventList() async {
     events = await dbHelper.getEvents();
  }

  List<TrainingSet> _sets =[];
  int index = 0;
  List<TrainingSetFormTextListKey> _items = <TrainingSetFormTextListKey>[];
  List<TrainingSetFormTextListKey> _list = <TrainingSetFormTextListKey>[];
  void _getTrainingSetList() async {
     _sets= await dbHelper.getTrainingSets(widget.task.id);
     logger.d(_sets);

    final StateNotifierProvider<TrainingStateController, TrainingState> trainingProvider = StateNotifierProvider<TrainingStateController, TrainingState>((ref) => TrainingStateController());

    for (final set in _sets)
    {
      _list.add(
        TrainingSetFormTextListKey(
          index:    ++index,
          provider: trainingProvider,
          widget:   TrainingSetFormTextList(
            provider:   trainingProvider,
            bodyWeight: widget.bodyWeight,
            weight:     set.weight,
            reps:       set.reps,
            lap:        set.lapTime,
            mets:       set.mets,
            kcal:       set.kcal,
            rm:         set.rm,
          ),
        )
      );
    }
    setState(() {
      _items = _list;
      logger.d(_items);
    });
  }

  int selectedEvent = 1;

  @override
  void initState() {
    super.initState();
    _getEventList();
    _getTrainingSetList();
    selectedEvent = widget.task.eventId;
  }

  @override
  Widget build(BuildContext context) {
    _getEventList();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Training Task Edit"),
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
          ],
        ),
      ),
    );
  }
}