import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:hackit_2025/data/notifiers.dart';
import 'package:hackit_2025/dtos/application_data.dart';
import 'package:hackit_2025/services/background_service_functions.dart';
import 'package:hackit_2025/services/local_database_service.dart';
import 'package:hackit_2025/services/notif_service.dart';
import 'package:hackit_2025/views/widgets/alert_dialog_service.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:usage_stats/usage_stats.dart';
import 'overlay_entrypoint.dart';

List<dynamic> _setMonitoringApplicationsSet(
  Map<dynamic, dynamic> databaseService,
  List<dynamic> monitoredApplicationSet,
) {
  List<dynamic> monitoredApps = databaseService["packageName"];
  monitoredApplicationSet.clear();

  monitoredApplicationSet = monitoredApps;
  return monitoredApplicationSet;
}

Future<void> initializeService() async {
  final eyeService = FlutterBackgroundService();

  await eyeService.configure(
    iosConfiguration: IosConfiguration(),
    androidConfiguration: AndroidConfiguration(
      onStart: onStart, // Evth u want your eyeService to do, defined here
      isForegroundMode: true,
      autoStart: true, // Isit fg or bg eyeService
    ),
  );

  if (!await eyeService.isRunning()) {
    await eyeService.startService();
  }
  // Now you can start it safely
  else {
    print("Service already exists!!!!");
    print("Service already exists!!!!");
    print("Service already exists!!!!");
  }
}

