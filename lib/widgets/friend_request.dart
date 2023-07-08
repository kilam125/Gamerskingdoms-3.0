import 'package:flutter/material.dart';
import 'package:gamers_kingdom/models/user.dart';

class FriendRequestWidget extends StatelessWidget {
  final UserProfile user;
  const FriendRequestWidget({
    super.key,
    required this.user
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: user.picture == null ?
        ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Image.asset(
            "assets/images/userpic.png", 
            fit: BoxFit.fill,
            height: 30,
            width: 30,
          ),
        )
        :ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Image.network(
          user.picture!,
          fit: BoxFit.fill,
          height: 30,
          width: 30,
        ),
      ),
      title: Text(user.displayName),
      trailing: const Row(),
    );
  }
}