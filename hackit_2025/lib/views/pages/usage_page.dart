import 'package:flutter/material.dart';

class UsagePage extends StatefulWidget {
  const UsagePage({super.key});

  @override
  State<UsagePage> createState() => _UsagePageState();
}

class _UsagePageState extends State<UsagePage> {
  @override
  Widget build(BuildContext context) {
    return Container(child: Text('Usage'));
  }
}
