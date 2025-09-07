import 'package:flutter/material.dart';
import 'package:hackit_2025/data/constants.dart';
import 'package:hackit_2025/views/pages/signup_page.dart';
import 'package:hackit_2025/widget_tree.dart';
import 'package:lottie/lottie.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Lottie.asset('assets/lotties/welcome.json'),
                      Center(child: Text('L')),
                    ],
                  ),
                  Text('LockedIn', style: KTextStyle.homePageText),
                  SizedBox(height: 5),
                  Padding(
                    padding: EdgeInsetsGeometry.symmetric(horizontal: 40),
                    child: Text(
                      'The all-in-one app app for students, by students.',
                      style: KTextStyle.descriptionText,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 50.0),
                  FractionallySizedBox(
                    widthFactor: 0.8,
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: FilledButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return SignupPage();
                              },
                            ),
                          );
                        },
                        child: Text(
                          'Lets Get Started',
                          style: KTextStyle.header3Text,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
