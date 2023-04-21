import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import './logger_wrap.dart';
import 'core/structure.dart';
import 'core/util.dart';
import './trainingDb.dart';

class EventRegistWidget extends StatefulWidget {

  final TrainingDatabase dbHelper;

  EventRegistWidget(
    {
      Key? key,
      required this.dbHelper,
    }
  );

  @override
  EventRegistWidgetState createState() => EventRegistWidgetState();

}

class EventRegistWidgetState extends State<EventRegistWidget> {

  TextEditingController _textController = TextEditingController();

   void _updateText() {
    if(_textController.text.isNotEmpty){
      setState(() {
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _textController.text = "";
    _textController.addListener(_updateText);
  }

  @override
  void dispose() {
    super.dispose();
    _textController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Setting Event"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      keyboardType: TextInputType.name,
                      controller: _textController,
                      decoration: InputDecoration(
                        labelText: "Event Name",
                        hintText: "",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ]
              ),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  Expanded(
                    flex: 1,
                    child: RegistBtnEvent(
                      dbHelper: widget.dbHelper,
                      name:     _textController.text,
                    )
                  ),
                  const Spacer(),
                ],
              ),
            ]
          )
        )
      );
  }
}

class RegistBtnEvent extends StatelessWidget {

  final TrainingDatabase dbHelper;
  final String name;

  RegistBtnEvent(
    {
      Key? key,
      required this.dbHelper,
      required this.name,
    }
  );

  @override
  Widget build(BuildContext context) {
    return
      ElevatedButton(
        onPressed: () async {
          Event event = Event(
            name: name
          );
          int eventId = await dbHelper.insertEvents(event);
          if (eventId > 0) {
            logger.i('Event insert with setId: $eventId');
          } else {
            logger.i('Failed to insert Event');
          }
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
            Icon( Icons.add_task, color: Colors.white, size: 35,),
          ],
        ),
      )
    ;
  }
}