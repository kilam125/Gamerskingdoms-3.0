import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gamers_kingdom/main.dart';
import 'package:gamers_kingdom/models/user.dart';
import 'package:gamers_kingdom/profile.dart';
import 'package:gamers_kingdom/widgets/progress_widget.dart';
import 'package:provider/provider.dart';

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
  int activeIndex = 0;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Object>(
      stream: FirebaseFirestore.instance
        .collection("users")
        .where("email", isEqualTo: widget.email)
        .snapshots(),
      builder: (context, snapshot) {
        if(!snapshot.hasData){
          return const ProgressWidget();
        }
        QuerySnapshot qds = snapshot.data as QuerySnapshot;
        Map userData = (qds.docs.first.data() as Map);
        return ListenableProvider<UserProfile>.value(
          updateShouldNotify:(oldList, currentList) => (currentList != oldList),
          value: UserProfile.fromFirestore(data: qds.docs.first),
          builder: (context, __) {
            UserProfile user = context.watch<UserProfile>();
            return Navigator(
              onGenerateRoute: (settings){
                if(settings.name == Profile.routeName){
                  return MaterialPageRoute(builder: (context){
                    return Profile(user: user);
                  });
                } else {
                  return MaterialPageRoute(builder: (context){
                    return Scaffold(
                      appBar: AppBar(
                      leading: Container(),
                      actions: [
                        Padding(
                          padding: const EdgeInsets.only(right: 16.0),
                          child: GestureDetector(
                            onTap: (){
                              Navigator.of(context, rootNavigator: false).push(
                                MaterialPageRoute(builder: (context){
                                  return Profile(user: user);
                                })
                              );
                            },
                            child: const Icon(
                              Icons.person,
                              size: 30,
                            ),
                          ),
                        )
                      ],
                    ),
                      bottomNavigationBar: BottomNavigationBar(
                        type: BottomNavigationBarType.fixed,
                        currentIndex: activeIndex,
                        elevation: 10,
                        showSelectedLabels: true,
                        onTap: (value) async {
                          setState(() {
                            activeIndex = value;
                          });
                        },
                        items: const [
                          BottomNavigationBarItem(
                            label: "Posts",
                            icon: Icon(Icons.note)
                          ),
                          BottomNavigationBarItem(
                            label: "Add Posts",
                            icon: Icon(Icons.post_add)
                          ),
                          BottomNavigationBarItem(
                            label: "Followers",
                            icon: Icon(Icons.note)
                          ),
                        ],
                      ),
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
                  });
                }
              }
            );
          },
        );
      }
    );
  }
}