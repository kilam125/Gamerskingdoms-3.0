import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gamers_kingdom/enums/skills.dart';
import 'package:gamers_kingdom/extensions/string_extension.dart';
import 'package:gamers_kingdom/models/post.dart';
import 'package:gamers_kingdom/models/user.dart';
import 'package:gamers_kingdom/profile.dart';
import 'package:gamers_kingdom/util/util.dart';
import 'package:gamers_kingdom/widgets/post_widget.dart';
import 'package:gamers_kingdom/widgets/progress_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:provider/provider.dart';

class ProfileViewStandalone extends StatefulWidget {
  final UserProfile followerData;
  final UserProfile recipientData;
  final bool ownUser;
  const ProfileViewStandalone({
    super.key,
    required this.followerData,
    required this.recipientData,
    this.ownUser = false
  });
  static const String routeName = "/ProfileView";
  @override
  State<ProfileViewStandalone> createState() => _ProfileViewStandaloneState();
}

class _ProfileViewStandaloneState extends State<ProfileViewStandalone> {
  TextEditingController displayName = TextEditingController();
  TextEditingController bio = TextEditingController();
  List<Skills> skills = List.generate(Skills.values.length, (index) => Skills.values[index]);
  List<Skills> selectedSkills = [];
  late final List<MultiSelectItem<Skills>> items;
  bool isLoading = false;
  bool isLoadingButton = false;
  @override
  void initState() {
    super.initState();
    displayName.text = widget.followerData.displayName;
    debugPrint("Selected Skills ${selectedSkills.toString()}");
    debugPrint("User Skills ${widget.followerData.skills.toString()}");
    selectedSkills  = widget.followerData.skills;
    items = skills
      .map((skill) => MultiSelectItem<Skills>(skill, Util.skillsToString(skill)))
      .toList();
    if(widget.followerData.bio != null){
      bio.text = widget.followerData.bio!;
    }
  }
  
  @override
  Widget build(BuildContext context) {
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
                  return Profile(user: widget.followerData);
                })
              );
            }, 
            icon: const Icon(Icons.edit)
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(top:16.0, left: 8, right: 8.0),
        child: StreamBuilder(
          stream: FirebaseFirestore.instance.collection("posts")
            .where("owner", isEqualTo: widget.followerData.userRef)
            .where("visible", isEqualTo: true)
            //.orderBy("datePost", descending: true)
            .snapshots(),
          builder: (context, snapshot) {
            if(!snapshot.hasData){
              return const Center(child: ProgressWidget());
            }
            List<Post> posts = snapshot.data!.docs.map((e) => Post.fromFirestore(data: e)).toList();
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          clipBehavior: Clip.antiAlias,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle
                          ),
                          child: widget.followerData.picture == null ?
                            Image.asset(
                              "assets/images/userpic.png", 
                              fit: BoxFit.fill,
                              height: 50,
                              width: 50,
                            )
                          :Image.network(
                            widget.followerData.picture!,
                            fit: BoxFit.fill,
                            height: 50,
                            width: 50,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                widget.followerData.displayName.capitalize(),
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.followerData.bio!,
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
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal :8.0),
                                child: Column(
                                  children: [
                                    Text(widget.followerData.followers!.length.toString()),
                                    Text(
                                      "Followers",
                                      style: Theme.of(context).textTheme.titleSmall,
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  Text(widget.followerData.following!.length.toString()),
                                  Text(
                                    "Following",
                                    style: Theme.of(context).textTheme.titleSmall,
                                  ),
                                ],
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
                      widget.followerData.skills.length, 
                      (index) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Chip(
                          label: Text(Util.skillsToString(widget.followerData.skills[index])),
                        ),
                      )
                    ),
                  ),
                ),
                if(!(widget.recipientData.userRef == widget.followerData.userRef))
                SliverToBoxAdapter(
                  child:(widget.followerData.followers!.contains(widget.recipientData.userRef))?
                  GestureDetector(
                    onTap: () async {
                      if(!mounted)return;
                      widget.followerData.removeFollower(widget.recipientData.userRef);
                      if(!mounted)return;
                      widget.recipientData.removeFollowing(widget.followerData.userRef);
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
                      await UserProfile.createFriendRequest(requester: widget.recipientData.userRef, target: widget.followerData.userRef);
                      if(!mounted)return;
                      widget.followerData.addFollower(widget.recipientData.userRef);
                      if(!mounted)return;
                      widget.recipientData.addFollowing(widget.followerData.userRef);
                    },
                  )
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        const Divider(color: Colors.grey, thickness: 1.0,),
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Posts (${posts.length})",
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                ),
                SliverList(
                  delegate: SliverChildListDelegate(
                    List.generate(
                      posts.length, 
                      (index) => GestureDetector(
                        onTap: (){},
                        child: Container(
                          margin: const EdgeInsets.all(8.0),
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(8.0)),
                            color: Color.fromARGB(255, 211, 213, 216),
                          ),
                          child: StreamProvider.value(
                            initialData: widget.recipientData,
                            value: UserProfile.streamUser(widget.recipientData.userRef),
                            builder: (context, child) {
                              return PostWidget(
                                latest: index == posts.length-1,
                                post: posts[index], 
                                user: widget.followerData,
                              );
                            }
                          )
                        ),
                      )
                    )
                  )
                ),
              ],
            );
          }
        ),
      ),
    );
  }
}