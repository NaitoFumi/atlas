import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import './logger_wrap.dart';
import 'core/structure.dart';
import './traningTask.dart';

class TrainingSetFormTextListKey {
  int index;
  Widget widget;
  StateNotifierProvider<TrainingStateController, TrainingState> provider;

  TrainingSetFormTextListKey({
    required this.index,
    required this.widget,
    required this.provider,
  });
}

class TrainingTaskList extends StatefulWidget {

  final TrainingTaskItem trainingTaskItem;

  TrainingTaskList(
    {
      Key? key,
      required this.trainingTaskItem,
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
    Expanded( //reps
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

class TrainingSetFormTextList extends ConsumerStatefulWidget {

  final StateNotifierProvider<TrainingStateController, TrainingState> provider;
  final double bodyWeight;

  TrainingSetFormTextList(
    {
      Key? key,
      required this.provider,
      required this.bodyWeight,
    }
  );

  @override
  TrainingSetFormTextListState createState() => TrainingSetFormTextListState();

}

class TrainingSetFormTextListState extends ConsumerState<TrainingSetFormTextList> {

  TextEditingController _weightTtextController = TextEditingController();
  TextEditingController _repsTtextController = TextEditingController();
  TextEditingController _lapTtextController = TextEditingController();
  TextEditingController _metsTtextController = TextEditingController();

  double weight = 0;
  int reps = 0;
  double rm = 0;

  double calculateRM(double weight, int reps) {
    double rm = 0;
    if(reps == 1){
      rm = weight;
    }
    else {
      rm = (weight * (1 + (reps / 40)));
    }
    return rm;
  }

  int lap = 0;
  // int interval = 0;
  double mets = 0;
  int kcal = 0;

  double calculateKcal(int lap, double bodyWeight, double mets) {
    return (mets * bodyWeight * (lap / 360) * 1.05);
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
        Row( //weight reps
          children: [
            TrainingSetFormText(
              textController:_weightTtextController,
              label: 'Reps',
              hint: 'Enter a number',
            ),
            TrainingSetFormText(
              textController:_repsTtextController,
              label: 'Weight',
              hint: 'Enter a number',
            ),
          ]
        ),
        Row( //lap interval mets
          children: [
            TrainingSetFormText(
              textController:_lapTtextController,
              label: 'Lap',
              hint: 'Enter a time',
            ),
            // TrainingSetFormText(
            //   textController:_metsTtextController,
            //   label: 'Interval',
            //   hint: 'Enter a time',
            // ),
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

  RegistTrainingTaskBtn(
    {
      Key? key,
      required this.selectDay,
      required this.trainingTaskList,
    }
  );

  @override
  Widget build(BuildContext context) {
    return
      ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
              TrainingTaskScreen(
                paramDate: selectDay,
                trainingTaskList: trainingTaskList,
              )
            ),
          );
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

  // final String label;
  // final String hint;

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