// Implement onStart function
// Setup Listeners here, to change eyeService accordingly from bg, fg and stop
// Additional function: Add timer in this logic, to update notification displayed by foreground sv
// Timer will constantly update content of that notification
Timer? eyeTimer;
@pragma('vm:entry-point')
void onStart(ServiceInstance eyeService) async {
  Hive.initFlutter();

  DatabaseService appDatabaseService = await DatabaseService.instance();
  var scheduleBox = await Hive.openBox("scheduleBox");
  var timeBlockBox = await Hive.openBox("timeBlockBox");
  timeBlockBox.clear();
  bool overlayShown = false;

  if (eyeService is AndroidServiceInstance) {
    // if android, setup like this for android
    eyeService.on('setAsForeground').listen((event) {
      eyeService.setAsForegroundService();
    });
    eyeService.on('setAsBackground').listen((event) {
      eyeService.setAsBackgroundService();
    });

    eyeService.on('updateUI').listen((event) {});
  }

  eyeService.on("stopService").listen((event) {
    eyeService.stopSelf();
  });

  eyeService.on("updateServiceIsolate1").listen((event) {
    if (event != null) {
      eyeTimerNotifier.value = event["timerValue"] ?? eyeTimerNotifier.value;
      eyeStartNotifier.value = event["startValue"] ?? eyeStartNotifier.value;
      eyeBreakNotifier.value = event['breakValue'] ?? eyeBreakNotifier.value;
    }
  });

  // Updates Service Isolate's Hive Box, to be used to show overlay.
  eyeService.on("updateTimeBlockServiceIsolate").listen((event) {
    if (event != null) {
      var title = event['title'];
      var boxItem = event['boxItem'];
      timeBlockBox.put(title, boxItem);
      print("finished");
      print(timeBlockBox.get(title));
    }
  });

  eyeService.on("overlayShown").listen((event) {
    if (event != null) {
      overlayShown = event['bool'];
    }
  });

  if (eyeTimer?.isActive ?? false) {
    print("Timer already running, skipping...");
    return;
  }
  ;
  //Whatever you invoke will cause the eyeService to start, stop etc. using those keys 'set as bg, fg etc'
  // This timer function specifically has to repeat every second to listen accordingly
  Map<String, UsageInfo>? previousUsageSession;
  Map<String, Map<String, UsageInfo>> previousUsageSessionsPerBlock = {};
  eyeTimer = Timer.periodic(Duration(seconds: 1), (timer) async {
    if (eyeService is AndroidServiceInstance) {
      if (await eyeService.isForegroundService()) {
        eyeService.setForegroundNotificationInfo(
          title: "LockedIn",
          content: "LockedIn is running in the background to help manage your screentime!",
        );
        if (appBlockNotifier.value) {
          // If AppBlock is enabled (default enabled)
          print("AppBlock service begins");
          if (timeBlockBox.isNotEmpty) {
            print("TimeBlockBox is not empty");

            for (var itemRaw in timeBlockBox.values) {
              var timeBlockItem = Map<dynamic, dynamic>.from(itemRaw);
              print(timeBlockItem);
              if (timeBlockItem['enabled'] == false) {
                continue;
              }

              // Loop to display overlay for scheduled-timers.
              
              List<dynamic> monitoredApplicationSet = List.from(timeBlockItem['packageName']);
              print(monitoredApplicationSet);

              Map<String, UsageInfo> currentUsageSession =
                  await getCurrentUsageStats(monitoredApplicationSet);
              print(
                currentUsageSession[monitoredApplicationSet[0]]!.lastTimeUsed,
              );
              print(
                currentUsageSession[monitoredApplicationSet[0]]!
                    .totalTimeInForeground,
              );
              // Gets usage stats of all apps, removing the ones not inside filtered package names.

              if (previousUsageSessionsPerBlock[timeBlockItem['title']] != null) {
                print("test3");
                String? appOpened = checkIfAnyAppHasBeenOpened(
                  // Function comparing foreground times between current vs previous, but idk if current and previous is defined too close that it is inaccurate.
                  currentUsageSession,
                  previousUsageSessionsPerBlock[timeBlockItem['title']]!,
                  monitoredApplicationSet,
                );
                appOpened != null ? print(appOpened) : print("hi");
                print("appopened");

                if (appOpened !=
                        null && // Compare time limit in seconds vs screentime in seconds
                    await checkTimeLimit(
                      appOpened,
                      timeBlockItem['timeLimit'],
                    ) && overlayShown == false)  {
                  AlertDialogService.createAlertDialog();
                  overlayShown = true;
                  print("showing overlay");
                  print(
                    previousUsageSession![monitoredApplicationSet[0]]!
                        .lastTimeUsed,
                  );
                  print(
                    previousUsageSession![monitoredApplicationSet[0]]!
                        .totalTimeInForeground,
                  );
                }
              }

              previousUsageSessionsPerBlock[timeBlockItem['title']] = currentUsageSession;
            }
          }
        }
        // I need to code timer logic. Duration shown in the clock is based on valuenotifier
        // I also need to return a boolean to tell the UI if the timer is in main vs 20s break, to display UI color and progressbar accordingly
        if (eyeStartNotifier.value == false) {
          eyeService.invoke("update_timer", {
            "timeLeft": 1200,
            "isBreak": false,
          });
          eyeTimerNotifier.value = 1200;
          eyeBreakNotifier.value = false;
          print("service is not running");
          // Don't run any function
        } else if (eyeStartNotifier.value == true) {
          if (eyeTimerNotifier.value > 0) {
            eyeTimerNotifier.value--;
            eyeService.invoke("update_timer", {
              "timeLeft": eyeTimerNotifier.value,
            });
            print("service is running");
          } else {
            if (eyeBreakNotifier.value == true) {
              eyeService.invoke("update_timer", {"isBreak": false});
              eyeBreakNotifier.value = false;
              eyeTimerNotifier.value = 1200;
            } else {
              NotifService().showNotification(
                title: "Eye break",
                body: "Take a 20 second break pwease!",
              );

              eyeBreakNotifier.value = true;
              eyeTimerNotifier.value = 20;
              eyeService.invoke("update_timer", {
                "isBreak": true,
                "timeLeft": eyeTimerNotifier.value,
              });
            }
          }
        }
      } else {}
    }
  });
}
