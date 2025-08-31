import 'package:flutter/material.dart';
import 'package:hackit_2025/data/notifiers.dart';
import 'package:hackit_2025/views/pages/home_page.dart';
import 'package:hackit_2025/views/pages/progress_page.dart';
import 'package:hackit_2025/views/pages/stats_page.dart';
import 'package:hackit_2025/views/pages/tasks_page.dart';
import 'package:hackit_2025/views/pages/usage_page.dart';
import 'package:hackit_2025/views/widgets/navbar_widget.dart';

List<Widget> pages = [
  HomePage(),
  UsagePage(),
  TasksPage(),
  ProgressPage(),
  StatsPage(),
];

class WidgetTree extends StatefulWidget {
  const WidgetTree({super.key});

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ValueListenableBuilder(
        valueListenable: selectedPageNotifier,
        builder: (context, selectedPage, child) {
          return pages.elementAt(selectedPage);
        },
      ),
      bottomNavigationBar: NavbarWidget(),
    );
  }
}
