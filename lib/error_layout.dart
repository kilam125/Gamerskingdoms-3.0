import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class ErrorLayout extends StatelessWidget {
  final String e;
  const ErrorLayout({
    super.key,
    required this.e
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: 
          RichText(
            textAlign: TextAlign.center,
            text:TextSpan(
              children:<TextSpan>[
                const TextSpan(
                  text:"Fatal error happened while charging user data, please report this bug to the support mail.\n",
                ),
                TextSpan(
                  text:"\n$e\n",
                ),
                TextSpan(
                  text:"Click here to log out.",

                  recognizer: TapGestureRecognizer()..onTap = () {
                    FirebaseAuth.instance.signOut();
                  }
                )
              ]
            )
          ),
      ),
    );
  }
}