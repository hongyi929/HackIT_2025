import 'package:flutter/material.dart';

class CategoryDropdownItem extends StatelessWidget {
  const CategoryDropdownItem({super.key});

  @override
  Widget build(BuildContext context) {
    return DropdownMenuItem(
      value: "gr",
      child: SizedBox(
        width: double.infinity,
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue,
              ),
            ),
            SizedBox(width: 10),
            Expanded(child: Text("The category item name")),
          ],
        ),
      ),
    );
  }
}
