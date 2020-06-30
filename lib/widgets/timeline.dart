import 'package:flutter/material.dart';

import '../config/palette.dart';
import '../utils/enums.dart';
import '../widgets/event.dart';

class Timeline extends StatefulWidget {
  final List data;
  final Function callback;

  Timeline(this.data, this.callback);

  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  var showAll = false;

  List sortByDate(List data, String orderBy, Order order) {
    if (order == Order.asc) {
      data.sort((a, b) {
        return a[orderBy].compareTo(b[orderBy]);
      });
    } else {
      data.sort((a, b) {
        return b[orderBy].compareTo(a[orderBy]);
      });
    }

    return data;
  }

  @override
  Widget build(BuildContext context) {
    var sortedEvents = sortByDate(widget.data, "creation", Order.desc);
    List<Widget> children = [
      SwitchListTile.adaptive(
        title: Text('Show All'),
        contentPadding: EdgeInsets.symmetric(horizontal: 8),
        value: showAll,
        activeColor: Colors.blue,
        onChanged: (val) {
          showAll = val;
          setState(() {});
        },
      )
    ];

    for (var event in sortedEvents) {
      EventType eventType;

      if (event["communication_medium"] == "Email") {
        eventType = EventType.email;
      } else if (event["comment_type"] == "Comment") {
        eventType = EventType.comment;
      } else {
        if (!showAll) {
          continue;
        }
        eventType = EventType.docVersion;
      }
      children.add(
        Event(
          eventType,
          event,
          widget.callback,
        ),
      );
    }

    return Container(
      color: Palette.bgColor,
      child: ListView.separated(
        padding: EdgeInsets.all(8),
        itemCount: children.length,
        itemBuilder: (BuildContext context, int index) {
          return children[index];
        },
        separatorBuilder: (BuildContext context, int index) {
          return Padding(
            padding: EdgeInsets.all(4),
          );
        },
      ),
    );
  }
}