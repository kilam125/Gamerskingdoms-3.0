
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gamers_kingdom/models/user.dart';
import 'package:gamers_kingdom/widgets/follower_line.dart';
import 'package:gamers_kingdom/widgets/progress_widget.dart';
import 'package:provider/provider.dart';

class FollowersStandalone extends StatefulWidget {
  final Function(int)? navCallback;

  const FollowersStandalone({
    super.key,
    this.navCallback
  });

  @override
  State<FollowersStandalone> createState() => _FollowersStandaloneState();
}

class _FollowersStandaloneState extends State<FollowersStandalone> {
  @override
  Widget build(BuildContext context) {
    UserProfile userProfile = context.read<UserProfile>();
    return Scaffold(
      appBar: AppBar(),
      body: Column(
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
                        height: 50,
                        width: 50,
                        child: ProgressWidget(),
                      );
                    }
                    if(!snapshot.hasData){
                      return const SizedBox(
                        height: 50,
                        width: 50,
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
      ),
    );
  }
}