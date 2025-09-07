import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hackit_2025/data/constants.dart';
import 'package:hackit_2025/views/widgets/input_widget.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

TextEditingController emailController = TextEditingController();
TextEditingController passwordController = TextEditingController();
final signupKey = GlobalKey<FormState>();

Future<void> signInWithEmailAndPassword() async {
  try {
    final userCredential = await FirebaseAuth.instance
      .signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
  print(userCredential);
  } on FirebaseAuthException catch (e) {
    print(e.message);
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
                    await signInWithEmailAndPassword();
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