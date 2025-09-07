import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hackit_2025/data/notifiers.dart';
import 'package:hackit_2025/firebase_options.dart';
import 'package:hackit_2025/views/pages/welcome_page.dart';
import 'package:hackit_2025/widget_tree.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Hive.initFlutter();
  await Hive.openBox("task_box");
  final myBox = Hive.box("task_box");
  await Hive.openBox("category_box");
  final categoryBox = Hive.box("category_box");
  myBox.clear();
  categoryBox.clear();
  await categoryBox.put("Joe", ["Joe mama", 4294967295]);
  taskAmountNotifier.value = myBox.length;
  categoryAmountNotifier.value = categoryBox.length;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MEOW',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      // We will use a streambuilder to actively listen for realtime changes on whether user is logged in or not
      // Whenever this value changes, the streambuilder automatically runs again, redirecting accordingly
      debugShowCheckedModeBanner: false,
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.data != null) {
            return WidgetTree();
          } else {
            return WelcomePage();
          }
        },
      ),
    );
  }
}
