import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:gamers_kingdom/add_posts.dart';
import 'package:gamers_kingdom/database_service.dart';
import 'package:gamers_kingdom/enums/attachment_type.dart';
import 'package:gamers_kingdom/enums/skills.dart';
import 'package:gamers_kingdom/extensions/string_extension.dart';
import 'package:gamers_kingdom/filter.dart' as ft;
import 'package:gamers_kingdom/followers.dart';
import 'package:gamers_kingdom/models/filtered_skills.dart';
import 'package:gamers_kingdom/models/post.dart';
import 'package:gamers_kingdom/models/user.dart';
import 'package:gamers_kingdom/notifications_page.dart';
import 'package:gamers_kingdom/page_comments.dart';
import 'package:gamers_kingdom/posts.dart';
import 'package:gamers_kingdom/profile.dart';
import 'package:gamers_kingdom/profile_view.dart';
import 'package:gamers_kingdom/widgets/progress_widget.dart';
import 'package:gamers_kingdom/widgets/video_widget.dart';
import 'package:gamers_kingdom/widgets/voice_note_widget.dart';
import 'package:google_fonts/google_fonts.dart';
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
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  @override
  void initState(){
    super.initState();
  }

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
      Posts(
        navCallback: navCallback, 
      ),
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
            ),
            ChangeNotifierProvider(
              create: (_) => FilteredSkills(),
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
                } else if(settings.name!.contains(NotificationPage.routeName)) {
                  return MaterialPageRoute(
                    settings: RouteSettings(
                      name:NotificationPage.routeName,
                    ),
                    builder: (context) => const NotificationPage()
                  );
                } else if(settings.name!.contains(ft.Filter.routeName)) {
                  return MaterialPageRoute(
                    settings: RouteSettings(
                      name:ft.Filter.routeName,
                    ),
                    builder: (context) => const ft.Filter()
                  );
                } else {
                  return MaterialPageRoute(builder: (context){
                    return Builder(
                      builder: (context) {
                        UserProfile user = context.watch<UserProfile>();
                        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                          var messaging = FirebaseMessaging.instance;
                          messaging.onTokenRefresh.listen((newToken) async {
                            debugPrint("On Token Refresh");
                            //Util.addFcmTokenAfterConnection(newFcmToken: newToken, user: context.read<Client>().getClientRef(), isCoach: false);
                            await context.read<UserProfile>().userRef.set(
                              {
                                "fcmTokens":FieldValue.arrayUnion([newToken]),
                              },
                              SetOptions(merge: true)
                            );
                          });
                          messaging.getToken().then((value) async {
                            debugPrint("Setting token : $value");
                            if(!(context.read<UserProfile>().getFcmTokens.contains(value))){
                              await context.read<UserProfile>().userRef.set(
                                {
                                  "fcmTokens":FieldValue.arrayUnion([value]),
                                },
                                SetOptions(merge: true)
                              );
                            }
                          });
                        });
                        return Scaffold(
                          appBar: AppBar(
                            centerTitle: true,
                            leading: (Provider.of<FilteredSkills>(context).getSkills.isNotEmpty && activeIndex == 0) ? 
                            IconButton(
                              onPressed: (){
                                Provider.of<FilteredSkills>(context, listen: false).resetSkills();
                              }, 
                              icon: const Icon(Icons.filter_alt_off)
                            ) : null,
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
                                      delegate: MySearchDelegate(
                                        selectedPosts: context.read<List<Post>>()
                                      )
                                    );
                                    if (!mounted) return;
                                    FocusManager.instance.primaryFocus!.unfocus();
                                  },
                                ),
                              ),
                              if(activeIndex == 0)
                              Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.tune,
                                    color: Colors.black,
                                    size: 30,
                                  ),
                                  onPressed: () async {
                                    List<Skills> skills = (await Navigator.of(context).pushNamed(ft.Filter.routeName)) as List<Skills>;
                                    // ignore: use_build_context_synchronously
                                    Provider.of<FilteredSkills>(context, listen: false).addSkillsToList(skills);
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

  MySearchDelegate(
    {
      required this.selectedPosts
    }
  );

  @override
  String get searchFieldLabel => 'Rechercher...';

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
    onPressed: () => close(context, null), 
    icon: const Icon(Icons.arrow_back)
  );

  @override
  List<Widget>? buildActions(BuildContext context) => [
    IconButton(
      icon: const Icon(Icons.close),
      onPressed: () {
          if (query.isEmpty) {
            close(context, null);
          } else {
            query = '';
          }
        },
      ),
    ];

  @override
  Widget buildResults(BuildContext context) {
    return Text("sel=$selectedPosts");
  }

  Widget getPictureWidget(String url, BuildContext context){
    return SizedBox(
      height: 300,
      width: MediaQuery.of(context).size.width,
      child: CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.fill,
        height: 300,
        width: MediaQuery.of(context).size.width,
      ),
    );
  }

  Widget getVideoWidget(String url) {
    return SizedBox(
      height: 300,
      width: double.infinity,
      child: VideoWidget(url: url),
    );
  }

  Widget attachementViewByType(AttachmentType attachmentType, String attachmentUrl, BuildContext context){
    if(attachmentType == AttachmentType.picture){
      return getPictureWidget(attachmentUrl, context);
    }
    else if(attachmentType == AttachmentType.video){
      return getVideoWidget(attachmentUrl);
    } else {
      return VoiceNoteWidget(url: attachmentUrl);
    }
  }
  
  double heightByAttachmentType(AttachmentType? attachmentType){
    if(attachmentType == AttachmentType.picture){
      return 400;
    }
    else if(attachmentType == AttachmentType.video){
      return 650;
    } else {
      return 300;
    }
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<Post> filteredList = selectedPosts.where((element) => element.userName.toLowerCase().contains(query.toLowerCase())).toList();
    UserProfile using = context.watch<UserProfile>();
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: ListView.builder(
        itemBuilder: (context, index){
          debugPrint("Index $index");
          Post post = filteredList[index];
          return Container(
            constraints: BoxConstraints(
              minHeight:heightByAttachmentType(post.attachmentType),
            ),
            width: 375,
            margin: const EdgeInsets.all(16.0),
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 223, 222, 222),
              borderRadius: BorderRadius.all(Radius.circular(10))
            ),
            child: StreamBuilder(
              stream: post.owner.get().asStream(),
              builder: (context, ownerSnapshot) {
                if(ownerSnapshot.data == null){
                  return const SizedBox(
                    height: 300,
                    width: 300,
                    child: Center(child: ProgressWidget())
                  );
                }
                UserProfile user = UserProfile.fromFirestore(data:  ownerSnapshot.data!);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          flex: 2,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
                            clipBehavior: Clip.antiAlias,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle
                            ),
                            child: user.picture == null ?
                              ClipRRect(
                                borderRadius: BorderRadius.circular(30),
                                child: Image.asset(
                                  "assets/images/userpic.png", 
                                  fit: BoxFit.fill,
                                  height: 30,
                                  width: 30,
                                ),
                              )
                              :ClipRRect(
                              borderRadius: BorderRadius.circular(30),
                              child: Image.network(
                                user.picture!,
                                fit: BoxFit.fill,
                                height: 30,
                                width: 30,
                              ),
                            ),
                          ),
                        ),
                        Flexible(
                          flex: 6,
                          child: GestureDetector(
                            onTap: (){
                              Navigator.of(context).pushNamed(
                                ProfileView.routeName,
                                arguments: {
                                  "user":user,
                                  "ownUser":false
                                }
                              );
                            },
                            child: Text(
                              user.displayName.capitalize(),
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ),
                        ),
                        Flexible(
                          flex: 2,
                          fit: FlexFit.tight,
                          child: Container(color: Colors.green)
                        )
                      ],
                    ),
                    if(post.attachmentType != null && post.attachmentUrl != null)
                    attachementViewByType(post.attachmentType!, post.attachmentUrl!, context),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () async { 
                            if(!post.likers.contains(using.userRef)){
                              await post.addLike(using.userRef);
                            } else {
                              await post.removeLike(using.userRef);
                            }
                          }, 
                          icon: Icon(
                            Icons.star_outline_sharp,
                            color: post.likers.contains(using.userRef) ? Colors.blue : Colors.black,
                            size: 30,
                          )
                        ),
                        IconButton(
                          onPressed: () async {
                            Navigator.pushNamed(
                              context, 
                              PageComments.routeName,
                              arguments: {
                                "index":index,
                                "userProfile":user
                              }
                            );
                          }, 
                          icon: const Icon(
                            Icons.add_comment,
                            size: 28,
                          )
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        "${post.likes} likes",
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(post.content!),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: GestureDetector(
                        onTap: (){
                          Navigator.of(context).pushNamed(
                            PageComments.routeName,
                            arguments: {
                              "index":index,
                              "userProfile":user
                            }
                          );
                        },
                        child: Text(
                          "Check ${post.comments.length} comments",
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: const Color.fromARGB(255, 62, 62, 62),
                            decoration: TextDecoration.underline
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }
            ),
          );
        },
        // itemCount: context.watch<List<Post>>().length,
        itemCount: filteredList.length,
      )
    );
  }
}