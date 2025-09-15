import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:hackit_2025/data/constants.dart';
import 'package:hackit_2025/data/notifiers.dart';
import 'package:hackit_2025/services/local_database_service.dart';
import 'package:hackit_2025/views/pages/add_app_blocker.dart';
import 'package:hackit_2025/views/pages/app_block_details.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';

class UsagePage extends StatefulWidget {
  const UsagePage({super.key});

  @override
  State<UsagePage> createState() => _UsagePageState();
}

class _UsagePageState extends State<UsagePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    var localScheduleBox = Hive.box("localScheduleBox");
    var localTimeBlockBox = Hive.box("localTimeBlockBox");

    final timeBlockListener = service.on("updateLocalTimeBlockBox").listen((
      event,
    ) {
      localTimeBlockBox.put(event!['title'], event['boxItem']);
    });

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Text("Time Blockers", style: KTextStyle.titleText),
              ),
              localTimeBlockBox.isEmpty
                  ? Text("Add a time blocker!")
                  : Expanded(
                      child: ValueListenableBuilder(
                        valueListenable: timeBlockLengthNotifier,
                        builder: (context, value, child) {
                          return ListView.builder(
                            itemCount: value,
                            itemBuilder: (context, index) {
                              print(localTimeBlockBox.length);
                              // does it have keys?
                              final key = localTimeBlockBox.keyAt(index);
                              print(key);
                              final data = localTimeBlockBox.get(key);
                              return FutureBuilder<List<AppInfo>>(
                                future: obtainFilteredAppList(data),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return ListTile(
                                      title: Text("Loading apps..."),
                                    );
                                  }

                                  if (snapshot.hasError) {
                                    return ListTile(
                                      title: Text("Error loading apps"),
                                    );
                                  }

                                  print(snapshot.data);
                                  return GestureDetector(
                                    child: ListTile(
                                      leading: Image.memory(
                                        snapshot.data![0].icon!,
                                      ),
                                      title: Text("${data['title']}"),
                                      subtitle: Text(
                                        "Number of apps: ${snapshot.data!.length}",
                                      ),
                                      trailing: Switch(
                                        value: data['enabled'],
                                        onChanged: (value) {
                                          setState(() {
                                            data['enabled'] = value;
                                            localTimeBlockBox.put(
                                              key,
                                              data,
                                            ); // overwrite with updated map
                                            service.invoke(
                                              "updateTimeBlockServiceIsolate",
                                              {
                                                "title": data['title'],
                                                "boxItem": data,
                                              },
                                            );
                                          });
                                        },
                                      ),
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) {
                                            return AppBlockDetails(
                                              keyApp: key.toString(),
                                            );
                                          },
                                        ),
                                      );
                                    },
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
                    ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return AddAppBlocker();
              },
            ),
          );
        },
        icon: Icon(Icons.add, color: Colors.white),
        label: Text("Add App Blocker", style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0XFF1B69E0),
      ),
    );
  }

  // I need to get user to grant usage access permissions and display over other apps permissions
}
