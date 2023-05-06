import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'logger_wrap.dart';
import 'core/structure.dart';
import 'core/util.dart';
import 'trainingDb.dart';
import 'traningTaskScreen.dart';
import 'trainingRegistWidget.dart';
import 'eventScreen.dart';

class TrainingTaskList extends StatefulWidget {

  final TrainingTaskItem trainingTaskItem;
  final double bodyWeight;
  final DateTime paramDate;
  final Function() callBackFunc;

  TrainingTaskList(
    {
      Key? key,
      required this.trainingTaskItem,
      required this.bodyWeight,
      required this.paramDate,
      required this.callBackFunc,
    }
  );

  @override
  _TrainingTaskList createState() => _TrainingTaskList();

}
class _TrainingTaskList extends State<TrainingTaskList> {
  @override
  Widget build(BuildContext context) {
    return
    ListTile(
      leading: Icon(Icons.add_a_photo),
      title: Text("${widget.trainingTaskItem.eventName}"),
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TrainingRegistWidget(
              task:       widget.trainingTaskItem,
              bodyWeight: widget.bodyWeight,
              paramDate: widget.paramDate,
              title: "Training Task Edit",
            )
          ),
        );
        widget.callBackFunc();
      },
    )
    ;
  }
}

class TrainingSetFormText extends StatelessWidget {

  final TextEditingController textController;
  final String label;
  final String hint;

  TrainingSetFormText(
    {
      Key? key,
      required this.textController,
      required this.label,
      required this.hint,
    }
  );

  @override
  Widget build(BuildContext context) {
    return
    Expanded(
      child:Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children:<Widget>[
          Expanded(
            child:TextFormField(
              keyboardType: TextInputType.number,
              controller: textController,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly // Only numbers can be entered
              ],
              decoration: InputDecoration(
                labelText: label,
                hintText: hint,
                border: OutlineInputBorder(),
              ),
            ),
          )
        ],
      ),
    );
  }
}
class TrainingSetFormTextWidget extends ConsumerStatefulWidget {

  final StateNotifierProvider<TrainingStateController, TrainingState> provider;
  final double bodyWeight;
  final double weight;
  final int reps;
  final double rm;
  final Function(double bodyWeight, double weight, int reps, double rm) onPressedCallback;

  TrainingSetFormTextWidget(
    {
      Key? key,
      required this.provider,
      required this.bodyWeight,
      required this.weight,
      required this.reps,
      required this.rm,
      required this.onPressedCallback,
    }
  );

  @override
  TrainingSetFormTextWidgetState createState() => TrainingSetFormTextWidgetState();

}

class TrainingSetFormTextWidgetState extends ConsumerState<TrainingSetFormTextWidget> {

  TextEditingController _weightTtextController = TextEditingController();
  TextEditingController _repsTtextController = TextEditingController();

  double weight = 0;
  int reps = 0;
  double rm = 0;

  double calculateRM(double _weight, int _reps) {
    double _rm = 0;
    if(_reps == 1){
      _rm = _weight;
    }
    else {
      _rm = (_weight * (1 + (_reps / 40)));
    }
    return _rm;
  }

  void _updateWeight() {
    if(_weightTtextController.text.isNotEmpty){
      setState(() {
        weight = double.parse(_weightTtextController.text);
        rm = calculateRM(weight, reps);
        ref.read(widget.provider.notifier).modify(weight,reps,rm);
      });
    }
  }
  void _updateReps() {
    if(_repsTtextController.text.isNotEmpty) {
      setState(() {
        reps = int.parse(_repsTtextController.text);
        rm = calculateRM(weight, reps);
        ref.read(widget.provider.notifier).modify(weight,reps,rm);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    weight = widget.weight;
    reps   = widget.reps;
    rm     = widget.rm;
    _weightTtextController.text = widget.weight.toString();
    _repsTtextController.text   = widget.reps.toString();
    _weightTtextController.addListener(_updateWeight);
    _repsTtextController.addListener(_updateReps);
  }

  @override
  void dispose() {
    _weightTtextController.dispose();
    _repsTtextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return
    Column(
      children: <Widget>[
        Row(
          children: [
            TrainingSetFormText(
              textController:_repsTtextController,
              label: 'Reps',
              hint: 'Enter a number',
            ),
            TrainingSetFormText(
              textController:_weightTtextController,
              label: 'Weight',
              hint: 'Enter a number',
            ),
            CopyTrainingSetBtn(
              bodyWeight: widget.bodyWeight,
              weight:     weight,
              reps:       reps,
              rm:         rm,
              onPressedCallback: widget.onPressedCallback,
            )
          ]
        ),
        Column(
          children: [
            Text(
              '1RM = ${rm.toStringAsFixed(1)} kg',
              style: TextStyle(fontSize: 24.0),
            ),
          ],
        ),
      ]
    );
  }
}

class CopyTrainingSetBtn extends StatelessWidget {

  final double bodyWeight;
  final double weight;
  final int reps;
  final double rm;
  final Function(double bodyWeight, double weight, int reps, double rm) onPressedCallback;

  CopyTrainingSetBtn(
    {
      Key? key,
      required this.bodyWeight,
      required this.weight,
      required this.reps,
      required this.rm,
      required this.onPressedCallback,
    }
  );

  @override
  Widget build(BuildContext context) {
    return
      ElevatedButton(
        onPressed: () async {
          logger.d(weight);
          logger.d(reps);
          onPressedCallback(bodyWeight, weight, reps, rm);
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
            Icon( Icons.add_task, color: Colors.white, size: 35,),
          ],
        ),
      )
    ;
  }
}

class RegistTrainingTaskBtn extends StatelessWidget {

  final DateTime selectDay;
  final List<TrainingTaskItem> trainingTaskList;
  final TrainingDatabase dbHelper;
  final Function(DateTime,  List<TrainingTaskItem>) onPressdFunc;
  final Function(TrainingDatabase,DateTime) callBackFunc;

  RegistTrainingTaskBtn(
    {
      Key? key,
      required this.selectDay,
      required this.trainingTaskList,
      required this.dbHelper,
      required this.onPressdFunc,
      required this.callBackFunc,
    }
  );

  @override
  Widget build(BuildContext context) {
    return
      ElevatedButton(
        onPressed: () async {
          onPressdFunc(selectDay, trainingTaskList);
          callBackFunc(dbHelper,selectDay);
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
            Icon( Icons.add_task, color: Colors.white, size: 35,),
          ],
        ),
      )
    ;
  }
}

class StaticBtn extends StatelessWidget {

