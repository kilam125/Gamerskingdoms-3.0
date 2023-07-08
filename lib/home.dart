import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:gamers_kingdom/dashboard.dart';
import 'package:gamers_kingdom/models/user.dart';
import 'package:gamers_kingdom/posts.dart';
import 'package:gamers_kingdom/profile_view.dart';
import 'package:provider/provider.dart';
import 'package:gamers_kingdom/filter.dart' as ft;

import 'add_posts.dart';
import 'enums/skills.dart';
import 'followers.dart';
import 'models/filtered_skills.dart';
import 'models/post.dart';

class Home extends StatefulWidget {
  const Home({super.key});
  static String routeName = "/Home";
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final formKey = GlobalKey<FormState>();
  final globalKey = GlobalKey(debugLabel: 'btm_app_bar');
  int activeIndex = 0;

  @override
  void initState(){
    super.initState();
  }

  titleByIndex(activeIndex){
    switch(activeIndex){
      case 0:
        return "Posts";
      case 1:
        return "Add Post";
      case 2:
        return "Followers";
    }
  }

  @override
  Widget build(BuildContext context) {
    navCallback(int index){
      setState(() {
        activeIndex = index;
      });
    }

    List<Widget> pages = [
      Posts(navCallback: navCallback),
      AddPosts(navCallback: navCallback),
      Followers(navCallback: navCallback),
    ];

    UserProfile user = context.watch<UserProfile>();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      var messaging = FirebaseMessaging.instance;
      messaging.onTokenRefresh.listen((newToken) async {
        debugPrint("On Token Refresh");
        //Util.addFcmTokenAfterConnection(newFcmToken: newToken, user: context.read<Client>().getClientRef(), isCoach: false);
        await context.read<UserProfile>().userRef.set(
          {
            "fcmTokens":FieldValue.arrayUnion([newToken]),
          },
          SetOptions(merge: true)
        );
      });
      messaging.getToken().then((value) async {
        debugPrint("Setting token : $value");
        if(!(context.read<UserProfile>().getFcmTokens.contains(value))){
          await context.read<UserProfile>().userRef.set(
            {
              "fcmTokens":FieldValue.arrayUnion([value]),
            },
            SetOptions(merge: true)
          );
        }
      });
    });

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: Row(
          children: [
            if(Provider.of<FilteredSkills>(context).getSkills.isNotEmpty && activeIndex == 0)
            IconButton(
              onPressed: (){
                Provider.of<FilteredSkills>(context, listen: false).resetSkills();
              }, 
              icon: const Icon(Icons.filter_alt_off)
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12.0),
              child: Image.asset(
                "assets/icon/main_logo_transparent.png",
                width: 30,
              ),
            )
          ],
        ),
        title: Text(
          titleByIndex(activeIndex)
        ),
        actions: [
          if(activeIndex == 0)
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: const Icon(
                Icons.search,
                color: Colors.black,
                size: 30,
              ),
              onPressed: () async {
                await showSearch(
                  context: context, 
                  delegate: MySearchDelegate(
                    selectedPosts: context.read<List<Post>>()
                  )
                );
                if (!mounted) return;
                FocusManager.instance.primaryFocus!.unfocus();
              },
            ),
          ),
          if(activeIndex == 0)
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: const Icon(
                Icons.tune,
                color: Colors.black,
                size: 30,
              ),
              onPressed: () async {
                List<Skills> skills = (await Navigator.of(context).pushNamed(ft.Filter.routeName)) as List<Skills>;
                // ignore: use_build_context_synchronously
                Provider.of<FilteredSkills>(context, listen: false).addSkillsToList(skills);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: (){
                Navigator.of(context).pushNamed(
                  ProfileView.routeName,
                  arguments: {
                    "user":user,
                    "ownUser":true
                  }
                );
              },
              child: const Icon(
                Icons.person,
                size: 30,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        key: globalKey,
        type: BottomNavigationBarType.fixed,
        currentIndex: activeIndex,
        elevation: 10,
        showSelectedLabels: true,
        onTap: (value) async {
          navCallback(value);
        },
        items: const [
          BottomNavigationBarItem(
            label: "Posts",
            icon: Icon(Icons.note)
          ),
          BottomNavigationBarItem(
            label: "Add Posts",
            icon: Icon(Icons.post_add)
          ),
          BottomNavigationBarItem(
            label: "Followers",
            icon: Icon(Icons.group)
          ),
        ],
      ),
      body: pages[activeIndex],
    );
  }
}