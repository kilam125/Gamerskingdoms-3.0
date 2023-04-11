import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gamers_kingdom/enums/skills.dart';
import 'package:gamers_kingdom/extensions/string_extension.dart';
import 'package:gamers_kingdom/models/post.dart';
import 'package:gamers_kingdom/models/user.dart';
import 'package:gamers_kingdom/pop_up/pop_up.dart';
import 'package:gamers_kingdom/util/util.dart';
import 'package:gamers_kingdom/widgets/post_widget.dart';
import 'package:gamers_kingdom/widgets/progress_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:provider/provider.dart';

class ProfileView extends StatefulWidget {
  final UserProfile user;
  const ProfileView({
    super.key,
    required this.user
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
      appBar: AppBar(),
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
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal :8.0),
                                child: Column(
                                  children: [
                                    Text(widget.user.followers!.length.toString()),
                                    Text(
                                      "Following",
                                      style: Theme.of(context).textTheme.titleSmall,
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  Text(widget.user.following!.length.toString()),
                                  Text(
                                    "Followers",
                                    style: Theme.of(context).textTheme.titleSmall,
                                  ),
                                ],
                              )
                            ],
                          ),
                        )
                      ],
                    )
                ),
                SliverToBoxAdapter(
                  child: Text(
                    widget.user.bio!
                  ),
                ),
                if(!(context.read<UserProfile>().userRef == widget.user.userRef))
                SliverToBoxAdapter(
                  child: context.read<UserProfile>().followers!.contains(widget.user.userRef)?
                  Row(
                    children: const [
                      Icon(Icons.check),
                      Text("Followed")
                    ],
                  ) :
                  StreamBuilder(
                    stream: FirebaseFirestore.instance.collection("friendRequest")
                      .where("target",isEqualTo: widget.user.userRef)
                      .where("requester",isEqualTo: context.read<UserProfile>().userRef)
                      .snapshots(),
                    builder: (context, snapshot) {
                      if(!snapshot.hasData){
                        return const SizedBox(
                          height: 30,
                          width: 30,
                          child: ProgressWidget(),
                        );
                      }
                      if(snapshot.data!.docs.isNotEmpty){
                        return TextButton(
                          child: const Text("Pending invitation"),
                          onPressed: () async {
                            PopUp.yesNoPopUp(
                              context: context, 
                              title: "Wait...", 
                              message: "Are you sure you want to cancel your invitation ?", 
                              yesCallBack: () async {
                                await snapshot.data!.docs.first.reference.delete();
                              }
                            );
                          },
                        );
                      }
                      return ElevatedButton(
                        child: const Text("Follow"),
                        onPressed: () async {
                          DocumentReference friendRequest = await UserProfile.createFriendRequest(requester: context.read<UserProfile>().userRef, target: widget.user.userRef);
                          widget.user.setFriendRequest(friendRequest);
                          if(!mounted)return;
                          context.read<UserProfile>().setFriendRequest(friendRequest);
                        },
                      );
                    }
                  ),
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
                          child: PostWidget(post: posts[index], user: widget.user)
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