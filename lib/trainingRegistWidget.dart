import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/structure.dart';
import 'core/util.dart';
import './logger_wrap.dart';
import './trainingDb.dart';
import './utilWidget.dart';

// ignore: must_be_immutable
class TrainingRegistWidget extends ConsumerStatefulWidget {
  final TrainingTaskItem? task;
  final double bodyWeight;
  final DateTime paramDate;
  final String title;

  const TrainingRegistWidget(
      {
        Key? key,
        this.task,
        required this.bodyWeight,
        required this.paramDate,
        required this.title,
      }
    ) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _TrainingRegistWidgetState createState() => _TrainingRegistWidgetState();
}
class _TrainingRegistWidgetState extends ConsumerState<TrainingRegistWidget> {

  final dbHelper = TrainingDatabase.instance;

  // Data fields
  List<Evnet> events = [];
  void _getEventList() async {
     events = await dbHelper.getEvents();
  }

  List<TrainingSet> _sets =[];
  int index = 0;
  List<TrainingSetFormTextList> _items = <TrainingSetFormTextList>[];
  List<TrainingSetFormTextList> _list = <TrainingSetFormTextList>[];

  void _getTrainingSetList(int taskId) async {
    logger.d(taskId);
     _sets= await dbHelper.getTrainingSets(taskId);
    logger.d(_sets);

    final StateNotifierProvider<TrainingStateController, TrainingState> trainingProvider = StateNotifierProvider<TrainingStateController, TrainingState>((ref) => TrainingStateController());

    for (final set in _sets)
    {
      _list.add(
        TrainingSetFormTextList(
          index:    ++index,
          provider: trainingProvider,
          setId:    set.id!,
          widget:   TrainingSetFormTextWidget(
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
    });
  }

  void addWidgetList() {
    final StateNotifierProvider<TrainingStateController, TrainingState> trainingProvider = StateNotifierProvider<TrainingStateController, TrainingState>((ref) => TrainingStateController());

    _list.add(
      TrainingSetFormTextList(
        index:    ++index,
        provider: trainingProvider,
        setId:    0,
        widget:   TrainingSetFormTextWidget(
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

  int paramTaskId = 0;

  int selectedEvent = defEvent;
  final StateNotifierProvider<EventSelectStateController, EventSelectState> eventSelectProvider = StateNotifierProvider<EventSelectStateController, EventSelectState>((ref) => EventSelectStateController());

  @override
  void initState() {
    super.initState();
    _getEventList();
    if (widget.task != null) {
      paramTaskId = widget.task!.id;
      _getTrainingSetList(paramTaskId);
      selectedEvent = widget.task!.eventId;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Row(
              children: [
                Expanded(
                  child: EventsMenu(
                    events: events,
                    selectedEvent: selectedEvent,
                    provider: eventSelectProvider,
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
                  child: AddBtnTrainingSetForm(onPressedCallback: addWidgetList,)
                ),
                const Spacer(),
                Expanded(
                  flex: 1,
                  child: RegistBtnTrainingSet(
                    taskId:              paramTaskId,
                    trainingSetFormList: _items,
                    date:                widget.paramDate,
                    eventId:             ref.watch(eventSelectProvider).selectedEventId,
                    dbHelper:            dbHelper,
                    ref:                 ref,
                  )
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