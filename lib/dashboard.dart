import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gamers_kingdom/add_posts.dart';
import 'package:gamers_kingdom/database_service.dart';
import 'package:gamers_kingdom/models/user.dart';
import 'package:gamers_kingdom/posts.dart';
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

  List<Widget> pages = const [
    Posts(),
    AddPosts(),
    AddPosts(),
  ];

  titleByIndex(activeIndex){
    switch(activeIndex){
      case 0:
        return "Posts";
      case 1:
        return "Add Post";
      case 2:
        return "Followers";
    }
  }

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
        return StreamProvider<UserProfile>.value(
          updateShouldNotify:(oldList, currentList) => (currentList != oldList),
          initialData: UserProfile.fromFirestore(data: qds.docs.first),
          value: DatabaseService.streamUser(qds.docs.first.id),
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
                    return Builder(
                      builder: (context) {
                        UserProfile user = context.watch<UserProfile>();
                        return Scaffold(
                          appBar: AppBar(
                            centerTitle: true,
                            leading: null,
                            title: Text(
                              titleByIndex(activeIndex)
                            ),
                            actions: [
                              Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.search, 
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                  onPressed: (){},
                                ),
                              ),
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
                                icon: Icon(Icons.group)
                              ),
                            ],
                          ),
                          body: pages[activeIndex],
                        );
                      }
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