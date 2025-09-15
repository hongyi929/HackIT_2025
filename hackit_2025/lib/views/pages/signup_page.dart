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
String? errorMessage;

Future<dynamic> createUserWithEmailAndPassword() async {
  try {
    final userCredential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );
    return true;
  } on FirebaseAuthException catch (e) {
    errorMessage = e.toString();
    return false;
  }
}

class _SignupPageState extends State<SignupPage> {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(),
      body: Form(
        key: signupKey,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Sign Up", style: KTextStyle.titleText),
              SizedBox(height: 40),
              InputWidget(title: "Email", controller: emailController),
              SizedBox(height: 20),
              InputWidget(title: "Password", controller: passwordController),
              SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0XFF1B69E0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () async {
                    if (signupKey.currentState!.validate()) {
                      bool signUpSuccess =
                          await createUserWithEmailAndPassword();
                      if (signUpSuccess == true) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return WidgetTree();
                            },
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              errorMessage!,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      }
                    }
                  },
                  child: const Text(
                    'Sign Up',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Already have an account?"),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return LoginPage();
                          },
                        ),
                      );
                    },
                    child: Text("Log in here."),
                  ),
                ],
              ),
              SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}
