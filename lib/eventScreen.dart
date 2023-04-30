import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'logger_wrap.dart';
import 'core/structure.dart';
import 'core/util.dart';
import 'trainingDb.dart';
import 'utilWidget.dart';

class EventScreen extends ConsumerStatefulWidget {

  final TrainingDatabase dbHelper;

  EventScreen(
    {
      Key? key,
      required this.dbHelper,
    }
  );

  @override
  _EventScreenState createState() => _EventScreenState();

}

class _EventScreenState extends ConsumerState<EventScreen> {

  TextEditingController _textController = TextEditingController();

  final StateNotifierProvider<EventSelectStateController, EventSelectState> eventSelectProvider =
    StateNotifierProvider<EventSelectStateController, EventSelectState>((ref) => EventSelectStateController());

  final dbHelper = TrainingDatabase.instance;

   void _updateText() {
    if(_textController.text.isNotEmpty){
      setState(() {
      });
    }
  }

  int selectedEvent = defEvent;
  List<Event> events = [];
  void _getEventList() async {
    List<Event> _events = await dbHelper.getEvents();
    setState(() {
      events = _events;
    });
  }

  List<TagEventName>tags = [];
  void _getTagList(int taskId) async {
    List<TagEventName>_tags = await dbHelper.getTagEventByEventId(taskId);
    setState(() {
      tags = _tags;
    });
  }

  @override
  void initState() {
    super.initState();
    _textController.text = "";
    _textController.addListener(_updateText);
    _getEventList();
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
              // Column(
              //   children: [
              //     Row(
              //       children: [
              //         Expanded(
              //           child: TextFormField(
              //             keyboardType: TextInputType.name,
              //             controller: _textController,
              //             decoration: const InputDecoration(
              //               labelText: "Add Event Name",
              //               hintText: "",
              //               border: OutlineInputBorder(),
              //             ),
              //           ),
              //         ),
              //       ]
              //     ),
              //     const SizedBox(height: 16.0),
              //     Row(
              //       mainAxisAlignment: MainAxisAlignment.center,
              //       children: [
              //         const Spacer(),
              //         Expanded(
              //           flex: 1,
              //           child: RegistEventBtn(
              //             dbHelper: widget.dbHelper,
              //             name:     _textController.text,
              //           )
              //         ),
              //         const Spacer(),
              //       ],
              //     ),
              //   ],
              // ),
              const SizedBox(height: 32.0),
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: EventsMenu(
                          dbHelper:           widget.dbHelper,
                          // events:             events,
                          selectedEvent:      defEvent,
                          provider:           eventSelectProvider,
                        ),
                      ),
                    ]
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(),
                      TagDropdownMenu(
                         dbHelper: widget.dbHelper,
                         provider: eventSelectProvider,
                      ),
                    ],
                  ),
                ],
              ),
            ]
          )
        )
      );
  }
}

// class RegistEventBtn extends StatelessWidget {

//   final TrainingDatabase dbHelper;
//   final String name;

//   RegistEventBtn(
//     {
//       Key? key,
//       required this.dbHelper,
//       required this.name,
//     }
//   );

