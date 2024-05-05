import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gamers_kingdom/enums/skills.dart';
import 'package:gamers_kingdom/extensions/string_extension.dart';
import 'package:gamers_kingdom/followers_standalone.dart';
import 'package:gamers_kingdom/following_standalone.dart';
import 'package:gamers_kingdom/models/post.dart';
import 'package:gamers_kingdom/models/user.dart';
import 'package:gamers_kingdom/pop_up/pop_up.dart';
import 'package:gamers_kingdom/util/util.dart';
import 'package:gamers_kingdom/widgets/post_widget.dart';
import 'package:gamers_kingdom/widgets/progress_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:provider/provider.dart';

class OtherUserProfileView extends StatefulWidget {
  final UserProfile user;
  final UserProfile me;
  const OtherUserProfileView({
    super.key,
    required this.user,
    required this.me,
  });
  static const String routeName = "/OtherUserProfileView";
  @override
  State<OtherUserProfileView> createState() => _OtherUserProfileViewState();
}

class _OtherUserProfileViewState extends State<OtherUserProfileView> with TickerProviderStateMixin{
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
    controller = TabController(length: 1, vsync: this);
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
    return Scaffold(
      appBar: AppBar(
        actions: [
          GestureDetector(
            onTapDown: (details) async {
              final offset = details.globalPosition;
              // Utiliser PopupMenuButton
              String? value = await showMenu<String>(
                useRootNavigator: false,
                context: context,
                position: RelativeRect.fromLTRB(
                  offset.dx,
                  offset.dy,
                  MediaQuery.of(context).size.width - offset.dx,
                  MediaQuery.of(context).size.height - offset.dy,
                ),
                items: [
                  const PopupMenuItem<String>(
                    value: 'block',
                    child: Text('Block user'),
                  ),
                ],
              );
              // Faire quelque chose avec la valeur retournée
              if (value != null) {
                // ignore: use_build_context_synchronously
                PopUp.yesNoPopUp(
                  context: context, 
                  title: "Wait..", 
                  message: "Are you sure you want to block this user ?", 
                  yesCallBack: () async {
                    await widget.me.blockUser(widget.user);
                    //await using.blockUser(user);
                  }
                );
              }
            },
            child: const Icon(Icons.more_vert, size: 30),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(top:16.0, left: 8, right: 8.0),
        child: StreamBuilder(
          stream: FirebaseFirestore.instance.collection("posts")
            .where("owner", isEqualTo: widget.user.userRef)
            .where("visible", isEqualTo: true)
            .orderBy("datePost", descending: true)
            .snapshots(),
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
                            child: widget.user.picture == null ?
                              Image.asset(
                                "assets/images/userpic.png", 
                                fit: BoxFit.fill,
                                height: 80,
                                width: 80,
                              )
                            :Image.network(
                              widget.user.picture!,
                              fit: BoxFit.fill,
                              height: 80,
                              width: 80,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 25.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  widget.user.displayName.capitalize(),
                                  style: GoogleFonts.lalezar(
                                    fontSize:16,
                                    fontWeight:FontWeight.w400,
                                    color: Theme.of(context).primaryColor,
                                    letterSpacing: 1
                                  )
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        children: [
                          Text(
                            widget.user.bio!,
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
                                      builder: (BuildContext context) => ListenableProvider.value(
                                        value: widget.user,
                                        builder: (context, child) => const FollowersStandalone(),
                                      ),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal :8.0),
                                  child: Column(
                                    children: [
                                      Text(widget.user.followers!.length.toString()),
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
                                      builder: (BuildContext context) => ListenableProvider.value(
                                        value: widget.user,
                                        builder: (context, child) => const FollowingStandalone(),
                                      ),
                                    ),
                                  );
                                },
                                child: Column(
                                  children: [
                                    Text(widget.user.following!.length.toString()),
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
                        widget.user.skills.length, 
                        (index) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Chip(
                            label: Text(
                              Util.skillsToString(widget.user.skills[index]),
                              style: const TextStyle(
                                fontSize: 20
                              ),
                            ),
                          ),
                        )
                      ),
                    ),
                  ),
                  if(!(context.read<UserProfile>().userRef == widget.user.userRef))
                  SliverToBoxAdapter(
                    child:(widget.user.followers!.contains(context.read<UserProfile>().userRef))?
                    GestureDetector(
                      onTap: () async {
                        if(!mounted)return;
                        widget.user.removeFollower(context.read<UserProfile>().userRef);
                        if(!mounted)return;
                        context.read<UserProfile>().removeFollowing(widget.user.userRef);
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
                        debugPrint("Tapped");
                        await UserProfile.createFriendRequest(requester: context.read<UserProfile>().userRef, target: widget.user.userRef);
                        if(!mounted)return;
                        widget.user.addFollower(context.read<UserProfile>().userRef);
                        if(!mounted)return;
                        context.read<UserProfile>().addFollowing(widget.user.userRef);
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
                              "Posts",
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
                  ListView.builder(
                    itemCount: posts.length,
                    itemBuilder: ((context, index) {
                      return Container(
                        margin: const EdgeInsets.all(8.0),
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                          color: Color.fromARGB(255, 211, 213, 216),
                        ),
                        child: PostWidget(
                          latest: index == posts.length-1,
                          post: posts[index], 
                          user: widget.user,
                        )
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
}