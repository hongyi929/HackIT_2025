import 'package:flutter/material.dart';

class ColorButtonWidget extends StatefulWidget {
  const ColorButtonWidget({super.key, required this.color});

  final Color color;

  @override
  State<ColorButtonWidget> createState() => _ColorButtonWidgetState();
}

class _ColorButtonWidgetState extends State<ColorButtonWidget> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        height: 60,
        width: 90,
        decoration: ShapeDecoration(
          color: widget.color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      onTap: () {
        
      },
    );
  }
}
