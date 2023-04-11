

import 'package:flutter/material.dart';
import 'package:gamers_kingdom/models/user.dart';
import 'package:provider/provider.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({
    super.key,
  });
  static String routeName = "/NotificationPage";
  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    UserProfile using = context.watch<UserProfile>();
    if(using.friendRequest!.isEmpty){
      return const Center(child: Text("No friend request"),);
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Friend request"),
      ),
      body: ListView.builder(
        itemBuilder: (context, index){
          debugPrint("Index $index");
          return Container();
        },
        itemCount: using.friendRequest!.length,
      ),
    );
  }
}