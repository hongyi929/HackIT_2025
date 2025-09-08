import 'package:flutter/material.dart';

class FilterButton extends StatefulWidget {
  const FilterButton({super.key, required this.label, required this.selected});
  final Text label;
  final bool selected;
  @override
  State<FilterButton> createState() => _FilterButtonState();
}

class _FilterButtonState extends State<FilterButton> {
  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: widget.label,
      selected: widget.selected,
      selectedColor: Color(0xFFF3FAFF),
      disabledColor: null,
      shape: ContinuousRectangleBorder(
        side: BorderSide(color: Colors.grey),
        borderRadius: BorderRadiusGeometry.all(Radius.circular(20)),
      )
    );
  }
}
