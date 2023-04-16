import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gamers_kingdom/add_posts.dart';
import 'package:gamers_kingdom/database_service.dart';
import 'package:gamers_kingdom/followers.dart';
import 'package:gamers_kingdom/models/post.dart';
import 'package:gamers_kingdom/models/user.dart';
import 'package:gamers_kingdom/notifications_page.dart';
import 'package:gamers_kingdom/page_comments.dart';
import 'package:gamers_kingdom/posts.dart';
import 'package:gamers_kingdom/profile.dart';
import 'package:gamers_kingdom/profile_view.dart';
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
  final globalKey = GlobalKey(debugLabel: 'btm_app_bar');
  int activeIndex = 0;

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
    navCallback(int index){
      setState(() {
        activeIndex = index;
      });
    }

    List<Widget> pages = [
      Posts(navCallback: navCallback),
      AddPosts(navCallback: navCallback),
      Followers(navCallback: navCallback),
    ];

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
        return MultiProvider(
          providers: [
            StreamProvider<UserProfile>.value(
              updateShouldNotify:(oldList, currentList) {
                debugPrint("Updating");
                return (currentList != oldList);
              },
              initialData: UserProfile.fromFirestore(data: qds.docs.first),
              value: DatabaseService.streamUser(qds.docs.first.id),
            ),
            StreamProvider<List<Post>>.value(
              value:Post.streamAllPosts(),
              updateShouldNotify:(oldList,currentList) => (currentList!=oldList),
              initialData: const [],
            )
          ],
          builder: (context, __) {
            UserProfile user = context.watch<UserProfile>();
            return Navigator(
              onGenerateRoute: (settings){
                if(settings.name == Profile.routeName){
                  return MaterialPageRoute(builder: (context){
                    return Profile(user: user);
                  });
                }  else if(settings.name!.contains(ProfileView.routeName)){
                  return MaterialPageRoute(
                    settings: const RouteSettings(
                      name:ProfileView.routeName,
                    ),
                    builder: (context) => ProfileView(
                      user: (settings.arguments as Map)["user"],
                      ownUser: (settings.arguments as Map)["ownUser"],
                    )
                  );
                } else if(settings.name!.contains(PageComments.routeName)){
                  return MaterialPageRoute(
                    settings: RouteSettings(
                      name:PageComments.routeName,
                    ),
                    builder: (context) => PageComments(
                      index: (settings.arguments as Map)["index"],
                      userProfile: (settings.arguments as Map)["userProfile"],
                    )
                  );
                }  else if(settings.name!.contains(NotificationPage.routeName)) {
                  return MaterialPageRoute(
                    settings: RouteSettings(
                      name:NotificationPage.routeName,
                    ),
                    builder: (context) => const NotificationPage()
                  );
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
                              if(activeIndex == 0)
                              Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.search,
                                    color: Colors.black,
                                    size: 30,
                                  ),
                                  onPressed: () async {
                                    await showSearch(
                                      context: context, 
                                      delegate: MySearchDelegate(selectedPosts: context.read<List<Post>>())
                                    );
                                    if (!mounted) return;
                                    FocusManager.instance.primaryFocus!.unfocus();
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 16.0),
                                child: GestureDetector(
                                  onTap: (){
                                    Navigator.of(context).pushNamed(
                                      ProfileView.routeName,
                                      arguments: {
                                        "user":user,
                                        "ownUser":true
                                      }
                                    );
                                  },
                                  child: const Icon(
                                    Icons.person,
                                    size: 30,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          bottomNavigationBar: BottomNavigationBar(
                            key: globalKey,
                            type: BottomNavigationBarType.fixed,
                            currentIndex: activeIndex,
                            elevation: 10,
                            showSelectedLabels: true,
                            onTap: (value) async {
                              navCallback(value);
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

class MySearchDelegate extends SearchDelegate {
  List<Post> selectedPosts;
  //final bool Function(List<Post>) filter;

  MySearchDelegate(
    {
      required this.selectedPosts
    }
  );

  @override
  String get searchFieldLabel => 'Rechercher...';

  @override
  Widget? buildLeading(BuildContext context) =>
  IconButton(
    onPressed: () => close(context, null), 
    icon: const Icon(Icons.arrow_back)
  );

  @override
  List<Widget>? buildActions(BuildContext context) => [
    IconButton(
      onPressed: () {
        if (query.isEmpty) {
          close(context, null);
        } else {
          query = '';
        }
      },
      icon: const Icon(Icons.close))
    ];

  @override
  Widget buildResults(BuildContext context) {
    return Text("sel=$selectedPosts");
    //MessageLine(pool: selectedPool!);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
/*     QuerySnapshot s = await FirebaseFirestore.instance.collection("users").where("displayName",isEqualTo: query).get();
    List<DocumentReference> docRefList = s.docs.map((e) => e.reference).toList();
    debugPrint("Query : $query");
    List filteredList = selectedPosts.where((element) => docRefList.contains(element.owner)).toList(); */
    return ListView.builder(
      itemCount: 0,
      itemBuilder: (context, i) {
        return GestureDetector(
          onTap: () {
/*             selectedPool = pools[i];
            query = pools[i].name;
            showResults(context); */
          },
          child:Text(""),
        );
      });
  }
}