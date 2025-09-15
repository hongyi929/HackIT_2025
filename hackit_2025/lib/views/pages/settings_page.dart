import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});


  @override
  
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0XFFF3FAFF),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Color(0XFFF3FAFF)
        ),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("Currently logged in as: ${user!.email}"),
              FilledButton(onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.popUntil(context, (route) => route.isFirst);
              }, child: Text("Log out"))
            ],
          ),
        ),
      ),
    );
  }
}