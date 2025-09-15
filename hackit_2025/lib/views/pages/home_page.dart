import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:hackit_2025/data/constants.dart';
import 'package:hackit_2025/data/notifiers.dart';
import 'package:hackit_2025/services/notif_service.dart';
import 'package:hackit_2025/views/pages/WorkSession/session_editor_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final service = FlutterBackgroundService();
  StreamSubscription? listenUpdate;

  @override
  void initState() {
    super.initState();

    listenUpdate = service.on("update_timer").listen((event) {
      if (event != null) {
        // Update notifiers here
        eyeTimerNotifier.value = event["timeLeft"] ?? eyeTimerNotifier.value;
        eyeBreakNotifier.value = event["isBreak"] ?? eyeBreakNotifier.value;
        print("test invoked?");
        print(eyeTimerNotifier.value);
      }
    });
  }

  @override
  void dispose() {
    listenUpdate?.cancel(); // remove listener when widget is removed
    super.dispose();
  }

  Widget buildButton() {
    return eyeStartNotifier.value
        ? SizedBox(
            width: 135,
            height: 40,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Color(0XFF1B69E0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    12,
                  ), // Adjust the radius as needed
                ),
              ),
              onPressed: () {
                eyeStartNotifier.value = !eyeStartNotifier.value;
                service.invoke("updateServiceIsolate1", {
                  "startValue": eyeStartNotifier.value,
                });
                setState(() {});
              },
              child: Text("Stop Timer"),
            ),
          )
        : SizedBox(
            width: 135,
            height: 40,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Color(0XFF1B69E0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    12,
                  ), // Adjust the radius as needed
                ),
              ),
              onPressed: () {
                eyeStartNotifier.value = !eyeStartNotifier.value;
                service.invoke("updateServiceIsolate1", {
                  "startValue": eyeStartNotifier.value,
                });
                setState(() {});
              },
              child: Text("Start timer"),
            ),
          );
  }

  Widget buildTime() {
    return ValueListenableBuilder(
      valueListenable: eyeTimerNotifier,
      builder: (context, value, child) {
        String twoDigits(int n) => n.toString().padLeft(2, '0');
        final minutes = twoDigits(value ~/ 60);
        final seconds = twoDigits(value % 60);
        return Text("$minutes: $seconds", style: KTextStyle.header2Text);
      },
    );
  }

  Duration duration = Duration(seconds: eyeTimerNotifier.value);
  Timer? timer;
  bool? breakTime = false;
  bool buttonPress = false;

  @override
  int mainSeconds = eyeTimerNotifier.value;
  int maxMainSeconds = 1200;
  int maxBreakSeconds = 20;

  Widget build(BuildContext context) {
    print(eyeTimerNotifier.value);
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFC0E6FF), Color(0xFFF5FBFF)],
            begin: Alignment.topCenter,
            end: Alignment(0, 0.7),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Text("Work Session", style: KTextStyle.header1Text),
              ),
              SizedBox(
                height: 160,
                width: double.infinity,
                child: Card(
                  color: Colors.white,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Work Session", style: KTextStyle.header2Text),
                      Text("Focus your mind with one tap."),
                      SizedBox(height: 12),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: SizedBox(
                          width: double.infinity,
                          height: 45,
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  12,
                                ), // Adjust the radius as needed
                              ),
                              backgroundColor: Color(0XFF1B69E0),
                            ),

                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return SessionEditorPage();
                                  },
                                ),
                              );
                            },
                            child: Text(
                              "Get started",
                              style: KTextStyle.header3Text,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Align(
                alignment: Alignment.topLeft,
                child: Text("Eye Break", style: KTextStyle.header1Text),
              ),
              SizedBox(
                height: 240,
                width: double.infinity,
                child: Card(
                  color: Colors.white,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        alignment: AlignmentGeometry.center,
                        children: [
                          buildTime(),
                          SizedBox(
                            height: 120,
                            width: 120,
                            child: ValueListenableBuilder(
                              valueListenable: eyeTimerNotifier,
                              builder: (context, eyeTimer, child) {
                                return ValueListenableBuilder(
                                  valueListenable: eyeBreakNotifier,
                                  builder: (context, eyeBreak, child) {
                                    return CircularProgressIndicator(
                                      value: eyeBreak
                                          ? eyeTimer / maxBreakSeconds
                                          : eyeTimer / maxMainSeconds,
                                      strokeWidth: 10,
                                      color: Color(0XFF1B69E0),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 20),
                      buildButton(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
