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

  int selectedEvent = defEvent;
  List<Event> events = [];

  void _getEventList() async {
    List<Event> _events = await dbHelper.getEvents();
    setState(() {
      events = _events;
    });
  }

  Map<int,TrainingSetFormTextWidget> mapTrainingSetForm = {};
  List<MapEntry<int, TrainingSetFormTextWidget>> mapEntriesTrainingSetForm = [];
  int index = 0;

  void _getTrainingSetList(int taskId) async {
    List<TrainingSet> _sets= await dbHelper.getTrainingSets(taskId);
    for (final set in _sets) {
      addTrainingSetFormTextList(widget.bodyWeight, set.weight, set.reps, set.rm, setId:set.id!);
    }
  }

  void addTrainingSetFormTextList(double bodyWeight, double weight, int reps, double rm, {int setId = 0}) {

    final StateNotifierProvider<TrainingStateController, TrainingState> trainingProvider =
      StateNotifierProvider<TrainingStateController, TrainingState>((ref) => TrainingStateController(
        weight: weight,
        reps:   reps,
        rm:     rm,
      ));
    mapTrainingSetForm[index] = TrainingSetFormTextWidget(
        index:      index++,
        provider:   trainingProvider,
        bodyWeight: bodyWeight,
        setId:      setId,
        weight:     weight,
        reps:       reps,
        rm:         rm,
        callBackFunc: addTrainingSetFormTextList,
        onPressedCallback: deleteTrainingSetFormTextList,
      );
    setState(() {
      // _items = _list;
      mapEntriesTrainingSetForm = mapTrainingSetForm.entries.toList();
    });
  }

  void deleteTrainingSetFormTextList(int index) async {
    MapEntry<int, TrainingSetFormTextWidget> entry = mapEntriesTrainingSetForm[index];
    int id = await dbHelper.deleteTrainingSet(entry.value.setId);
    if(id > 0) {
      logger.i("delete Success TagEvent");
      mapTrainingSetForm.remove(index);
    }
    else {
      logger.i("delete faile TagEvent");
    }
    setState(() {
      mapEntriesTrainingSetForm = mapTrainingSetForm.entries.toList();
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
        addTrainingSetFormTextList(widget.bodyWeight, 0, 0, 0);
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
                MapEntry<int, TrainingSetFormTextWidget> entry = mapEntriesTrainingSetForm[index];
                return entry.value;
              },
              itemCount: mapEntriesTrainingSetForm.length,
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
                      onPressedCallback: addTrainingSetFormTextList,
                      bodyWeight: widget.bodyWeight,
                    )
                ),
                const Spacer(),
                Expanded(
                  flex: 1,
                  child: RegistBtnTrainingSet(
                    taskId:              paramTaskId,
                    trainingSetFormList: mapEntriesTrainingSetForm,
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