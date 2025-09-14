import 'package:app_usage/app_usage.dart';
import 'package:flutter/material.dart';
import 'package:hackit_2025/dtos/application_data.dart';
import 'package:usage_stats/usage_stats.dart';

Future<Map<String, UsageInfo>> getCurrentUsageStats(
  List<dynamic> appIds,
) async {
  DateTime endDate = DateTime.now();
  DateTime startDate = endDate.subtract(const Duration(minutes: 600));

  Map<String, UsageInfo> queryAndAggregateUsageStats =
      await UsageStats.queryAndAggregateUsageStats(startDate, endDate);

  List<String> keys = queryAndAggregateUsageStats.keys.toList();
  for (String key in keys) {
    if (!appIds.contains(key)) {
      queryAndAggregateUsageStats.remove(key);
    }
  }
  return queryAndAggregateUsageStats;
}

String? checkIfAnyAppHasBeenOpened(
  Map<String, UsageInfo> currentUsage,
  Map<String, UsageInfo> previousUsage,
  List<dynamic> monitoredApplicationSet,
) {
  /*
      (i) Last used time updates when an app is opened as well as well then app is closed [Point a and Point b]
      (ii) Foreground total time changes when an app is closed [Point b]
      So to determine the startup, we can check for (i) first, and then to confirm that its not a "App Closing" use case
      we can crosscheck it with the foreground total time use case as well
     */

  for (String appId in monitoredApplicationSet) {
    if (currentUsage.containsKey(appId) && previousUsage.containsKey(appId)) {
      UsageInfo currentAppUsage = currentUsage[appId]!;
      UsageInfo previousAppUsage = previousUsage[appId]!;

      if (currentAppUsage.lastTimeUsed != previousAppUsage.lastTimeUsed) {
        if (currentAppUsage.totalTimeInForeground ==
            previousAppUsage.totalTimeInForeground) {
          return appId;
        }
      }
    }
  }

  return null;
}

bool? checkIfScheduleTrue(
  TimeOfDay startTime,
  TimeOfDay endTime,
  List<int> weekdays,
) {
  if (startTime == null || endTime == null || weekdays == null) {return false;}
  // 1 =mon, 7 = sun

  final now = DateTime.now();

  // Check if today is in the allowed weekdays
  if (!weekdays.contains(now.weekday)) return false;

  // Convert TimeOfDay to DateTime for today
  final startDateTime = DateTime(
    now.year,
    now.month,
    now.day,
    startTime.hour,
    startTime.minute,
  );
  final endDateTime = DateTime(
    now.year,
    now.month,
    now.day,
    endTime.hour,
    endTime.minute,
  );

  return now.isAfter(startDateTime) && now.isBefore(endDateTime);
}

Future<bool> checkTimeLimit(String? appOpened, timeLimit) async{
  final now = DateTime.now();
  final startOfDay = DateTime(now.year, now.month, now.day);
  
  AppUsage appUsage = AppUsage();
  
try {
  List<AppUsageInfo> infos = await appUsage.getAppUsage(startOfDay, now);

  // Filter only the apps you care about
  final filtered = infos.where((info) => appOpened!.contains(info.packageName)).toList();

  for (var app in filtered) {
    
    print('${app.appName} (${app.packageName}): ${app.usage.inMinutes} minutes today');
    var screenTime = app.usage.inSeconds;
    print(screenTime);
    if (screenTime > timeLimit) {
      return true;
    }
    else {
      return false;
    }
  }
  return false;
  
} catch (e) {
  print('Error fetching usage: $e');
  return false;
}



}