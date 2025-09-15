import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:hackit_2025/data/notifiers.dart';
import 'package:hackit_2025/firebase_options.dart';
import 'package:hackit_2025/services/background_services.dart';
import 'package:hackit_2025/services/notif_service.dart';
import 'package:hackit_2025/views/pages/permission_page.dart';
import 'package:hackit_2025/views/pages/welcome_page.dart';
import 'package:hackit_2025/views/widgets/overlay_widget.dart';
import 'package:hackit_2025/widget_tree.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:usage_stats/usage_stats.dart';

void main() async {
  // Initialise and connect to firebase platform
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Initialise Notifications Service and asks for Notifications Permissions within the initNotif Function
  await NotifService().initNotification();
  await Hive.initFlutter();
  await initializeService();
  var scheduleBox = await Hive.openBox("localScheduleBox");
  var timeBlockBox = await Hive.openBox("localTimeBlockBox");

  timeBlockLengthNotifier.value = timeBlockBox.length;
  print(timeBlockBox.length);
  timeBlockBox.clear();
  // DIsplay over other apps and Usage Access

  runApp(const MyApp());
}

@pragma("vm:entry-point")
void overlayMain() async {
  debugPrint("Starting Alerting Window Isolate!");
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MaterialApp(debugShowCheckedModeBanner: false, home: OverlayWidget()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Future<bool> checkPermissions() async {
    final usagePermission = await UsageStats.checkUsagePermission() ?? false;
    final overlayPermission = await FlutterOverlayWindow.isPermissionGranted();
    return usagePermission && overlayPermission;
  }

  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MEOW',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      // We will use a streambuilder to actively listen for realtime changes on whether user is logged in or not
      // Whenever this value changes, the streambuilder automatically runs again, redirecting accordingly
      // Streambuilder rebuilds its own layered stack. So to see the rebuild, you need to be on the same layered stack
      debugShowCheckedModeBanner: false,
      home: FutureBuilder(
        future: checkPermissions(),
        builder: (context, asyncSnapshot) {
          return StreamBuilder(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting ||
                  asyncSnapshot.connectionState == ConnectionState.waiting) {
                return Container(
                  color: Colors.white,
                  child: const Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.data != null) {
                selectedPageNotifier.value = 0;
                return asyncSnapshot.data! ? WidgetTree() : PermissionPage();
              } else {
                selectedPageNotifier.value = 0;
                return WelcomePage();
              }
            },
          );
        },
      ),
    );
  }
}
