import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gamers_kingdom/enums/skills.dart';
import 'package:gamers_kingdom/models/user.dart';
import 'package:gamers_kingdom/util/util.dart';
import 'package:gamers_kingdom/widgets/follower_line.dart';
import 'package:gamers_kingdom/widgets/progress_widget.dart';

class ProfileBySkills extends StatefulWidget {
  final List<Skills> skills;
  const ProfileBySkills({
    super.key,
    required this.skills
  });

  @override
  State<ProfileBySkills> createState() => _ProfileBySkillsState();
}

class _ProfileBySkillsState extends State<ProfileBySkills> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Search profile by Skills"),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
          .collection("users")
          .where("skills", arrayContainsAny: widget.skills.map((e) => Util.skillsToString(e)).toList())
          .snapshots(),
        builder: (context, snapshot) {
          if(!snapshot.hasData){
            return const Center(child: ProgressWidget());
          }
          List<UserProfile> users = snapshot.data!.docs.map((e) => UserProfile.fromFirestore(data: e)).toList();
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index){
              return FollowerLine(user: users[index]);
            }
          );
        }
      ),
    );
  }
}