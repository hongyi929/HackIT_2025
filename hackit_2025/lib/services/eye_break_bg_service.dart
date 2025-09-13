import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:hackit_2025/data/notifiers.dart';
import 'package:hackit_2025/services/notif_service.dart';

Future<void> initializeService() async {
  final eyeService = FlutterBackgroundService();

  await eyeService.configure(
    iosConfiguration: IosConfiguration(),
    androidConfiguration: AndroidConfiguration(
      onStart: onStart, // Evth u want your eyeService to do, defined here
      isForegroundMode: false,
      autoStart: true, // Isit fg or bg eyeService
    ),
  );
  await eyeService.startService();
}

// Implement onStart function
// Setup Listeners here, to change eyeService accordingly from bg, fg and stop
// Additional function: Add timer in this logic, to update notification displayed by foreground sv
// Timer will constantly update content of that notification
@pragma('vm:entry-point')
void onStart(ServiceInstance eyeService) async {
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

  //Whatever you invoke will cause the eyeService to start, stop etc. using those keys 'set as bg, fg etc'
  // This timer function specifically has to repeat every second to listen accordingly

  Timer eyeTimer = Timer.periodic(Duration(seconds: 1), (timer) async {

    if (eyeService is AndroidServiceInstance) {
      if (await eyeService.isForegroundService()) {
        eyeService.setForegroundNotificationInfo(
          title: "Service",
          content: "Updated at ${DateTime.now()}",
        );
      } else {
        // I need to code timer logic. Duration shown in the clock is based on valuenotifier
        // I also need to return a boolean to tell the UI if the timer is in main vs 20s break, to display UI color and progressbar accordingly
        if (eyeStartNotifier.value == false) {
          eyeService.invoke("update_timer", {
            "timeLeft": 1200,
            "isBreak" : false
          });
          eyeTimerNotifier.value = 1200;
          eyeBreakNotifier.value = false;
          print("service is not running");
          // Don't run any function
        } else {
          if (eyeTimerNotifier.value > 0) {
            eyeTimerNotifier.value--;
            eyeService.invoke("update_timer", {
            "timeLeft": eyeTimerNotifier.value,
          });
            print("service is running");
          } else {
            if (eyeBreakNotifier.value == true) {
              eyeService.invoke("update_timer", {
                "isBreak" : false
              });
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
                "isBreak" : true,
                "timeLeft" : eyeTimerNotifier.value
              });
            }
          }
        }
      }
    }
  });
}
