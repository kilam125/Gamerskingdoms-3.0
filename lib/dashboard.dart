
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gamers_kingdom/database_service.dart';
import 'package:gamers_kingdom/enums/attachment_type.dart';
import 'package:gamers_kingdom/extensions/string_extension.dart';
import 'package:gamers_kingdom/filter.dart' as ft;
import 'package:gamers_kingdom/home.dart';
import 'package:gamers_kingdom/main.dart';
import 'package:gamers_kingdom/models/filtered_skills.dart';
import 'package:gamers_kingdom/models/post.dart';
import 'package:gamers_kingdom/models/user.dart';
import 'package:gamers_kingdom/notifications_page.dart';
import 'package:gamers_kingdom/other_user_profile_view.dart';
import 'package:gamers_kingdom/page_comments.dart';
import 'package:gamers_kingdom/profile.dart';
import 'package:gamers_kingdom/own_profile_view.dart';
import 'package:gamers_kingdom/unknown_route.dart';
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
  int activeIndex = 0;

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
    Map? mp = (ModalRoute.of(context)!.settings.arguments as Map?);
    if(mp != null && mp["route"] != null){
      navigatorKey.currentState!.pushNamed(
        OwnProfileView.routeName,
/*         arguments: {
          "user":UserProfile.fromFirestore(data: doc)
        } */
      );
    }
    
    return WillPopScope(
      onWillPop: (){
        return Future.value(false);
      },
      child: StreamBuilder<Object>(
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
                catchError: (context, error){
                  debugPrint("Logout");
                  return const [];
                },
              ),
              ChangeNotifierProvider(
                create: (_) => FilteredSkills(),
              )
            ],
            builder: (context, __) {
              UserProfile user = context.watch<UserProfile>();
              return Navigator(
                //key: secondNavigatorKey,
                onUnknownRoute: (settings) => MaterialPageRoute(
                  settings: RouteSettings(
                    name:UnknownRoute.routeName,
                  ),
                  builder: (context) => const UnknownRoute()
                ),
                onGenerateRoute: (settings){
                  if(settings.name == Profile.routeName){
                    return MaterialPageRoute(builder: (context){
                      return Profile(user: user);
                    });
                  }  else if(settings.name!.contains(OwnProfileView.routeName)){
                    return MaterialPageRoute(
                      settings: const RouteSettings(
                        name:OwnProfileView.routeName,
                      ),
                      builder: (context) => OwnProfileView(
                        user: (settings.arguments as Map)["user"],
                        ownUser: (settings.arguments as Map)["ownUser"] ?? false,
                      )
                    );
                  } else if(settings.name!.contains(OtherUserProfileView.routeName)){
                    return MaterialPageRoute(
                      settings: const RouteSettings(
                        name:OtherUserProfileView.routeName,
                      ),
                      builder: (context) => OtherUserProfileView(
                        user: (settings.arguments as Map)["user"],
                      )
                    );
                  }
                  else if(settings.name!.contains(PageComments.routeName)){
                    return MaterialPageRoute(
                      settings: RouteSettings(
                        name:PageComments.routeName,
                      ),
                      builder: (context) => PageComments(
                        postRef: (settings.arguments as Map)["postRef"],
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
                      return const Home();
                    });
                  }
                }
              );
            },
          );
        }
      ),
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
      List<Post> filteredList = selectedPosts.where((element) => element.userName.toLowerCase().contains(query.toLowerCase())).toList();
      UserProfile using = context.watch<UserProfile>();
      return SizedBox(
        height: MediaQuery.of(context).size.height,
        child: ListView.builder(
          itemBuilder: (context, index) {
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
                                  OwnProfileView.routeName,
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
                                  "userProfile":user,
                                  "postRef":post.postRef,
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
                                "postRef":post.postRef,
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
          itemCount: filteredList.length,
        ),
      );
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
                                OwnProfileView.routeName,
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
                                "userProfile":user,
                                "postRef":post.postRef,
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
                              "postRef":post.postRef,
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