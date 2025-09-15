import 'package:flutter/material.dart';
import 'package:hackit_2025/data/notifiers.dart';

class NavbarWidget extends StatelessWidget {
  const NavbarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: selectedPageNotifier,
      builder: (context, selectedPage, child) {
        return Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black87.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 10,
                offset: Offset(0, -1), // Shadow above the nav bar
              ),
            ],
          ),
          child: NavigationBar(
            backgroundColor: Color(0XFFF5FAFF),
            destinations: [
              NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
              NavigationDestination(
                icon: Icon(Icons.data_usage),
                label: 'Usage',
              ),
              NavigationDestination(icon: Icon(Icons.task), label: 'Tasks'),
              NavigationDestination(
                icon: Icon(Icons.emoji_nature_rounded),
                label: 'Progress',
              ),
              NavigationDestination(
                icon: Icon(Icons.auto_graph_sharp),
                label: 'Stats',
              ),
            ],
            onDestinationSelected: (int value) {
              selectedPageNotifier.value = value;
            },
            selectedIndex: selectedPage,
          ),
        );
      },
    );
  }
}
