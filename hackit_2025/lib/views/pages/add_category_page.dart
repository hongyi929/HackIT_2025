import 'package:flutter/material.dart';
import 'package:hackit_2025/data/constants.dart';
import 'package:hackit_2025/views/widgets/color_button_widget.dart';
import 'package:hackit_2025/views/widgets/input_widget.dart';

class AddCategoryPage extends StatefulWidget {
  const AddCategoryPage({super.key});

  @override
  State<AddCategoryPage> createState() => _AddCategoryPageState();
}

List<Widget> colorList = [
  ColorButtonWidget(color: Color(0xFFEF2222)),
  ColorButtonWidget(color: Color(0XFFEFA022)),
  ColorButtonWidget(color: Color(0XFF22C6EF)),
  ColorButtonWidget(color: Color(0XFF228CEF)),
  ColorButtonWidget(color: Color(0xFF5CD851)),
  ColorButtonWidget(color: Color(0XFFFF7DDC)),
  ColorButtonWidget(color: Color(0XFFF99494)),
  ColorButtonWidget(color: Color(0XFFFFE14D)),
  ColorButtonWidget(color: Color(0xFFED78DF)),
  ColorButtonWidget(color: Color(0XFF5CE4B5)),
  ColorButtonWidget(color: Color(0XFF666666)),
  ColorButtonWidget(color: Color(0XFFD9D9D9)),
];

class _AddCategoryPageState extends State<AddCategoryPage> {
  TextEditingController categoryController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Category Creator", style: KTextStyle.header1Text),
              SizedBox(height: 20),
              InputWidget(
                title: "Category Name",
                controller: categoryController,
              ),
              SizedBox(height: 20),
              Text("Color"),
              SizedBox(height: 10),
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 20,
                    childAspectRatio: 1.35
                  ),
                  itemCount: colorList.length,
                  itemBuilder: (context, index) {
                    Widget colorBox = colorList[index];
                    return GestureDetector(child: colorBox,
                    onTap: () {
                      
                    },);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
