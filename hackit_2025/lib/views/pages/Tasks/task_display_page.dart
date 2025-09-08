import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TaskDisplayPage extends StatefulWidget {
  const TaskDisplayPage({super.key, required this.title, required this.description, required this.date, required this.categoryName, required this.categoryColor});

  final String title;
  final String description;
  final Timestamp date;
  final String categoryName;
  final Color categoryColor;

  @override
  State<TaskDisplayPage> createState() => _TaskDisplayPageState();
}

class _TaskDisplayPageState extends State<TaskDisplayPage> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}