import 'package:flutter/material.dart';
import 'package:hackit_2025/services/notif_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FilledButton(
        onPressed: () {
        NotifService().showNotification(title: "Title", body: "Body");
        },
        child: Text("Send notification"),
      ),
    );
  }
}
