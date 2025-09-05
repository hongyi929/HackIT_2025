import 'package:flutter/material.dart';

class ColorButtonWidget extends StatefulWidget {
  const ColorButtonWidget({
    super.key,
    required this.color,
    required this.selected,
  });

  final Color color;

  final bool selected;

  @override
  State<ColorButtonWidget> createState() => _ColorButtonWidgetState();
}

class _ColorButtonWidgetState extends State<ColorButtonWidget> {
  @override
  Widget build(BuildContext context) {
    if (widget.selected == true) { 
      return Stack(
        alignment: AlignmentGeometry.center,
        children: [
          Container(
            height: 60,
            width: 90,
            decoration: ShapeDecoration(
              color: widget.color,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          Icon(Icons.check, size: 40),
        ],
      ); }
      else {
        return Container(
            height: 60,
            width: 90,
            decoration: ShapeDecoration(
              color: widget.color,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
      }
    } 
  }
