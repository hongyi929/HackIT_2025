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
    int hours = timeLimit ~/ 60;
    int minutes = (timeLimit - hours* 60) % 60;
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(boxItem['title'], style: KTextStyle.header1Text),
            Text("Time Limit: $hours hours, $minutes minutes"),
            Text("Apps blocked:"),
            Expanded(
              child: ListView.builder(
                itemCount: boxItem['apps'].length,
                itemBuilder: (context, index) {
                  var appName = boxItem['apps'][index];
                  return FutureBuilder(
                    future: obtainFilteredAppList(boxItem),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      }
                      else {
                        return ListTile(
                          leading: Image.memory(snapshot.data![index].icon!),
                          title: Text(snapshot.data![index].name),
                        );
              
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
