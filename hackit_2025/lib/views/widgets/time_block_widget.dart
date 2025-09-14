import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:hackit_2025/data/notifiers.dart';
import 'package:hackit_2025/views/pages/Tasks/task_display_page.dart';
import 'package:hackit_2025/views/widgets/input_widget.dart';
import 'package:hive/hive.dart';
import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';

class TimeBlockWidget extends StatefulWidget {
  const TimeBlockWidget({super.key, required this.titleController});

  final TextEditingController titleController;

  @override
  State<TimeBlockWidget> createState() => _TimeBlockWidgetState();
}

class _TimeBlockWidgetState extends State<TimeBlockWidget> {
  List<AppInfo> installedApps = [];
  bool isLoading = true;
  Map<String, dynamic> selectedApps = {};
  var localTimeBlockBox = Hive.box("localTimeBlockBox");
  final service = FlutterBackgroundService();

  @override
  void initState() {
    super.initState();
    fetchInstalledApps();
  }

  Future<void> fetchInstalledApps() async {
    try {
      List<AppInfo> apps = await InstalledApps.getInstalledApps(true, true);
      apps = apps.where((app) {
        return !app.packageName.contains(".overlay") &&
            !app.packageName.contains(".config") &&
            !app.packageName.contains(".permissioncontroller");
      }).toList();
      setState(() {
        installedApps = apps;
        isLoading = false;
        LoopSelected();
      });
    } catch (e) {
      print("Error fetching installed apps: $e");
      setState(() => isLoading = false);
    }
  }

  Duration? selectedDuration;
  int? hours;
  int? minutes;
  void LoopSelected() {
    for (var app in installedApps) {
      selectedApps['${app.name}'] = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    print(installedApps);
    return Column(
      children: [
        InputWidget(title: "Title", controller: titleController),
        SizedBox(height: 50),
        Text("Screentime Limit"),
        FilledButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  content: SizedBox(
                    height: 320,
                    width: 300,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(Icons.close),
                        ),
                        CupertinoTimerPicker(
                          onTimerDurationChanged: (value) {
                            selectedDuration = value;
                          },
                          mode: CupertinoTimerPickerMode.hm,
                        ),
                        Align(
                          alignment: AlignmentGeometry.center,
                          child: FilledButton(
                            onPressed: () {
                              setState(() {
                                hours = selectedDuration!.inHours;
                                minutes =
                                    selectedDuration!.inMinutes - hours! * 60;
                                Navigator.pop(context);
                              });
                            },
                            child: Text("Confirm time"),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
          child: Text("Select Time"),
        ),
        selectedDuration == null
            ? Text("Set time limit for apps!")
            : Text("Selected time limit: $hours h $minutes min"),
        SizedBox(height: 40),
        Text("Select apps to limit"),
        FilledButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                return StatefulBuilder(
                  builder: (context, setState) {
                    return AlertDialog(
                      content: SizedBox(
                        height: 700,
                        width: double.infinity,
                        child: Column(
                          children: [
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    LoopSelected();
                                  },
                                  icon: Icon(Icons.close),
                                ),
                                SizedBox(width: 165),
                                IconButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    // I need the package name for later on
                                    // Figure out full logic b4 continuing
                                  },
                                  icon: Icon(Icons.check),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 600,
                              width: 500,
                              child: ListView.builder(
                                scrollDirection: Axis.vertical,
                                itemCount: installedApps.length,
                                itemBuilder: (context, index) {
                                  var app = installedApps[index];
                                  return SizedBox(
                                    height: 60,
                                    width: double.infinity,
                                    child: ListTile(
                                      leading: Image.memory(
                                        app.icon!,
                                        height: 32,
                                        width: 32,
                                      ),
                                      title: Text(app.name),
                                      trailing: Checkbox(
                                        value: selectedApps[app.name],
                                        onChanged: (value) {
                                          setState(() {
                                            selectedApps[app.name] = value!;
                                          });
                                        },
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
          child: Text("Select apps.."),
        ),
        FilledButton(
          onPressed: () {
            if (selectedDuration == null ||
                !selectedApps.values.any((value) => value == true || titleController.text == null)) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Please fill in all required blanks.")),
              );
            } else {
              localTimeBlockBox.put(titleController.text, {
                "apps": selectedApps.entries
                    .where((entry) => entry.value == true) // only true values
                    .map((entry) => entry.key) // take the key
                    .toList(),
                "packageName": installedApps
                    .where((app) => selectedApps[app.name] == true)
                    .map((app) => app.packageName)
                    .toList(),
                "title": titleController.text,
                "timeLimit": selectedDuration!.inSeconds,
                "enabled" : true
              });
              print("hello");
              service.invoke("updateTimeBlockServiceIsolate", {
                "title": titleController.text,
                "boxItem" : localTimeBlockBox.get(titleController.text)
              });
              Navigator.pop(context);
              timeBlockLengthNotifier.value = localTimeBlockBox.length;
            }
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Icon(Icons.check), Text("Save")],
          ),
        ),
      ],
    );
  }
}
