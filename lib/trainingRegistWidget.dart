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
  _TrainingRegistWidgetState createState() => _TrainingRegistWidgetState();
}
class _TrainingRegistWidgetState extends ConsumerState<TrainingRegistWidget> {

  final dbHelper = TrainingDatabase.instance;

  // Data fields
  int selectedEvent = defEvent;
  List<Event> events = [];

  void _getEventList() async {
    List<Event> _events = await dbHelper.getEvents();
    setState(() {
      events = _events;
    });
  }

  List<TrainingSet> _sets =[];
  int index = 0;
  List<TrainingSetFormTextList> _items = <TrainingSetFormTextList>[];
  List<TrainingSetFormTextList> _list = <TrainingSetFormTextList>[];

  void _getTrainingSetList(int taskId) async {
     _sets= await dbHelper.getTrainingSets(taskId);
    for (final set in _sets)
    {
      addWidgetList(widget.bodyWeight, set.weight, set.reps, set.rm, setId:set.id!);
    }
  }

  void addWidgetList(double bodyWeight, double weight, int reps, double rm, {int setId = 0}) {

    final StateNotifierProvider<TrainingStateController, TrainingState> trainingProvider =
      StateNotifierProvider<TrainingStateController, TrainingState>((ref) => TrainingStateController(
        weight: weight,
        reps:   reps,
        rm:     rm,
      ));

    _list.add(
      TrainingSetFormTextList(
        index:    ++index,
        provider: trainingProvider,
        setId:    setId,
        widget:   TrainingSetFormTextWidget(
          provider:   trainingProvider,
          bodyWeight: bodyWeight,
          weight:     weight,
          reps:       reps,
          rm:         rm,
          onPressedCallback: addWidgetList,
        ),
      )
    );
    setState(() {
      _items = _list;
    });
  }

  int paramTaskId = 0;

  final StateNotifierProvider<EventSelectStateController, EventSelectState> eventSelectProvider = StateNotifierProvider<EventSelectStateController, EventSelectState>((ref) => EventSelectStateController());

  TextEditingController _metsTtextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getEventList();
    if (widget.task != null) {
      paramTaskId = widget.task!.id;
      _getTrainingSetList(paramTaskId);
      selectedEvent = widget.task!.eventId;
    }
    else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        addWidgetList(widget.bodyWeight, 0, 0, 0);
      });
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
                  flex: 4,
                  child: EventsMenu(
                    dbHelper:      dbHelper,
                    selectedEvent: selectedEvent,
                    provider:      eventSelectProvider,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: EventSettingBtn(
                    dbHelper:          dbHelper,
                    eventId:           ref.watch(eventSelectProvider).selectedEventId,
                    onPressedCallback: _getEventList,
                  )
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
                  child:
                    AddBtnTrainingSetForm(
                      onPressedCallback: addWidgetList,
                      bodyWeight: widget.bodyWeight,
                    )
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