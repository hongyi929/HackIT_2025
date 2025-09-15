import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:hackit_2025/data/constants.dart';
import 'package:hackit_2025/views/pages/home_page.dart';
import 'package:hackit_2025/widget_tree.dart';
import 'package:usage_stats/usage_stats.dart';

class PermissionPage extends StatefulWidget {
  const PermissionPage({super.key});

  @override
  State<PermissionPage> createState() => _PermissionPageState();
}

class _PermissionPageState extends State<PermissionPage> {
  bool usagePermissionGranted = false;
  bool drawOverOtherAppsPermissionGranted = false;
  bool get _allGranted =>
      usagePermissionGranted && drawOverOtherAppsPermissionGranted;

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
    super.dispose();
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
            Text("Enable Permissions", style: KTextStyle.titleText),
            SizedBox(height: 8),
            Text(
              "These permissions will enable the app to work as functioned!",
              style: KTextStyle.descriptionText,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),
            Container(
              padding: EdgeInsets.all(20),
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: cs.outlineVariant.withOpacity(0.4)),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  Text("Enable Usage Access"),
                  Expanded(child: SizedBox()),
                  usagePermissionGranted
                      ? Icon(Icons.check_circle, color: Colors.green)
                      : FilledButton(
                          onPressed: () {
                            UsageStats.grantUsagePermission();
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: Color(0XFF1B69E0),
                          ),
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
                color: Colors.white,
                border: Border.all(color: cs.outlineVariant.withOpacity(0.4)),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  Text("Overlay Permissions"),
                  Expanded(child: SizedBox()),
                  drawOverOtherAppsPermissionGranted
                      ? Icon(Icons.check_circle, color: Colors.green)
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
                          style: FilledButton.styleFrom(
                            backgroundColor: Color(0XFF1B69E0),
                          ),
                          child: Text("Enable"),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 0, 20, 50),
        child: SizedBox(
          height: 54,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1B69E0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: _allGranted
                ? () {
                    // Replace the stack so there's no back to PermissionPage
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const WidgetTree()),
                      (route) => false,
                    );
                  }
                : null, // disabled when either permission is missing
            child: const Text(
              'Continue',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
