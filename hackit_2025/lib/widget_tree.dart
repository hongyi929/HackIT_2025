import 'package:flutter/material.dart';
import 'package:hackit_2025/data/constants.dart';
import 'package:hackit_2025/data/notifiers.dart';
import 'package:hackit_2025/views/pages/home_page.dart';
import 'package:hackit_2025/views/pages/progress_page.dart';
import 'package:hackit_2025/views/pages/settings_page.dart';
import 'package:hackit_2025/views/pages/stats_page.dart';
import 'package:hackit_2025/views/pages/Tasks/tasks_page.dart';
import 'package:hackit_2025/views/pages/usage_page.dart';
import 'package:hackit_2025/views/widgets/navbar_widget.dart';

List<Widget> pages = [
  HomePage(),
  UsagePage(),
  TasksPage(),
  ProgressPage(),
  StatsPage(),
];

// Thinking if permission initialization should be here instead
// So maybe IF permission not enabled, it will first async-await come up a popup to ask them to allow perm for A
// After A has ran, B will run (via await async as well), same thing, popup and then lead them to enable the permission

class WidgetTree extends StatefulWidget {
  const WidgetTree({super.key});

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Icon(Icons.shield),
        ),
        title: Text("LockedIn", style: KTextStyle.header1Text),
        actions: [Padding(
          padding: const EdgeInsets.all(20.0),
          child: GestureDetector(child: Icon(Icons.person), onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return SettingsPage();
            },));
          },),
        ),],
        backgroundColor: Color(0xFFC0E6FF),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFC0E6FF), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment(0, 0.6),
          ),
        ),
        child: ValueListenableBuilder(
          valueListenable: selectedPageNotifier,
          builder: (context, selectedPage, child) {
            return pages.elementAt(selectedPage);
          },
        ),
      ),
      bottomNavigationBar: NavbarWidget(),
    );
  }
}
