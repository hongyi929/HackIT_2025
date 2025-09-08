import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hackit_2025/data/constants.dart';
import 'package:hackit_2025/views/pages/login_page.dart';
import 'package:hackit_2025/views/widgets/input_widget.dart';
import 'package:hackit_2025/widget_tree.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

TextEditingController emailController = TextEditingController();
TextEditingController passwordController = TextEditingController();
final signupKey = GlobalKey<FormState>();

Future<void> createUserWithEmailAndPassword() async {
  try {
    final userCredential = await FirebaseAuth.instance
      .createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
  print(userCredential);
  } on FirebaseAuthException catch (e) {
    print(e.message);
  }
}

class _SignupPageState extends State<SignupPage> {
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
              Text("Sign Up", style: KTextStyle.header1Text),
              InputWidget(title: "Email", controller: emailController),
              InputWidget(title: "Password", controller: passwordController),
              FilledButton(
                onPressed: () async {
                  if (signupKey.currentState!.validate()) {
                    await createUserWithEmailAndPassword();
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
                      return WidgetTree();
                    },));
                  }
                },
                child: Text("Sign Up"),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Already have an account?"),
                  TextButton(onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) {
                      return LoginPage();
                    },));
                  }, child: Text("Log in here."))
                ],
              ),
              SizedBox(height: 100)
            ],
          ),
        ),
      ),
    );
  }
}
