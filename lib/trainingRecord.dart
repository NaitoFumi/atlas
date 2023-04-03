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

  final TrainingDatabase dbHelper = TrainingDatabase.instance;

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
                  child: AddBtnTrainingSetForm(onPressedCallback: addWidgetList,)
                ),
                const Spacer(),
                Expanded(
                  flex: 1,
                  child: RegistBtnTrainingSet(
                    items:    _items,
                    date:     widget.paramDate,
                    eventId:  selectedEvent,
                    dbHelper: dbHelper,
                    ref:      ref,
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