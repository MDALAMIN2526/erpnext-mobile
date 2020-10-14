import 'package:flutter/material.dart';
import 'package:frappe_app/config/frappe_icons.dart';
import 'package:frappe_app/utils/frappe_alert.dart';
import 'package:frappe_app/utils/frappe_icon.dart';
import 'package:provider/provider.dart';

import '../app.dart';

import '../config/palette.dart';

import '../widgets/card_list_tile.dart';

import '../utils/backend_service.dart';
import '../utils/enums.dart';
import '../utils/helpers.dart';
import '../utils/queue_helper.dart';

class QueueList extends StatefulWidget {
  @override
  _QueueListState createState() => _QueueListState();
}

class _QueueListState extends State<QueueList> {
  BackendService backendService;

  @override
  void initState() {
    super.initState();
    backendService = BackendService();
  }

  void _refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var connectionStatus = Provider.of<ConnectivityStatus>(
      context,
    );

    return Scaffold(
      backgroundColor: Palette.bgColor,
      appBar: AppBar(
        title: Text('Queue'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _refresh();
        },
        child: ListView.builder(
          itemCount: QueueHelper.queueContainer.length,
          itemBuilder: (context, index) {
            var q = QueueHelper.getAt(index);
            return CardListTile(
              leading: IconButton(
                icon: Icon(Icons.sync),
                onPressed: () async {
                  if (connectionStatus == null ||
                      connectionStatus == ConnectivityStatus.offline) {
                    FrappeAlert.errorAlert(
                      title: 'Cant Sync, App is offline',
                      context: context,
                    );
                    return;
                  } else if (q["error"] != null) {
                    FrappeAlert.errorAlert(
                      title: "There was some error while processing this item",
                      context: context,
                    );
                    return;
                  }

                  await QueueHelper.processQueueItem(q, index);
                  _refresh();
                },
              ),
              title: Text(q['title'] ?? ""),
              subtitle: Row(
                children: [
                  Text(
                    q['doctype'],
                  ),
                  VerticalDivider(),
                  Text(
                    q["type"],
                  ),
                  VerticalDivider(),
                  if (q["error"] != null)
                    FrappeIcon(
                      FrappeIcons.error,
                      size: 20,
                    ),
                ],
              ),
              trailing: IconButton(
                onPressed: () {
                  QueueHelper.deleteAt(index);
                  setState(() {});
                },
                icon: Icon(Icons.clear),
              ),
              onTap: () {
                q["qIdx"] = index;
                Navigator.of(context, rootNavigator: true).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return CustomRouter(
                        viewType: ViewType.form,
                        doctype: q['doctype'],
                        queued: true,
                        queuedData: q,
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
