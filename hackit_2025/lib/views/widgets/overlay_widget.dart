
import 'package:flutter/material.dart';
import 'package:hackit_2025/views/widgets/alert_dialog_header.dart';

class OverlayWidget extends StatelessWidget {


  Map<String, double> timeData = {"time": 0.5};

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).primaryColor),
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        color: Colors.black87,
      ),
      height: screenHeight * 1,
      width: screenWidth * 0.5,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          AlertDialogHeader(),
        ],
      ),
    );
  }
}