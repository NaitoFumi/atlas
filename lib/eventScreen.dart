import 'dart:math';

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
  final int eventId;

  EventScreen(
    {
      Key? key,
      required this.dbHelper,
      required this.eventId,
    }
  );

  @override
  _EventScreenState createState() => _EventScreenState();

}

class _EventScreenState extends ConsumerState<EventScreen> {

  final StateNotifierProvider<TagSelectStateController, TagSelectState> tagSelectProvider =
    StateNotifierProvider<TagSelectStateController, TagSelectState>((ref) => TagSelectStateController());

  final dbHelper = TrainingDatabase.instance;

  // List<TagEventName>tags = [];
  Map<int,TagEventName> mapTags = {};
  List<MapEntry<int, TagEventName>> mapEntriesTags = [];

  void _getTagList(int eventId) async {
    List<TagEventName>_tags = await dbHelper.getTagEventByEventId(eventId);
    setState(() {
      mapTags = _tags.fold<Map<int,TagEventName>>({}, (map, item) {
        map[item.id!] = item;
        return map;
      });
      mapEntriesTags = mapTags.entries.toList();
    });
  }

  void _deleteTagEvent(int tagEventId) async {
    logger.d(tagEventId);
    int id = await dbHelper.deleteTagEvent(tagEventId);
    if(id > 0) {
      logger.i("delete Success TagEvent");
    }
    else {
      logger.i("delete faile TagEvent");
    }
    setState(() {
      mapTags.remove(id);
      mapEntriesTags = mapTags.entries.toList();
    });
  }

  @override
  void initState() {
    super.initState();
    _getTagList(widget.eventId);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return
      Scaffold(
        appBar: AppBar(
          title: Text("Setting Event"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child:
            Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TagDropdownMenu(
                        dbHelper: widget.dbHelper,
                        provider: tagSelectProvider,
                    ),
                    const Spacer(),
                    RegistTagBtn(
                      dbHelper: widget.dbHelper,
                      provider: tagSelectProvider,
                      eventId:  widget.eventId,
                      onPressedCallback: _getTagList,
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child:
                        ListView.builder(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemBuilder: (BuildContext context, int index){
                            MapEntry<int, TagEventName> entryTag = mapEntriesTags[index];
                            TagEventName tagEventName = entryTag.value;
                            return
                            Row(
                              children: [
                                Expanded(
                                  flex: 5,
                                  child:
                                    Container(
                                      margin: EdgeInsets.all(10.0),
                                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: Colors.blue,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child:
                                        Text(
                                          tagEventName.name,
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                    ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child:
                                    ElevatedButton(
                                      onPressed: () async {
                                        _deleteTagEvent(tagEventName.id!);
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
                                          Icon( Icons.remove, color: Colors.white, size: 15,),
                                        ],
                                      ),
                                    )
                                )
                              ],
                            );
                          },
                          itemCount: mapEntriesTags.length,
                        ),
                    ),
                  ],
                ),
              ]
            )
        )
      )
    ;
  }
}

class RegistTagBtn extends ConsumerStatefulWidget {

  final TrainingDatabase dbHelper;
  final StateNotifierProvider<TagSelectStateController, TagSelectState> provider;
  final int eventId;
  final Function(int eventId) onPressedCallback;

  const RegistTagBtn(
    {
      Key? key,
      required this.dbHelper,
      required this.provider,
      required this.eventId,
      required this.onPressedCallback,
    }
  );

  @override
  _RegistTagBtnState createState() => _RegistTagBtnState();
}

class _RegistTagBtnState extends ConsumerState<RegistTagBtn> {

  @override
  Widget build(BuildContext context) {
    return
      ElevatedButton(
        onPressed: () async {
          TagEvent tag_event = TagEvent(
            eventId: widget.eventId,
            tagId:   ref.watch(widget.provider).selectedTagId
          );
          int _tagEventId = await widget.dbHelper.insertTagEvent(tag_event);
          if (_tagEventId > 0) {
            logger.i('TagEvent insert with setId: $_tagEventId');
          } else {
            logger.i('Failed to insert TagEvent');
          }
          widget.onPressedCallback(widget.eventId);
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

class TagDropdownMenu extends ConsumerStatefulWidget {

  final TrainingDatabase dbHelper;
  final StateNotifierProvider<TagSelectStateController, TagSelectState> provider;

  const TagDropdownMenu(
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

  final TextEditingController _textEditingController = TextEditingController();
  int _selectedTag = 0;

 @override
  void initState() {
    super.initState();
    _getTags();
    _selectedTag = 0;
  }

  @override
  void dispose() {
    super.dispose();
  }

  List<Tag> _tags = [];

  void _getTags() async {
     List<Tag> tagList = await widget.dbHelper.getTag();
     setState(() {
      _tags = tagList;
      Tag tag = Tag(id: 0, name: "Custom Tag");
      _tags.insert(0, tag);
     });
  }

  int insertedId = 0;

  void registTag(String name) async {
      Tag tagData = Tag(name: name);
      insertedId = await widget.dbHelper.insertTag(tagData);
      if(insertedId > 0) {
        logger.i('Tag insert with tagId: $insertedId');
      }
      else {
        logger.i('Failed to insert Tag');
        insertedId = 0;
      }
  }

  @override
  Widget build(BuildContext context) {
    return
      Column(
        children: [
          DropdownButton<int>(
            hint: Text('Select an option'),
            value: _selectedTag,
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
                            _getTags();
                            _selectedTag = insertedId;
                            ref.read(widget.provider.notifier).modify(insertedId);
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
                  _selectedTag = value ?? 0;
                  ref.read(widget.provider.notifier).modify(_selectedTag);
                });
              }
            },
            items: _tags.map((tag) {
              return DropdownMenuItem(
                value: tag.id,
                child:
                  Row(
                    children: [
                      Text(tag.name),
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