
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gamers_kingdom/models/user.dart';
import 'package:gamers_kingdom/widgets/follower_line.dart';
import 'package:gamers_kingdom/widgets/progress_widget.dart';
import 'package:provider/provider.dart';

class Followers extends StatefulWidget {
  final Function(int) navCallback;

  const Followers({
    super.key,
    required this.navCallback
  });

  @override
  State<Followers> createState() => _FollowersState();
}

class _FollowersState extends State<Followers> {
  @override
  Widget build(BuildContext context) {
    UserProfile userProfile = context.watch<UserProfile>();
    if(userProfile.followers == null || userProfile.followers!.isEmpty) {
      return const Center(
        child: Text("You have no followers"),
      );
    }
    return Column(
      children: [
        Flexible(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Followers : ${userProfile.followers!.length}",
              style: Theme.of(context).textTheme.titleSmall,
            ),
          )
        ),
        Flexible(
          flex: 8,
          child: ListView.separated(
            separatorBuilder: (
              BuildContext context, 
              int index
            ) => const Divider(
              thickness: 1, 
              color: Colors.grey
            ),
            itemBuilder: (context, index){
              return StreamBuilder(
                stream: (userProfile.followers![index] as DocumentReference).snapshots(),
                builder: (context, snapshot) {
                  if(userProfile.followers == null){
                    return const SizedBox(
                      height: 30,
                      width: 30,
                      child: ProgressWidget(),
                    );
                  }
                  if(!snapshot.hasData){
                    return const SizedBox(
                      height: 30,
                      width: 30,
                      child: ProgressWidget(),
                    );
                  }
                  return FollowerLine(user: UserProfile.fromFirestore(data: snapshot.data!),);
                }
              );
            },
            itemCount: userProfile.followers!.length,
          ),
        ),
      ],
    );
  }
}