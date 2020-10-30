import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:device_info/device_info.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:frappe_app/screens/no_internet.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';
import 'http.dart';

import '../form/controls/control.dart';

import '../service_locator.dart';

import '../config/palette.dart';

import '../services/navigation_service.dart';

import '../utils/cache_helper.dart';
import '../utils/config_helper.dart';
import '../utils/dio_helper.dart';
import '../utils/enums.dart';
import '../utils/backend_service.dart';

import '../widgets/section.dart';
import '../widgets/custom_expansion_tile.dart';

Widget buildDecoratedWidget(Widget fieldWidget, bool withLabel,
    [String label = ""]) {
  if (withLabel) {
    return Padding(
      padding: Palette.fieldPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: Palette.labelPadding,
            child: Text(
              label,
              style: Palette.secondaryTxtStyle,
            ),
          ),
          fieldWidget
        ],
      ),
    );
  } else {
    return Padding(
      padding: Palette.fieldPadding,
      child: fieldWidget,
    );
  }
}

getDownloadPath() async {
  // TODO
  if (Platform.isAndroid) {
    return '/storage/emulated/0/Download/';
  } else if (Platform.isIOS) {
    final Directory downloadsDirectory =
        await getApplicationDocumentsDirectory();
    return downloadsDirectory.path;
  }
}

downloadFile(String fileUrl, String downloadPath) async {
  await _checkPermission();

  final absoluteUrl = getAbsoluteUrl(fileUrl);

  await FlutterDownloader.enqueue(
    headers: {
      HttpHeaders.cookieHeader: await DioHelper.getCookies(),
    },
    url: absoluteUrl,
    savedDir: downloadPath,
    showNotification:
        true, // show download progress in status bar (for Android)
    openFileFromNotification:
        true, // click on notification to open downloaded file (for Android)
  );
}

Future<bool> _checkPermission() async {
  if (Platform.isAndroid) {
    PermissionStatus permission = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.storage);
    if (permission != PermissionStatus.granted) {
      Map<PermissionGroup, PermissionStatus> permissions =
          await PermissionHandler()
              .requestPermissions([PermissionGroup.storage]);
      if (permissions[PermissionGroup.storage] == PermissionStatus.granted) {
        return true;
      }
    } else {
      return true;
    }
  } else {
    return true;
  }
  return false;
}

String toTitleCase(String str) {
  return str
      .replaceAllMapped(
          RegExp(
              r'[A-Z]{2,}(?=[A-Z][a-z]+[0-9]*|\b)|[A-Z]?[a-z]+[0-9]*|[A-Z]|[0-9]+'),
          (Match m) =>
              "${m[0][0].toUpperCase()}${m[0].substring(1).toLowerCase()}")
      .replaceAll(RegExp(r'(_|-)+'), ' ');
}

void showSnackBar(String txt, context) {
  Scaffold.of(context).showSnackBar(
    SnackBar(
      content: Text(txt),
    ),
  );
}

