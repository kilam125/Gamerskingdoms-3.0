import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint("Handling a background message from home");
/*   FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );
  flutterLocalNotificationsPlugin.initialize(initializationSettings);
  debugPrint(message.toString());
  showNotification(message.data, flutterLocalNotificationsPlugin); */
}

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
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  Future<void> settingsPermissions() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      debugPrint('User granted provisional permission');
    } else {
      debugPrint('User declined or has not accepted permission');
    }
    // Get any messages which caused the application to open from
    // a terminated state.
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true, // Required to display a heads up notification
      badge: true,
      sound: true,
    );
  }

  Future<void> setupInteractedMessage() async {
    // Get any messages which caused the application to open from
    // a terminated state.
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    // If the message also contains a data property with a "type" of "chat",
    // navigate to a chat screen
    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }

    // Also handle any interaction when the app is in the background via a
    // Stream listener
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }
  
  void _handleMessage(RemoteMessage message) async {
    if(message.data["route"] == ProfileView.routeName){
      DocumentSnapshot doc = await FirebaseFirestore.instance.collection("users").doc(message.data["userId"]).get();
      Navigator.of(context).pushNamed(
        ProfileView.routeName,
        arguments: {
          "user":UserProfile.fromFirestore(data: doc)
        }
      );
    }
  }

  @override
  void initState(){
    super.initState();
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/launcher_icon');
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
    settingsPermissions();
    setupInteractedMessage();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Handle foreground messages
      debugPrint('Received message: ${message.notification?.body}');
      showNotification(message.notification!.toMap(), flutterLocalNotificationsPlugin);
    });

    if(!kIsWeb){
      if(Platform.isIOS)
      {
        FirebaseMessaging.onBackgroundMessage((message) async {
          debugPrint("Background Message received ${message.data.toString()}");
        });
      } else if (Platform.isAndroid){
        FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
      }
    }
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
      Posts(
        navCallback: navCallback, 
      ),
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
        leading: (Provider.of<FilteredSkills>(context).getSkills.isNotEmpty && activeIndex == 0) ? 
        IconButton(
          onPressed: (){
            Provider.of<FilteredSkills>(context, listen: false).resetSkills();
          }, 
          icon: const Icon(Icons.filter_alt_off)
        ) : null,
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