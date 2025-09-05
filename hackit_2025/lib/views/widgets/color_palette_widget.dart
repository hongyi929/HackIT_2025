import 'package:flutter/material.dart';

class ColorPaletteWidget extends StatefulWidget {
  const ColorPaletteWidget({
    super.key,
    required this.color,
    required this.selected,
  });

  final Color color;
  final bool selected;

  @override
  State<ColorPaletteWidget> createState() => _ColorPaletteWidgetState();
}

class _ColorPaletteWidgetState extends State<ColorPaletteWidget> {
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
      );
    } else {
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
          Icon(Icons.palette, size: 40)
        ],
      );
    }
  }
}
