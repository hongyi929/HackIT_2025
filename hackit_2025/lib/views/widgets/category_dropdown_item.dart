import 'package:flutter/material.dart';

class CategoryDropdownItem extends StatelessWidget {
  const CategoryDropdownItem({super.key, required this.categoryName, required this.categoryColor});

  final String categoryName;
  final Color categoryColor;
  
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 20,
          decoration: BoxDecoration(shape: BoxShape.circle, color: categoryColor),
        ),
        SizedBox(width: 10),
        Expanded(child: Text(categoryName)),
      ],
    );
  }
}
