import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:hackit_2025/data/constants.dart';
import 'package:hackit_2025/data/notifiers.dart';
import 'package:hackit_2025/views/widgets/color_button_widget.dart';
import 'package:hackit_2025/views/widgets/color_palette_widget.dart';
import 'package:hackit_2025/views/widgets/input_widget.dart';
import 'package:hive/hive.dart';

class AddCategoryPage extends StatefulWidget {
  const AddCategoryPage({super.key});

  @override
  State<AddCategoryPage> createState() => _AddCategoryPageState();
}

List<int> colorList = [
  Color(0xFFEF2222).toARGB32(),
  Color(0XFFEFA022).toARGB32(),
  Color(0XFF22C6EF).toARGB32(),
  Color(0XFF228CEF).toARGB32(),
  Color(0xFF5CD851).toARGB32(),
  Color(0XFFFF7DDC).toARGB32(),
  Color(0XFFF99494).toARGB32(),
  Color(0XFFFFE14D).toARGB32(),
  Color(0xFFED78DF).toARGB32(),
  Color(0XFF5CE4B5).toARGB32(),
  Color(0XFF666666).toARGB32(),
  Color(0XFFD9D9D9).toARGB32(),
];



class _AddCategoryPageState extends State<AddCategoryPage> {


  TextEditingController categoryController = TextEditingController();
  int selectedIndex = 0;
  Color colorPicker = Colors.grey;
  final categoryKey = GlobalKey<FormState>();
  int createdColor = Color(0xFFEF2222).toARGB32();
  @override
  Widget build(BuildContext context) {
    
    final categoryBox = Hive.box("category_box");
    
    print(categoryBox.length);
    if (categoryBox.isNotEmpty) {
      print(categoryBox.get("ss"));
    } else {
      print("No categories yet");
    }
    return Scaffold(
      
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SizedBox(
          width: double.infinity,
          child: Form(
            key: categoryKey,
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
                SizedBox(
                  height: 300,
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 20,
                      childAspectRatio: 1.35,
                    ),
                    itemCount: colorList.length,
                    itemBuilder: (context, index) {
                      Color boxColor = Color(colorList[index]);
                      if (index < 11) {
                        return GestureDetector(
                          child: ColorButtonWidget(
                            color: boxColor,
                            selected: selectedIndex == index,
                          ),
                          onTap: () {
                            setState(() {
                              selectedIndex = index;
                              createdColor = colorList[index];
                            });
                          },
                        );
                      } else {
                        return GestureDetector(
                          child: ColorPaletteWidget(
                            color: colorPicker,
                            selected: selectedIndex == index,
                          ),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return SizedBox(
                                  height: 300,
                                  child: AlertDialog(
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ColorPicker(
                                          pickerColor: colorPicker,
                                          onColorChanged: (value) {
                                            setState(() {
                                              colorPicker = value;
                                              selectedIndex = index;
                                              createdColor = value.toARGB32();
                                            });
                                          },
                                        ),
                                        FilledButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text("Select color"),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      }
                    },
                  ),
                ),
                FilledButton(
                  onPressed: () {
                    if (categoryKey.currentState!.validate()) {
                        categoryBox.put(categoryController.text, [
                        categoryController.text,
                        createdColor
                      ]);
                      categoryAmountNotifier.value = categoryBox.length;
                      Navigator.pop(context);
                    }
                  },
                  child: Text("Create category"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
