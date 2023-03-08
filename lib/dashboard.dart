import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gamers_kingdom/main.dart';
import 'package:gamers_kingdom/widgets/progress_widget.dart';

class Dashboard extends StatefulWidget {
  final String email;
  const Dashboard({
    required this.email,
    super.key
  });
  static String routeName = "/Dashboard";
  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Object>(
      stream: FirebaseFirestore.instance.collection("users").where("email", isEqualTo: widget.email).snapshots(),
      builder: (context, snapshot) {
        if(!snapshot.hasData){
          return const ProgressWidget();
        }
        QuerySnapshot qds = snapshot.data as QuerySnapshot;
        Map userData = (qds.docs.first.data() as Map);
        return Scaffold(
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Your are logged as : ${userData["displayName"]}"),
              ElevatedButton(
                onPressed: (){
                  Navigator.of(context).popAndPushNamed(HomePage.routeName);
                  FirebaseAuth.instance.signOut();
                }, 
                child: const Text("Logout")
              )
            ],
          ),
        );
      }
    );
  }
}