  StaticBtn(
    {
      Key? key,
    }
  );

  @override
  Widget build(BuildContext context) {
    return
      ElevatedButton(
        onPressed: () {
          // Navigator.push(
            // context,
            // MaterialPageRoute(
            //   builder: (context) =>
            // ),
          // );
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
            Icon( Icons.analytics, color: Colors.white, size: 35,),
          ],
        ),
      )
    ;
  }
}

class AddBtnTrainingSetForm extends StatelessWidget {

  final Function(double bodyWeight, double weight, int reps, double rm) onPressedCallback;
  final double bodyWeight;

  AddBtnTrainingSetForm(
    {
      Key? key,
      required this.onPressedCallback,
      required this.bodyWeight,
    }
  );

  @override
  Widget build(BuildContext context) {
    return
      ElevatedButton(
        onPressed: () async {
          onPressedCallback(bodyWeight, 0, 0, 0);
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
      )
    ;
  }
}

class RegistBtnTrainingSet extends StatelessWidget {

  final int taskId;
  final List<TrainingSetFormTextList> trainingSetFormList;
  final DateTime date;
  final int eventId;
  final TrainingDatabase dbHelper;
  final ref;

  RegistBtnTrainingSet(
    {
      Key? key,
      required this.taskId,
      required this.trainingSetFormList,
      required this.date,
      required this.eventId,
      required this.dbHelper,
      required this.ref,
    }
  );

  @override
  Widget build(BuildContext context) {
    return
      ElevatedButton(
        onPressed: () async {
          registTrainingRecodes(taskId,trainingSetFormList, date, eventId, dbHelper, ref);
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
      )
    ;
  }
}

class EventsMenu extends ConsumerStatefulWidget {

  final TrainingDatabase dbHelper;
  final StateNotifierProvider<EventSelectStateController, EventSelectState> provider;
  final int selectedEvent;

  EventsMenu(
    {
      Key? key,
      required this.dbHelper,
      required this.provider,
      required this.selectedEvent,
    }
  );

  @override
  EventsMenuState createState() => EventsMenuState();

}
class EventsMenuState extends ConsumerState<EventsMenu> {

  final TextEditingController _textEditingController = TextEditingController();
  int _selectedEventId = 0;

   @override
  void initState() {
    super.initState();
    _getEventList(widget.dbHelper);
    _selectedEventId = widget.selectedEvent;
  }

  @override
  void dispose() {
    super.dispose();
  }

  List<Event> events = [];

  void _getEventList(TrainingDatabase dbHelper,) async {
    List<Event> _events = await dbHelper.getEvents();
    setState(() {
      events = _events;
      Event _event = Event(id: 0, name: "Custom Event");
      events.insert(0, _event);
    });
  }

  int insertedEventId = 0;

  void _registEvent(TrainingDatabase dbHelper, String eventName) async {
    Event event = Event(name: eventName);
    insertedEventId = await dbHelper.insertEvents(event);
    if (insertedEventId > 0) {
      logger.i('Event insert with setId: $insertedEventId');
    } else {
      logger.i('Failed to insert Event');
      insertedEventId = widget.selectedEvent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return
      Column(
        children: [
          DropdownButton<int>(
            hint: Text('Select an Event'),
            value: _selectedEventId,
            onChanged: (int? value) {
              if (value == 0) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Enter custom Event'),
                    content: TextField(
                      controller: _textEditingController,
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          setState(() {
                            _registEvent(widget.dbHelper,_textEditingController.text);
                            _getEventList(widget.dbHelper);
                            _selectedEventId = insertedEventId;
                            ref.read(widget.provider.notifier).modify(_selectedEventId);
                          });
                          _textEditingController.clear();
                        },
                        child: const Text('Add'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Cancel'),
                      ),
                    ],
                  ),
                );
              } else {
                setState(() {
                  _selectedEventId = value ?? 0;
                  ref.read(widget.provider.notifier).modify(_selectedEventId);
                });
              }
            },
            items: events.map((evnet) {
              return DropdownMenuItem(
                value: evnet.id,
                child:
                  Row(
                    children: [
                      Text(evnet.name),
                    ],
                  ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
        ],
      )
    ;
  }
}

class EventSettingBtn extends StatelessWidget {

  final TrainingDatabase dbHelper;
  final int eventId;
  final Function() onPressedCallback;


  EventSettingBtn(
    {
      Key? key,
      required this.dbHelper,
      required this.eventId,
      required this.onPressedCallback,
    }
  );

  @override
  Widget build(BuildContext context) {
    return
      ElevatedButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
              EventScreen(dbHelper: dbHelper, eventId: eventId)
            ),
          );
          onPressedCallback();
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
            Icon(Icons.settings, color: Colors.white),
            SizedBox(width: 4),
          ],
        ),
      )
    ;
  }
}