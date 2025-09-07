import 'dart:io';
import 'package:flutter/services.dart'; // PlatformException
import 'package:android_intent_plus/android_intent.dart'; // open Settings
import 'package:app_usage/app_usage.dart'; // AppUsage().getAppUsage
import 'package:installed_apps/installed_apps.dart'; // getAppInfo
import 'package:installed_apps/app_info.dart'; // AppInfo model

// Filter values for your segmented control
enum TimeRange { today, week, month }

// Convert Today / Week / Month -> [start, end) (end is exclusive)
({DateTime start, DateTime end}) rangeBounds(TimeRange r) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  switch (r) {
    case TimeRange.today:
      return (start: today, end: today.add(const Duration(days: 1)));
    case TimeRange.week:
      final monday = today.subtract(Duration(days: today.weekday - 1));
      return (start: monday, end: monday.add(const Duration(days: 7)));
    case TimeRange.month:
      final first = DateTime(now.year, now.month, 1);
      final next = (now.month == 12)
          ? DateTime(now.year + 1, 1, 1)
          : DateTime(now.year, now.month + 1, 1);
      return (start: first, end: next);
  }
}

// Row model shown in "Most used apps"
class AppUsageRow {
  final String packageName;
  final String displayName;
  final Duration usage;
  final Uint8List? iconBytes;

  AppUsageRow({
    required this.packageName,
    required this.displayName,
    required this.usage,
    this.iconBytes,
  });
}

// STEP 1 — Check Usage Access by trying a tiny read.
// If it throws, send the user to the Usage Access settings page.
Future<bool> ensureUsagePermission() async {
  if (!Platform.isAndroid) return false;
  try {
    // Checks if usage access is enabled by performing a function with those permissions
    final now = DateTime.now();
    await AppUsage().getAppUsage(now.subtract(const Duration(minutes: 1)), now);
    return true;
  } on PlatformException { // On any exception, it means its not enabled, so user is redirected to allow permissions
    const intent = AndroidIntent(
      action: 'android.settings.USAGE_ACCESS_SETTINGS',
    );
    await intent.launch();
    return false;
  } catch (_) {
    const intent = AndroidIntent(
      action: 'android.settings.USAGE_ACCESS_SETTINGS',
    );
    await intent.launch();
    return false;
  }
}

// STEP 2 — Load usage for the selected range, sum per app, sort,
// then look up friendly name + icon via installed_apps.
Future<List<AppUsageRow>> loadUsage(TimeRange range, {int limit = 10}) async {
  final b = rangeBounds(range);

  List<AppUsageInfo> raw;
  try {
    raw = await AppUsage().getAppUsage(b.start, b.end);
  } on PlatformException {
    return [];
  } catch (_) {
    return [];
  }

  final totals = <String, Duration>{};
  for (final info in raw) {
    totals.update(
      info.packageName,
      (d) => d + info.usage,
      ifAbsent: () => info.usage,
    );
  }

  final top = totals.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  final rows = <AppUsageRow>[];
  for (final e in top.take(limit)) {
    String name = e.key;
    Uint8List? icon;

    try {
      final AppInfo? app = await InstalledApps.getAppInfo(e.key, null);
      if (app != null) {
        name = app.name;
        icon = app.icon;
      }
    } catch (_) {}

    rows.add(
      AppUsageRow(
        packageName: e.key,
        displayName: name,
        usage: e.value,
        iconBytes: icon,
      ),
    );
  }

  return rows;
}

// STEP 3 — Helpers used by the UI
Duration totalUsage(List<AppUsageRow> rows) =>
    rows.fold(Duration.zero, (sum, r) => sum + r.usage);

String formatDuration(Duration d) {
  final h = d.inHours;
  final m = d.inMinutes.remainder(60);
  return h > 0 ? '${h}h ${m}m' : '${m}m';
}
