import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:hackit_2025/data/constants.dart';
import 'package:usage_stats/usage_stats.dart';

class PermissionPage extends StatefulWidget {
  const PermissionPage({super.key});

  @override
  State<PermissionPage> createState() => _PermissionPageState();
}

class _PermissionPageState extends State<PermissionPage> {
  bool usagePermissionGranted = false;
  bool drawOverOtherAppsPermissionGranted = false;
  late Timer timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      usagePermissionGranted = (await UsageStats.checkUsagePermission())!;
      drawOverOtherAppsPermissionGranted =
          await FlutterOverlayWindow.isPermissionGranted();
      setState(() {});
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    timer.cancel();
    super.dispose(
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text("Enable Permissions", style: KTextStyle.header1Text),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(20),
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey,
                border: Border.all(color: cs.outlineVariant.withOpacity(0.4)),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  Text("Enable Usage Access"),
                  Expanded(child: SizedBox()),
                  usagePermissionGranted
                      ? Text("hi")
                      : FilledButton(
                          onPressed: () {
                            UsageStats.grantUsagePermission();
                          },
                          child: Text("Enable"),
                        ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(20),
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey,
                border: Border.all(color: cs.outlineVariant.withOpacity(0.4)),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  Text("Overlay Permissions"),
                  Expanded(child: SizedBox()),
                  drawOverOtherAppsPermissionGranted
                      ? Text("hi")
                      : FilledButton(
                          onPressed: () async {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Navigate to the app and enable overlay permissions.",
                                ),
                                duration: Duration(seconds: 5),
                              ),
                            );

                            await FlutterOverlayWindow.requestPermission();
                            Future.delayed(
                              Duration(seconds: 1),
                              () => setState(() {}),
                            );
                            setState(() {});
                          },
                          child: Text("Enable"),
                        ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(20),
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey,
                border: Border.all(color: cs.outlineVariant.withOpacity(0.4)),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  Text("Permission Name"),
                  Expanded(child: SizedBox()),
                  FilledButton(onPressed: () {}, child: Text("Enable")),
                ],
              ),
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(20),
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey,
                border: Border.all(color: cs.outlineVariant.withOpacity(0.4)),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  Text("Permission Name"),
                  Expanded(child: SizedBox()),
                  FilledButton(onPressed: () {}, child: Text("Enable")),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
