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

class ProfileView extends StatefulWidget {
  final UserProfile user;
  final bool ownUser;
  const ProfileView({
    super.key,
    required this.user,
    this.ownUser = false
  });
  static const String routeName = "/ProfileView";
  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final formKey = GlobalKey<FormState>();
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
          if(widget.ownUser)
          IconButton(
            onPressed: (){
              Navigator.of(
                context, 
                rootNavigator: false
              ).push(
                MaterialPageRoute(builder: (context){
                  return Profile(user: widget.user);
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
            .where("owner", isEqualTo: widget.user.userRef)
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
                          child: widget.user.picture == null ?
                            Image.asset(
                              "assets/images/userpic.png", 
                              fit: BoxFit.fill,
                              height: 50,
                              width: 50,
                            )
                          :Image.network(
                            widget.user.picture!,
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
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
                              Padding(
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
                              Column(
                                children: [
                                  Text(widget.user.following!.length.toString()),
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
                      widget.user.skills.length, 
                      (index) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Chip(
                          label: Text(Util.skillsToString(widget.user.skills[index])),
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
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
                      await UserProfile.createFriendRequest(requester: context.read<UserProfile>().userRef, target: widget.user.userRef);
                      if(!mounted)return;
                      widget.user.addFollower(context.read<UserProfile>().userRef);
                      if(!mounted)return;
                      context.read<UserProfile>().addFollowing(widget.user.userRef);
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
                          child: PostWidget(
                            post: posts[index], 
                            user: widget.user,
                            index: index,
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