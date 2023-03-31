import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

import './logger_wrap.dart';
import './core/structure.dart';
import './core/util.dart';
import './trainingDb.dart';
import './utilWidget.dart';
import './trainingRecord.dart';

class TrainingTaskScreen extends StatefulWidget {

  final DateTime paramDate;
  final List<TrainingTaskItem> trainingTaskList;

  TrainingTaskScreen(
    {
      Key? key,
      required this.paramDate,
      required this.trainingTaskList,
    }
  );

  @override
  // ignore: library_private_types_in_public_api
  _TrainingTaskScreenState createState() => _TrainingTaskScreenState();
}

class _TrainingTaskScreenState extends State<TrainingTaskScreen> {

  final dbHelper = TrainingDatabase.instance;
  List<Evnet> eventsList = [];
  final TextEditingController _bodyWeightTextController = TextEditingController();
  final TextEditingController _bfpTextController = TextEditingController();
  double _bmr = 0;
  BodyComposition _lastData = BodyComposition (
    id: -1,
    bfp: 0,
    bodyWeight: 0,
    date: DateTime.now().millisecondsSinceEpoch,
  );
  BodyComposition _newData = BodyComposition (
    id: -1,
    bfp: 0,
    bodyWeight: 0,
    date: DateTime.now().millisecondsSinceEpoch,
  );

  DateFormat dateFormat = DateFormat('yyyy-MM-dd');
  String strDate = "";

  void _getBodyComposition() async {
    int dayUnix = roundUnixTimeToDays(widget.paramDate.millisecondsSinceEpoch);
    List<BodyComposition> bodyCompositionList = await dbHelper.getBodyComposition(dayUnix);
    if (bodyCompositionList.isNotEmpty) {
      logger.i('TrainingEvents select');
      _lastData.id = bodyCompositionList[0].id;
      _lastData.bodyWeight = bodyCompositionList[0].bodyWeight;
      _lastData.bfp = bodyCompositionList[0].bfp;
      _lastData.date = bodyCompositionList[0].date;
      _bmr = _calculateBMR(_lastData.bodyWeight, _lastData.bfp);
      _bodyWeightTextController.text = _lastData.bodyWeight.toString();
      _bfpTextController.text = _lastData.bfp.toString();
      _newData = _lastData;

    } else {
      logger.i('Failed to select TrainingEvents');
      _lastData.id = -1;
      _lastData.date = 0;
    }
  }

  void _insertBodyComposition() async {
    if (_lastData.id == -1) {
    int dayUnix = roundUnixTimeToDays(widget.paramDate.millisecondsSinceEpoch);
      BodyComposition registData = BodyComposition (
        bfp: _newData.bfp,
        bodyWeight: _newData.bodyWeight,
        date: dayUnix,
      );
      int idBodyComposition = await dbHelper.insertBodyComposition(registData);
      if (idBodyComposition > 0) {
        logger.i('BodyComposition inserted with taskId: $idBodyComposition');
      } else {
        logger.i('Failed to insert BodyComposition');
        Navigator.pop(context);
      }
    }
    else if (
      (_lastData.bodyWeight != _newData.bodyWeight) ||
      (_lastData.bfp != _newData.bfp)
    ) {
      int idBodyComposition = await dbHelper.updateBodyComposition(_newData);
      if (idBodyComposition > 0) {
        logger.i('BodyComposition Update with taskId: $idBodyComposition');
      } else {
        logger.i('Failed to Update BodyComposition');
        Navigator.pop(context);
      }
    }
    else{
    }
  }

  double _calculateBMR(double bodyWeight, double btmRate) {
    double lbm = bodyWeight * (1 - btmRate);
    double bmr = 370 + (21.6 * lbm);
    return bmr;
  }

  void _updateWeight() {
    if(_bodyWeightTextController.text.isNotEmpty){
      setState(() {
        _newData.bodyWeight = double.parse(_bodyWeightTextController.text);
        _bmr = _calculateBMR(_newData.bodyWeight, _newData.bfp);
      });
    }
  }

  void _updateBfp() {
    if(_bfpTextController.text.isNotEmpty) {
      setState(() {
        _newData.bfp = double.parse(_bfpTextController.text);
        _bmr = _calculateBMR(_newData.bodyWeight, _newData.bfp);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _getBodyComposition();
    _bodyWeightTextController.addListener(_updateWeight);
    _bfpTextController.addListener(_updateBfp);
    strDate = dateFormat.format(widget.paramDate);
  }

  @override
  Widget build(BuildContext context) {
    logger.d(widget.trainingTaskList);
    logger.d(widget.trainingTaskList.length);
    return Scaffold(
      appBar: AppBar(
        title: Text(strDate),
      ),
      floatingActionButton: Container(
        width: 80,
        height: 80,
        child: FloatingActionButton(
          onPressed: () {
            _insertBodyComposition();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                  TrainingRecordScreen(
                    paramDate: widget.paramDate,
                    bodyWeight:double.parse(_newData.bodyWeight.toString())
                  )
              ),
            );
          },
          child: const Icon( Icons.add_task, color: Colors.white, size: 60, ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Expanded( //weight
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextFormField(
                      controller: _bodyWeightTextController,
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly // Only numbers can be entered
                      ],
                      decoration: const InputDecoration(
                        hintText: 'Enter a number',
                        border: OutlineInputBorder(),
                        labelText: "Body Weight",
                        suffix: Text('kg'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded( //weight
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextFormField(
                      controller: _bfpTextController,
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly // Only numbers can be entered
                      ],
                      decoration: const InputDecoration(
                        hintText: 'Enter a number',
                        border: OutlineInputBorder(),
                        labelText: "Body Fat Percentage",
                        suffix: Text('%'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Text(_bmr.toString()),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: ListView.builder(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemBuilder: (BuildContext context, int index){
                        return TrainingTaskList(
                          trainingTaskItem:widget.trainingTaskList[index],
                          bodyWeight: _newData.bodyWeight
                        );
                      },
                      itemCount: widget.trainingTaskList.length,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}