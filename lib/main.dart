import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Your other code here
      home: CalendarScreen()
      // home: TrainingRecordScreen()
    );
  }
}

class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}
class _CalendarScreenState extends State<CalendarScreen> {

  // This function is used to listen to the date changes.
  void onSelectedDate(DateTime dateTime) {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Calendar"),
      ),
      body: Container(
          margin: const EdgeInsets.only(top:10, left:30, right:30),
          child: CalendarCarousel<Event>(
            //アイコンを表示する日付について、EventのList
            markedDateShowIcon: true,
            markedDateIconMaxShown: 1,
            markedDateMoreShowTotal: null,
            markedDateIconBuilder: (event)=>event.icon,  //アイコン
            onDayPressed: (DateTime date, List<Event> events) {
              // this.setState(() => _currentDate = date);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TrainingRecordScreen()),
              );
            },
          ),
      )
    );
  }
}

class TrainingRecordScreen extends StatefulWidget {
  const TrainingRecordScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _TrainingRecordScreenState createState() => _TrainingRecordScreenState();
}
class _TrainingRecordScreenState extends State<TrainingRecordScreen> {
  // Data fields
  List<String> events = ["Event 1", "Event 2"];
  List<String> parts = ["Part 1", "Part 2"];
  int weight = 0;
  int reps = 0;

  // Form fields
  String selectedEvent = "Event 1";
  String selectedPart = "Part 1";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Training Record"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            DropdownButtonFormField(
              // Populate list of events
              items: events.map((event) {
                return DropdownMenuItem(
                  value: event,
                  child: Text(event)
                );
              }).toList(),
              // Set the value
              value: selectedEvent,
              onChanged: (String? value) {
                setState(() {
                  selectedEvent = value!;
                });
             },
            ),
            DropdownButtonFormField(
              // Populate list of parts
              items: parts.map((part) {
                return DropdownMenuItem(
                  value: part,
                  child: Text(part)
                );
              }).toList(),
              // Set the value
              value: selectedPart,
              onChanged: (String? value) {
                setState(() {
                  selectedPart = value!;
                });
             },
            ),
            // Slider for the weight
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text("Weight"),
                SizedBox(
                  width: 100,
                  child: Slider(
                    value: weight.toDouble(),
                    min: 0,
                    max: 200,
                    divisions: 20,
                    label: '$weight kgs',
                    onChanged: (value) {
                      setState(() {
                        weight = value.round();
                      });
                    },
                  ),
                ),
                Text("$weight kg"),
              ],
            ),
            // Slider for the reps
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text("Number of Reps"),
                  SizedBox(
                    width: 100,
                    child: Slider(
                      value: reps.toDouble(),
                      min: 0,
                      max: 25,
                      divisions: 25,
                      label: '$reps reps',
                      onChanged: (value) {
                        setState(() {
                          reps = value.round();
                        });
                      },
                    ),
                  ),
                  Text("$reps reps"),
                ],
              )
          ],
        ),
      ),
    );
  }
}