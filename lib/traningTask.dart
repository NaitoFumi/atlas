import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import './logger_wrap.dart';
import './trainingDb.dart';

class TrainingTaskScreen extends StatefulWidget {

  final paramDate;

  TrainingTaskScreen({Key? key, required this.paramDate}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _TrainingTaskScreenState createState() => _TrainingTaskScreenState();
}

class _TrainingTaskScreenState extends State<TrainingTaskScreen> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    
  }
}