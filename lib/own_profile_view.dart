import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:gamers_kingdom/delete_entry.dart';
import 'package:gamers_kingdom/enums/skills.dart';
import 'package:gamers_kingdom/extensions/string_extension.dart';
import 'package:gamers_kingdom/followers_standalone.dart';
import 'package:gamers_kingdom/following_standalone.dart';
import 'package:gamers_kingdom/models/post.dart';
import 'package:gamers_kingdom/models/user.dart';
import 'package:gamers_kingdom/profile.dart';
import 'package:gamers_kingdom/util/util.dart';
import 'package:gamers_kingdom/widgets/post_widget.dart';
import 'package:gamers_kingdom/widgets/progress_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:provider/provider.dart';

class OwnProfileView extends StatefulWidget {
  final UserProfile user;
  final bool ownUser;
  const OwnProfileView({
    super.key,
    required this.user,
    this.ownUser = false
  });
  static const String routeName = "/ProfileView";
  @override
  State<OwnProfileView> createState() => _OwnProfileViewState();
}

class _OwnProfileViewState extends State<OwnProfileView> with TickerProviderStateMixin{
  TextEditingController displayName = TextEditingController();
  TextEditingController bio = TextEditingController();
  List<Skills> skills = List.generate(Skills.values.length, (index) => Skills.values[index]);
  List<Skills> selectedSkills = [];
  late final List<MultiSelectItem<Skills>> items;
  bool isLoading = false;
  bool isLoadingButton = false;
  late TabController controller;
  @override
  void initState() {
    super.initState();
    controller = TabController(length: 2, vsync: this);
    displayName.text = widget.user.displayName;
    debugPrint("Selected Skills ${selectedSkills.toString()}");
    debugPrint("User Skills ${widget.user.skills.toString()}");
    selectedSkills  = widget.user.skills;
    items = skills
      .map((skill) => MultiSelectItem<Skills>(skill, Util.skillsToString(skill)))
      .toList();
    if(widget.user.bio != null){
      bio.text = widget.user.bio!;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    UserProfile user = context.watch<UserProfile>();
    return Scaffold(
      appBar: AppBar(
        actions: [
          if(widget.ownUser)
          IconButton(
            onPressed: (){
              Navigator.of(
                context, 
                rootNavigator: false
              ).push(
                MaterialPageRoute(builder: (context){
                  return Profile(user: user);
                })
              );
            }, 
            icon: const Icon(Icons.edit)
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(top:16.0, left: 8, right: 8.0),
        child: FutureBuilder(
          future: FirebaseFirestore.instance.collection("posts")
            .where("owner", isEqualTo: user.userRef)
            .where("visible", isEqualTo: true)
            .orderBy("datePost", descending: true)
            .get(),
          builder: (context, snapshot) {
            if(!snapshot.hasData){
              return const Center(child: ProgressWidget());
            }
            List<Post> posts = snapshot.data!.docs.map((e) => Post.fromFirestore(data: e)).toList();
            return NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverToBoxAdapter(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            clipBehavior: Clip.antiAlias,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle
                            ),
                            child: user.picture == null ?
                              Image.asset(
                                "assets/images/userpic.png", 
                                fit: BoxFit.fill,
                                height: 50,
                                width: 50,
                              )
                            :Image.network(
                              user.picture!,
                              fit: BoxFit.fill,
                              height: 50,
                              width: 50,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              user.displayName.capitalize(),
                              style: GoogleFonts.lalezar(
                                fontSize:16,
                                fontWeight:FontWeight.w400,
                                color: Theme.of(context).primaryColor,
                                letterSpacing: 1
                              )
                            ),
                          ),
                        ],
                      )
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            user.bio!,
                            style: const TextStyle(
                              fontSize: 16
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              GestureDetector(
                                onTap: (){
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (BuildContext context) => ListenableProvider(
                                        create: (context) => Provider.of<UserProfile>(context, listen: false),
                                        builder: (context, child) => const FollowersStandalone(),
                                      ),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal :8.0),
                                  child: Column(
                                    children: [
                                      Text(user.followers!.length.toString()),
                                      Text(
                                        "Followers",
                                        style: Theme.of(context).textTheme.titleSmall,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: (){
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (BuildContext context) => ListenableProvider(
                                        create: (context) => Provider.of<UserProfile>(context, listen: false),
                                        builder: (context, child) => const FollowingStandalone(),
                                      ),
                                    ),
                                  );
                                },
                                child: Column(
                                  children: [
                                    Text(user.following!.length.toString()),
                                    Text(
                                      "Following",
                                      style: Theme.of(context).textTheme.titleSmall,
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Wrap(
                      children: List.generate(
                        user.skills.length, 
                        (index) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Chip(
                            label: Text(
                              Util.skillsToString(user.skills[index]),
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        )
                      ),
                    ),
                  ),
                  if(!(context.read<UserProfile>().userRef == user.userRef))
                  SliverToBoxAdapter(
                    child:(user.followers!.contains(context.read<UserProfile>().userRef))?
                    GestureDetector(
                      onTap: () async {
                        if(!mounted)return;
                        user.removeFollower(context.read<UserProfile>().userRef);
                        if(!mounted)return;
                        context.read<UserProfile>().removeFollowing(user.userRef);
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(Icons.check),
                          ),
                          Text("Followed")
                        ],
                      ),
                    ) :
                    ElevatedButton(
                      child: const Text("Follow"),
                      onPressed: () async {
                        await UserProfile.createFriendRequest(requester: context.read<UserProfile>().userRef, target: user.userRef);
                        if(!mounted)return;
                        user.addFollower(context.read<UserProfile>().userRef);
                        if(!mounted)return;
                        context.read<UserProfile>().addFollowing(user.userRef);
                      },
                    )
                  ),
                  const SliverToBoxAdapter(
                    child: Divider(color: Colors.grey, thickness: 1.0,),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TabBar(
                        indicatorColor: Colors.cyan,
                        controller: controller,
                        tabs: [
                          GestureDetector(
                            onTap: (){
                              controller.animateTo(0);
                            },
                            child: Text(
                              "Following Posts",
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ),
                          GestureDetector(
                            onTap: (){
                              controller.animateTo(1);
                            },
                            child: Text(
                              widget.ownUser ?
                              "My Posts (${posts.length})" : "Posts",
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ),
                        ],
                      ),
                    )
                  ),
                ];
              },
              body: TabBarView(
                controller: controller,
                children: [
                  user.following!.isNotEmpty ? 
                  StreamBuilder(
                    stream: FirebaseFirestore.instance
                      .collection("posts")
                      .where("owner", whereIn: user.following)
                      .where("visible", isEqualTo: true)
                      .orderBy("datePost", descending: true)
                      .snapshots(),
                    builder: (context, snapshot) {
                      debugPrint("User following : ${user.following}");
                      if(!snapshot.hasData){
                        return const ProgressWidget();
                      }
                      if(snapshot.data!.docs.isEmpty){
                        return const Center(child: Text("No post from following"));
                      }
                      List<Post> followingPost = snapshot.data!.docs.map((e) => Post.fromFirestore(data: e)).toList();
                      return ListView.builder(
                        itemCount: followingPost.length,
                        itemBuilder: ((context, index) {
                          Post ps = followingPost[index];
                          return Container(
                            margin: const EdgeInsets.all(8.0),
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(8.0)),
                              color: Color.fromARGB(255, 211, 213, 216),
                            ),
                            child: StreamBuilder(
                              stream: ps.owner.get().asStream(),
                              builder: (context, ownerSnapshot) {
                                if(!ownerSnapshot.hasData){
                                  return const ProgressWidget();
                                }
                                UserProfile owner = UserProfile.fromFirestore(data:  ownerSnapshot.data!);
                                return PostWidget(
                                  latest: index == 0,
                                  post: ps, 
                                  user: owner,
                                  moi: user
                                );
                              }
                            )
                          );
                          }
                        )
                      );
                    }
                  ) : const Center(child: Text("No post from following")),
                  ListView.builder(
                    itemCount: posts.length,
                    itemBuilder: ((context, index) {
                      return Slidable(
                        key: UniqueKey(),
                        groupTag: 'group', // All slidables share the same groupTag now
                        endActionPane: ActionPane(
                          extentRatio: 0.40,
                          motion: const ScrollMotion(),
                          children: [
                            Builder(
                              builder: (builderContext) {
                                return GestureDetector(
                                  onTap: () async {
                                    // Callback délenchant l'exception
                                    Slidable.of(builderContext)!.dismiss(
                                      ResizeRequest(
                                        const Duration(milliseconds: 50), 
                                        () { }
                                      )
                                    );
                                    await deletePost(posts[index]);
                                  },
                                  child: const DeleteEntryButton(),
                              );
                            }
                          ),
                        ],
                        ),
                        child: Container(
                          margin: const EdgeInsets.all(8.0),
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(8.0)),
                            color: Color.fromARGB(255, 211, 213, 216),
                          ),
                          child: PostWidget(
                            latest: index == 0,
                            post: posts[index], 
                            user: user,
                            moi: user
                          )
                        ),
                      );
                      }
                    )
                  ),
                ],
              ),
            );
          }
        ),
      ),
    );
  }
  Future<void> deletePost(Post post){
    return showDialog(
      context: context, 
      builder: (context){
        return AlertDialog(
          title: const Text("Delete Post"),
          content: const Text("Are you sure you want to delete this post?"),
          actions: [
            TextButton(
              onPressed: (){
                Navigator.of(context).pop();
              }, 
              child: const Text("Cancel")
            ),
            TextButton(
              onPressed: () async {
                await post.postRef.delete();
                Navigator.of(context).pop();
              }, 
              child: const Text("Delete")
            ),
          ],
        );
      }
    );
  }
}