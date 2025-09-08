import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hackit_2025/firebase_options.dart';
import 'package:hackit_2025/views/pages/welcome_page.dart';
import 'package:hackit_2025/widget_tree.dart';


void main() async {
  // Initialise and connect to firebase platform
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
      // Streambuilder rebuilds its own layered stack. So to see the rebuild, you need to be on the same layered stack
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
