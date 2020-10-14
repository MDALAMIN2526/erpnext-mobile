// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:frappe_app/utils/config_helper.dart';
// import 'package:frappe_app/utils/helpers.dart';
// import 'package:frappe_app/utils/queue_helper.dart';
// import 'package:workmanager/workmanager.dart';

// import 'utils/cache_helper.dart';
// import 'utils/http.dart';
// import 'service_locator.dart';
// import 'services/storage_service.dart';

// const String TASK_SYNC_DATA = 'downloadModules';
// const String TASK_PROCESS_QUEUE = 'processQueue';
// const String SYNC_DATA_TASK_UNIQUE_NAME = '101';
// const String PROCESS_QUEUE_UNIQUE_NAME = '102';

// void callbackDispatcher() {
//   Workmanager.executeTask((task, inputData) async {
//     setupLocator();
//     await locator<StorageService>().initStorage();
//     await locator<StorageService>().initBox('queue');
//     await locator<StorageService>().initBox('cache');
//     await locator<StorageService>().initBox('config');
//     await initConfig();
//     final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//         FlutterLocalNotificationsPlugin();
//     const AndroidInitializationSettings initializationSettingsAndroid =
//         AndroidInitializationSettings('app_icon');

//     final IOSInitializationSettings initializationSettingsIOS =
//         IOSInitializationSettings();
//     final InitializationSettings initializationSettings =
//         InitializationSettings(
//       iOS: initializationSettingsIOS,
//       android: initializationSettingsAndroid,
//     );
//     await flutterLocalNotificationsPlugin.initialize(
//       initializationSettings,
//     );

//     var notificationCount = await getActiveNotifications();

//     if (ConfigHelper().isLoggedIn) {
//       switch (task) {
//         case TASK_SYNC_DATA:
//           await showNotification(
//             title: "Sync",
//             subtitle: "Downloading Modules",
//             index: notificationCount,
//           );
//           print("$task was executed");
//           await syncnow();
//           print('Sync complete');
//           await showNotification(
//             title: "Sync",
//             subtitle: "Downloading Modules completed",
//             index: notificationCount,
//           );

//           break;

//         case TASK_PROCESS_QUEUE:
//           print('process queue started');
//           await showNotification(
//             title: "Queue",
//             subtitle: "Processing Queue",
//             index: notificationCount,
//           );
//           await QueueHelper.processQueue();
//           await showNotification(
//             title: "Queue",
//             subtitle: "Processing Queue Completed",
//             index: notificationCount,
//           );
//           break;
//       }
//       return Future.value(true);
//     } else {
//       print('not logged in');
//       return Future.value(true);
//     }
//   });
// }

// initAutoSync(bool isDebugMode) async {
//   await Workmanager.initialize(
//     callbackDispatcher,
//     isInDebugMode: isDebugMode,
//   );
//   registerPeriodicTask();
// }

// void registerPeriodicTask() {
//   Workmanager.registerPeriodicTask(
//     SYNC_DATA_TASK_UNIQUE_NAME,
//     TASK_SYNC_DATA,
//     frequency: Duration(minutes: 15),
//     constraints: Constraints(
//       networkType: NetworkType.connected,
//       requiresBatteryNotLow: false,
//     ),
//     existingWorkPolicy: ExistingWorkPolicy.replace,
//   );

//   Workmanager.registerPeriodicTask(
//     PROCESS_QUEUE_UNIQUE_NAME,
//     TASK_PROCESS_QUEUE,
//     frequency: Duration(minutes: 15),
//     constraints: Constraints(
//       networkType: NetworkType.connected,
//       requiresBatteryNotLow: false,
//     ),
//     existingWorkPolicy: ExistingWorkPolicy.replace,
//   );
// }

// Future syncnow() async {
//   print("downloading modules2");

//   if (ConfigHelper().activeModules != null) {
//     var activeModules = ConfigHelper().activeModules;

//     for (var module in activeModules.keys) {
//       await CacheHelper.cacheModule(module);
//     }

//     return Future.value(true);
//   }
// }
