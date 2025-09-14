import 'dart:math';

import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:hackit_2025/data/constants.dart';
import 'package:hackit_2025/views/widgets/alert_dialog_service.dart';
import 'package:hive/hive.dart';

List<String> activities = [
  "read a book",
  "go for a walk",
  "draw or paint",
  "cook a new recipe",
  "do some stretches or yoga",
  "write in a journal",
  "listen to music",
  "call a friend or family member",
  "meditate",
  "organize your desk or room",
  "try a DIY craft",
  "practice a musical instrument",
  "go for a bike ride",
  "do a puzzle or brain game",
  "learn a few words in a new language",
];

Random random = Random();
int randomInt = random.nextInt(14);

class AlertDialogHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Material(
      type: MaterialType.transparency,
      child: SizedBox(
        height: screenHeight * 0.7,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(padding: EdgeInsets.all(0)),
            SizedBox(height: 230),
            _title(),
            SizedBox(height: 50),
            _timeSpent(),
            SizedBox(height: 50),
            _dismissButton(context),
            SizedBox(width: screenWidth * 0.05),
          ],
        ),
      ),
    );
  }

  Widget _title() {
    return Text(
      "This App is Blocked!",
      style: TextStyle(
        color: Colors.white,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _timeSpent() {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(221, 158, 158, 158),
        borderRadius: BorderRadius.circular(15),
      ),
      height: 150,
      width: 260,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "You have reached your screentime limit!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
                fontWeight: FontWeight.w500
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Maybe you should ${activities[randomInt]}",
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _dismissButton(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 7, 125, 222),
      ),
        
      onPressed: () async {
        await AlertDialogService.closeAlertDialog();
        final intent = AndroidIntent(
          action: 'android.intent.action.MAIN',
          category: 'android.intent.category.HOME',
        );
        await intent.launch();
      },
      child: SizedBox(
        width: 215,
        child: Row(   
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Text("Close App")],
        ),
      ),
    );
  }
}
