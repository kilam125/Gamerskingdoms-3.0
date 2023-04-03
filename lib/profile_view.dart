import 'package:flutter/material.dart';
import 'package:gamers_kingdom/enums/skills.dart';
import 'package:gamers_kingdom/extensions/string_extension.dart';
import 'package:gamers_kingdom/models/user.dart';
import 'package:gamers_kingdom/util/util.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';

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
        padding: const EdgeInsets.only(top:16.0),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
                child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle
                ),
                child: widget.user.picture == null ?
                  Image.asset(
                    "assets/images/userpic.png", 
                    fit: BoxFit.fill,
                    height: 200,
                    width: 200,
                  )
                :Image.network(
                  widget.user.picture!,
                  fit: BoxFit.fill,
                  height: 200,
                  width: 200,
                ),
              )
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.user.displayName.capitalize(),
                      style: GoogleFonts.lalezar(
                        fontSize:30,
                        fontWeight:FontWeight.w400,
                        color: Theme.of(context).primaryColor,
                        letterSpacing: 1
                      )
                    ),
                  ],
                ),
              )
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(widget.user.followers!.length.toString()),
                        Text(
                          "Following",
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ],
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
              ),
            ), 
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Posts",
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ],
                ),
              )
            ),
          ],
        ),
      ),
    );
  }
}