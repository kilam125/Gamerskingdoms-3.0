

import 'package:flutter/material.dart';
import 'package:gamers_kingdom/extensions/string_extension.dart';
import 'package:gamers_kingdom/models/user.dart';
import 'package:gamers_kingdom/other_user_profile_view.dart';
import 'package:provider/provider.dart';

class FollowerLine extends StatelessWidget {
  final UserProfile user;
  const FollowerLine({
    super.key,
    required this.user
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: (){
        Navigator.of(context).pushNamed(
          OtherUserProfileView.routeName,
          arguments: {
            "user":user,
            "me": context.read<UserProfile>()
          }
        );
      },
      leading: user.picture == null ?
        ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Image.asset(
            "assets/images/userpic.png", 
            fit: BoxFit.fill,
            height: 50,
            width: 50,
          ),
        )
        :ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Image.network(
          user.picture!,
          fit: BoxFit.fill,
          height: 50,
          width: 50,
        ),
      ),
      title: Text(
        user.displayName.capitalize(),
        style: Theme.of(context).textTheme.titleSmall,
      ),
    );
  }
}