List<Widget> generateLayout({
  @required List fields,
  @required ViewType viewType,
  bool editMode = true,
  bool withLabel = true,
  Function onChanged,
}) {
  List<Widget> collapsibles = [];
  List<Widget> sections = [];
  List<Widget> widgets = [];

  List<String> collapsibleLabels = [];
  List<String> sectionLabels = [];

  bool isCollapsible = false;
  bool isSection = false;

  int cIdx = 0;
  int sIdx = 0;

  fields.forEach((field) {
    var val = field["_current_val"] ?? field["default"];

    if (val == '__user') {
      val = ConfigHelper().userId;
    }

    if (field["fieldtype"] == "Section Break") {
      if (sections.length > 0) {
        var sectionVisibility = sections.any((element) {
          if (element is Visibility) {
            return element.visible == true;
          } else {
            return true;
          }
        });

        widgets.add(
          Visibility(
            visible: sectionVisibility,
            child: sectionLabels[sIdx] != ''
                ? ListTileTheme(
                    contentPadding: EdgeInsets.all(0),
                    child: CustomExpansionTile(
                      maintainState: true,
                      initiallyExpanded: true,
                      title: Text(
                        sectionLabels[sIdx].toUpperCase(),
                        style: Palette.secondaryTxtStyle,
                      ),
                      children: [...sections],
                    ),
                  )
                : Section(
                    title: sectionLabels[sIdx],
                    children: [...sections],
                  ),
          ),
        );

        sIdx += 1;
        sections.clear();
      } else if (collapsibles.length > 0) {
        var sectionVisibility = collapsibles.any((element) {
          if (element is Visibility) {
            return element.visible == true;
          } else {
            return true;
          }
        });
        widgets.add(
          Visibility(
            visible: sectionVisibility,
            child: ListTileTheme(
              contentPadding: EdgeInsets.all(0),
              child: CustomExpansionTile(
                maintainState: true,
                title: Text(
                  collapsibleLabels[cIdx].toUpperCase(),
                  style: Palette.secondaryTxtStyle,
                ),
                children: [...collapsibles],
              ),
            ),
          ),
        );
        cIdx += 1;
        collapsibles.clear();
      }

      if (field["collapsible"] == 1) {
        isSection = false;
        isCollapsible = true;
        collapsibleLabels.add(field["label"]);
      } else {
        isCollapsible = false;
        isSection = true;
        sectionLabels
            .add(field["label"] != null ? field["label"].toUpperCase() : '');
      }
    } else if (isCollapsible) {
      if (viewType == ViewType.form) {
        collapsibles.add(
          Visibility(
            visible: editMode ? true : val != null && val != '',
            child: makeControl(
              field: field,
              value: val,
              withLabel: withLabel,
              editMode: editMode,
              onChanged: onChanged,
            ),
          ),
        );
      } else {
        collapsibles.add(
          makeControl(
            field: field,
            value: val,
            withLabel: withLabel,
            editMode: editMode,
            onChanged: onChanged,
          ),
        );
      }
    } else if (isSection) {
      if (viewType == ViewType.form) {
        sections.add(
          Visibility(
            visible: editMode ? true : val != null && val != '',
            child: makeControl(
              field: field,
              value: val,
              withLabel: withLabel,
              editMode: editMode,
              onChanged: onChanged,
            ),
          ),
        );
      } else {
        sections.add(
          makeControl(
            field: field,
            value: val,
            withLabel: withLabel,
            editMode: editMode,
            onChanged: onChanged,
          ),
        );
      }
    } else {
      if (viewType == ViewType.form) {
        widgets.add(
          Visibility(
            visible: editMode ? true : val != null && val != '',
            child: makeControl(
              field: field,
              value: val,
              withLabel: withLabel,
              editMode: editMode,
              onChanged: onChanged,
            ),
          ),
        );
      } else {
        widgets.add(
          makeControl(
            field: field,
            value: val,
            withLabel: withLabel,
            editMode: editMode,
            onChanged: onChanged,
          ),
        );
      }
    }
  });

  return widgets;
}

DateTime parseDate(val) {
  if (val == null) {
    return null;
  } else if (val == "Today") {
    return DateTime.now();
  } else {
    return DateTime.parse(val);
  }
}

List generateFieldnames(String doctype, Map meta) {
  var fields = [
    'name',
    'modified',
    '_assign',
    '_seen',
    '_liked_by',
    '_comments',
  ];

  if (hasTitle(meta)) {
    fields.add(meta["title_field"]);
  }

  if (hasField(meta, 'status')) {
    fields.add('status');
  } else {
    fields.add('docstatus');
  }

  var transformedFields = fields.map((field) {
    return "`tab$doctype`.`$field`";
  }).toList();

  return transformedFields;
}

String getInitials(String txt) {
  List<String> names = txt.split(" ");
  String initials = "";
  int numWords = 2;

  if (names.length < numWords) {
    numWords = names.length;
  }
  for (var i = 0; i < numWords; i++) {
    initials += names[i] != '' ? '${names[i][0].toUpperCase()}' : "";
  }
  return initials;
}

bool hasField(Map meta, String fieldName) {
  return meta.containsKey('_field$fieldName');
}

