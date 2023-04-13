import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import './logger_wrap.dart';
import 'core/structure.dart';
import 'core/util.dart';
import './trainingDb.dart';
import './traningTask.dart';
import './trainingRegistWidget.dart';

class TrainingTaskList extends StatefulWidget {

  final TrainingTaskItem trainingTaskItem;
  final double bodyWeight;
  final DateTime paramDate;

  TrainingTaskList(
    {
      Key? key,
      required this.trainingTaskItem,
      required this.bodyWeight,
      required this.paramDate,
    }
  );

  @override
  _TrainingTaskList createState() => _TrainingTaskList();

}
class _TrainingTaskList extends State<TrainingTaskList> {
  @override
  Widget build(BuildContext context) {
    logger.d(widget.trainingTaskItem);
    return
    ListTile(
      leading: Icon(Icons.add_a_photo),
      title: Text("${widget.trainingTaskItem.eventName}"),
      onTap: (){
        Navigator.push(
          context,
          MaterialPageRoute(
            // builder: (context) => TrainingEditScreen(
            builder: (context) => TrainingRegistWidget(
              task:       widget.trainingTaskItem,
              bodyWeight: widget.bodyWeight,
              paramDate: widget.paramDate,
              title: "Training Task Edit",
            )
          ),
        );
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
  final int lap;
  final double mets;
  final int kcal;
  final double rm;

  TrainingSetFormTextWidget(
    {
      Key? key,
      required this.provider,
      required this.bodyWeight,
      required this.weight,
      required this.reps,
      required this.lap,
      required this.mets,
      required this.kcal,
      required this.rm,
    }
  );

  @override
  TrainingSetFormTextWidgetState createState() => TrainingSetFormTextWidgetState();

}

class TrainingSetFormTextWidgetState extends ConsumerState<TrainingSetFormTextWidget> {

  TextEditingController _weightTtextController = TextEditingController();
  TextEditingController _repsTtextController = TextEditingController();
  TextEditingController _lapTtextController = TextEditingController();
  TextEditingController _metsTtextController = TextEditingController();

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

  // int interval = 0;
  int lap = 0;
  double mets = 0;
  int kcal = 0;

  double calculateKcal(int _lap, double _bodyWeight, double _mets) {
    return (_mets * _bodyWeight * (_lap / 360) * 1.05);
  }

  void _updateWeight() {
    if(_weightTtextController.text.isNotEmpty){
      setState(() {
        weight = double.parse(_weightTtextController.text);
        rm = calculateRM(weight, reps);
        ref.read(widget.provider.notifier).modify(weight,mets,reps,lap,rm,kcal);
      });
    }
  }
  void _updateReps() {
    if(_repsTtextController.text.isNotEmpty) {
      setState(() {
        reps = int.parse(_repsTtextController.text);
        rm = calculateRM(weight, reps);
        ref.read(widget.provider.notifier).modify(weight,mets,reps,lap,rm,kcal);
      });
    }
  }
  void _updateLap() {
    if(_lapTtextController.text.isNotEmpty) {
      lap = int.parse(_lapTtextController.text);
      kcal = calculateKcal(lap, widget.bodyWeight, mets).toInt();
      ref.read(widget.provider.notifier).modify(weight,mets,reps,lap,rm,kcal);
    }
  }
  void _updateMets(){
    if(_metsTtextController.text.isNotEmpty) {
      mets = double.parse(_metsTtextController.text);
      kcal = calculateKcal(lap, widget.bodyWeight, mets).toInt();
      ref.read(widget.provider.notifier).modify(weight,mets,reps,lap,rm,kcal);
    }
  }

  @override
  void initState() {
    super.initState();
    weight = widget.weight;
    reps   = widget.reps;
    lap    = widget.lap;
    mets   = widget.mets;
    kcal   = widget.kcal;
    rm     = widget.rm;
    // _weightTtextController.text = widget.reps.toString();
    _weightTtextController.text = widget.weight.toString();
    _repsTtextController.text   = widget.reps.toString();
    _lapTtextController.text    = widget.lap.toString();
    _metsTtextController.text   = widget.mets.toString();
    _weightTtextController.addListener(_updateWeight);
    _repsTtextController.addListener(_updateReps);
    _lapTtextController.addListener(_updateLap);
    _metsTtextController.addListener(_updateMets);
  }

  @override
  void dispose() {
    _weightTtextController.dispose();
    _repsTtextController.dispose();
    _lapTtextController.dispose();
    _metsTtextController.dispose();
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
          ]
        ),
        Row(
          children: [
            TrainingSetFormText(
              textController:_lapTtextController,
              label: 'Lap',
              hint: 'Enter a time',
            ),
            TrainingSetFormText(
              textController:_metsTtextController,
              label: 'Mets',
              hint: 'Enter a number',
            ),
          ],
        ),
        Column( //rm
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

class RegistTrainingTaskBtn extends StatelessWidget {

  final DateTime selectDay;
  final List<TrainingTaskItem> trainingTaskList;
  final TrainingDatabase dbHelper;
  final Function(TrainingDatabase,DateTime) callBackFunc;

  RegistTrainingTaskBtn(
    {
      Key? key,
      required this.selectDay,
      required this.trainingTaskList,
      required this.dbHelper,
      required this.callBackFunc,
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
              TrainingTaskScreen(
                paramDate: selectDay,
                trainingTaskList: trainingTaskList,
              )
            ),
          );
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

  final Function() onPressedCallback;

  AddBtnTrainingSetForm(
    {
      Key? key,
      required this.onPressedCallback,
    }
  );

  @override
  Widget build(BuildContext context) {
    return
      ElevatedButton(
        onPressed: () async {
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
  final dbHelper;
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

  final StateNotifierProvider<EventSelectStateController, EventSelectState> provider;
  final List<Evnet> events;
  int selectedEvent = 1;

  EventsMenu(
    {
      Key? key,
      required this.provider,
      required this.events,
      required this.selectedEvent,
    }
  );

  @override
  EventsMenuState createState() => EventsMenuState();

}
class EventsMenuState extends ConsumerState<EventsMenu> {

   @override
  void initState() {
    super.initState();
    // ref.read(widget.provider.notifier).modify(widget.selectedEvent);
  }

  @override
  Widget build(BuildContext context) {
    return
      DropdownButtonFormField(
        items: widget.events.map((event) {
          return DropdownMenuItem(
            value: event.id,
            child: Text(event.name)
          );
        }).toList(),
        value: widget.selectedEvent,
        onChanged: (int? value) {
          ref.read(widget.provider.notifier).modify(value);
        },
      )
    ;
  }
}