//   @override
//   Widget build(BuildContext context) {
//     return
//       ElevatedButton(
//         onPressed: () async {
//           Event event = Event(
//             name: name
//           );
//           int eventId = await dbHelper.insertEvents(event);
//           if (eventId > 0) {
//             logger.i('Event insert with setId: $eventId');
//           } else {
//             logger.i('Failed to insert Event');
//           }
//         },
//         style: ElevatedButton.styleFrom(
//           backgroundColor: Colors.blue,
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(24),
//           ),
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: const [
//             Icon( Icons.add_task, color: Colors.white, size: 35,),
//           ],
//         ),
//       )
//     ;
//   }
// }

class TagBoxWidget extends StatelessWidget {

  final String name;

  TagBoxWidget(
    {
      Key? key,
      required this.name,
    }
  );

  @override
  Widget build(BuildContext context) {
    return
      Text(name)
    ;
  }
}

class TagDropdownMenu extends ConsumerStatefulWidget {

  final TrainingDatabase dbHelper;
  final StateNotifierProvider<EventSelectStateController, EventSelectState> provider;

  TagDropdownMenu(
    {
      Key? key,
      required this.dbHelper,
      required this.provider,
    }
  );

  @override
  _TagDropdownMenuState createState() => _TagDropdownMenuState();
}

class _TagDropdownMenuState extends ConsumerState<TagDropdownMenu> {
  List<Tag> _tags = [];
  int _selectedItem = 0;
  // String _selectedItem = "Option 1";
  TextEditingController _textEditingController = TextEditingController();

 @override
  void initState() {
    super.initState();
    getTags();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void getTags() async {
     List<Tag> _tagList = await widget.dbHelper.getTag();
     setState(() {
      _tags = _tagList;
      Tag _tag = Tag(id: 0, name: "Custom Tag");
      _tags.insert(0, _tag);
     });
  }

  int insertedId = 0;
  void registTag(String name) async {
      Tag tagData = Tag(
        name: name
      );
      insertedId = await widget.dbHelper.insertTag(tagData);
      if(insertedId > 0) {
      }
      else {
        insertedId = 0;
      }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // DropdownButton<String>(
        DropdownButton<int>(
          hint: Text('Select an option'),
          value: _selectedItem,
          onChanged: (int? value) {
            if (value == 0) {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Enter custom Tag'),
                  content: TextField(
                    controller: _textEditingController,
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          registTag(_textEditingController.text);
                          getTags();
                          _selectedItem = insertedId;
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
                _selectedItem = value ?? 0;
              });
            }
          },
          items: _tags.map((tag) {
            return DropdownMenuItem(
              value: tag.id,
              child:
                Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Text(tag.name)
                    ),
                    Expanded(
                      flex: 1,
                      child: (
                        ElevatedButton(
                          onPressed: () async {
                            TagEvent tag_event = TagEvent(
                              tagId: tag.id!,
                              eventId: ref.watch(widget.provider).selectedEventId,
                            );
                            await widget.dbHelper.insertTagEvent(tag_event);
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
                      )
                    ),
                  ],
                ),
            );
          }).toList(),
        ),
        SizedBox(height: 16),
        Text('Selected option: $_selectedItem'),
      ],
    );
  }
}


// class CustomDropdownMenu extends StatefulWidget {
//   @override
//   _CustomDropdownMenuState createState() => _CustomDropdownMenuState();
// }

// class _CustomDropdownMenuState extends State<CustomDropdownMenu> {
//   List<String> _items = ['Option 1', 'Option 2', 'Option 3', 'Custom'];
//   String _selectedItem = "Option 1";
//   TextEditingController _textEditingController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         DropdownButton<String>(
//           hint: Text('Select an option'),
//           value: _selectedItem,
//           onChanged: (String? value) {
//             if (value == 'Custom') {
//               showDialog(
//                 context: context,
//                 builder: (context) => AlertDialog(
//                   title: const Text('Enter custom option'),
//                   content: TextField(
//                     controller: _textEditingController,
//                   ),
//                   actions: [
//                     TextButton(
//                       onPressed: () {
//                         Navigator.pop(context);
//                         setState(() {
//                           _items.insert(_items.length - 1, _textEditingController.text);
//                           _selectedItem = _textEditingController.text;
//                         });
//                         _textEditingController.clear();
//                       },
//                       child: const Text('Add'),
//                     ),
//                     TextButton(
//                       onPressed: () {
//                         Navigator.pop(context);
//                       },
//                       child: const Text('Cancel'),
//                     ),
//                   ],
//                 ),
//               );
//             } else {
//               setState(() {
//                 _selectedItem = value ?? "aa";
//               });
//             }
//           },
//           items: _items.map<DropdownMenuItem<String>>((String value) {
//             return DropdownMenuItem<String>(
//               value: value,
//               child: Text(value),
//             );
//           }).toList(),
//         ),
//         SizedBox(height: 16),
//         Text('Selected option: $_selectedItem'),
//       ],
//     );
//   }
// }