bool isSubmittable(Map meta) {
  return meta["is_submittable"] == 1;
}

List sortBy(List data, String orderBy, Order order) {
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

getActivatedDoctypes(Map doctypes, String module) {
  if (ConfigHelper().activeModules != null) {
    var activeModules = ConfigHelper().activeModules;
    var activeDoctypes = [];

    doctypes["message"]["cards"]["items"].forEach((item) {
      activeDoctypes.addAll(item["links"]);
    });
    activeDoctypes = activeDoctypes.where((m) {
      return activeModules[module].contains(
        m["name"],
      );
    }).toList();

    return activeDoctypes;
  }
}

bool hasTitle(Map meta) {
  return meta["title_field"] != null && meta["title_field"] != '';
}

getTitle(Map meta, Map doc) {
  if (hasTitle(meta)) {
    return doc[meta["title_field"]];
  } else {
    return doc["name"];
  }
}

clearLoginInfo() async {
  await DioHelper.getCookiePath()
    ..delete(
      ConfigHelper().uri,
    );
  ConfigHelper.set('isLoggedIn', false);
}

handle403() async {
  await clearLoginInfo();
  locator<NavigationService>().clearAllAndNavigateTo('session_expired');
}

handleError(Response error, [bool hideAppBar = false]) {
  if (error.statusCode == HttpStatus.forbidden) {
    handle403();
  } else if (error.statusCode == HttpStatus.serviceUnavailable) {
    return NoInternet(hideAppBar);
  } else {
    return Text("${error.statusMessage}");
  }
}

Future<void> showNotification({
  @required String title,
  @required String subtitle,
  int index = 0,
}) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'FrappeChannelId',
    'FrappeChannelName',
    'FrappeChannelDescription',
    // importance: Importance.max,
    // priority: Priority.high,
    ticker: 'ticker',
  );
  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin.show(
    index,
    title,
    subtitle,
    platformChannelSpecifics,
  );
}

Future<int> getActiveNotifications() async {
  final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
  if (!(androidInfo.version.sdkInt >= 23)) {
    return 0;
  }

  final List<ActiveNotification> activeNotifications =
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.getActiveNotifications();

  return activeNotifications.length;
}

showErrorDialog(e, BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(e.statusMessage),
        actions: <Widget>[
          FlatButton(
            child: Text('Ok'),
            onPressed: () async {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

Map extractChangedValues(Map original, Map updated) {
  var changedValues = {};
  for (var key in updated.keys) {
    if (original[key] != updated[key]) {
      changedValues[key] = updated[key];
    }
  }
  return changedValues;
}

requestIOSLocationAuthorization(connectivity) async {
  try {
    if (Platform.isIOS) {
      LocationAuthorizationStatus status =
          await connectivity.getLocationServiceAuthorization();
      if (status == LocationAuthorizationStatus.notDetermined) {
        status = await connectivity.requestLocationServiceAuthorization();
      } else {
        return {
          "access": true,
        };
      }
    }
  } on PlatformException catch (e) {
    print(e.toString());
    return {
      "access": false,
    };
  }
}

Future<bool> verifyOnline() async {
  bool isOnline = false;
  try {
    final result = await InternetAddress.lookup('google.com');
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      isOnline = true;
    } else
      isOnline = false;
  } on SocketException catch (_) {
    isOnline = false;
  }

  return isOnline;
}

getLinkFields(String doctype) async {
  var docMeta = await BackendService.getDoctype(
    doctype,
  );
  docMeta = docMeta["docs"][0];
  var linkFieldDoctypes = docMeta["fields"]
      .where((d) => d["fieldtype"] == 'Link')
      .map((d) => d["options"])
      .toList();

  return linkFieldDoctypes;
}

putSharedPrefValue(String key, bool value) async {
  var _prefs = await SharedPreferences.getInstance();
  await _prefs.setBool(key, value);
}

Future<bool> getSharedPrefValue(String key) async {
  var _prefs = await SharedPreferences.getInstance();
  await _prefs.reload();
  return _prefs.getBool(key);
}
