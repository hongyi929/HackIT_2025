import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:hackit_2025/data/constants.dart';
import 'package:hive/hive.dart';
import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';

class AppBlockDetails extends StatefulWidget {
  const AppBlockDetails({super.key, required this.keyApp});

  final String keyApp;

  @override
  State<AppBlockDetails> createState() => _AppBlockDetailsState();
}

final service = FlutterBackgroundService();

Future<List<AppInfo>> obtainFilteredAppList(boxItem) async {
  List<AppInfo> apps = await InstalledApps.getInstalledApps(true, true);
  List<String> appNames = List<String>.from(boxItem['apps'] ?? []);
  List<AppInfo> filteredApps = apps
      .where((app) => appNames.contains(app.name))
      .toList();
  return filteredApps;
}

var timeBlockBox = Hive.box("localTimeBlockBox");

class _AppBlockDetailsState extends State<AppBlockDetails> {
  @override
  Widget build(BuildContext context) {
    var boxItem = timeBlockBox.get(widget.keyApp);
    var filteredApps = obtainFilteredAppList(boxItem);
    int timeLimit = boxItem['timeLimit'];
    int hours = timeLimit ~/ 3600;
    int minutes = timeLimit~/60 - hours* 60;
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(boxItem['title'], style: KTextStyle.header1Text),
            Text("Time Limit: $hours hours, $minutes minutes"),
            Text("Apps blocked:"),
            FutureBuilder(
              future: obtainFilteredAppList(boxItem),
              builder: (context, asyncSnapshot) {
                if (asyncSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return Expanded(
                  child: ListView.builder(
                    itemCount: boxItem['apps'].length,
                    itemBuilder: (context, index) {
                      var appName = boxItem['apps'][index];
                      return ListTile(
                              leading: Image.memory(asyncSnapshot.data![index].icon!),
                              title: Text(asyncSnapshot.data![index].name),
                            );
                    },
                  ),
                );
              }
            ),
          ],
        ),
      ),
    );
  }
}
