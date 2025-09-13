import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hackit_2025/data/constants.dart';
import 'package:hackit_2025/views/widgets/input_widget.dart';
import 'package:hackit_2025/widget_tree.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

TextEditingController emailController = TextEditingController();
TextEditingController passwordController = TextEditingController();
final signupKey = GlobalKey<FormState>();
String? errorMessage;

Future<bool> signInWithEmailAndPassword() async {
  try {
    final userCredential = await FirebaseAuth.instance
      .signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      return true;
  } on FirebaseAuthException catch (e) {
    errorMessage = e.toString();
    return false;
  }
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Form(
        key: signupKey,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Log in", style: KTextStyle.header1Text),
              InputWidget(title: "Email", controller: emailController),
              InputWidget(title: "Password", controller: passwordController),
              FilledButton(
                onPressed: () async {
                  if (signupKey.currentState!.validate()) {
                    bool loginSuccess = await signInWithEmailAndPassword();
                    if (loginSuccess == true) {
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
                        return WidgetTree();
                      },));
                    }
                    else {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(errorMessage!, textAlign: TextAlign.center,)));
                    }
                  }
                },
                child: Text("Log in"),
              ),
              SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}