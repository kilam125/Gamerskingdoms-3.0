import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:gamers_kingdom/comment_view_standalone.dart';
import 'package:gamers_kingdom/main.dart';
import 'package:gamers_kingdom/models/comment.dart';
import 'package:gamers_kingdom/models/post.dart';
import 'package:gamers_kingdom/models/user.dart';
import 'package:gamers_kingdom/post_view_owner_standalone.dart';
import 'package:gamers_kingdom/own_profile_view.dart';
import 'package:gamers_kingdom/profile_view_standalone.dart';

  Future<void> showNotification(Map<String, dynamic> messageData, FlutterLocalNotificationsPlugin fl) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      importance: Importance.max,
      priority: Priority.high,
    );
    const DarwinNotificationDetails darwinInitSettings =
      DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true
      );

    NotificationDetails platformChannelSpecifics =
      NotificationDetails(
        android: Platform.isAndroid ? androidPlatformChannelSpecifics : null,
        iOS: Platform.isIOS ? darwinInitSettings : null
      );

    await fl.show(
      0,
      messageData['title'],
      messageData['body'],
      platformChannelSpecifics,
      payload: messageData['data'],
    );
  }

  void logging(AuthorizationStatus authorizationStatus){
    if (authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted permission');
    } else if (authorizationStatus == AuthorizationStatus.provisional) {
      debugPrint('User granted provisional permission');
    } else {
      debugPrint('User declined or has not accepted permission');
    }
  }

  Future<void> handleMessage(RemoteMessage? message) async {
    debugPrint("[NOTIF] In HANDLE MESSAGE");
    FirebaseCrashlytics.instance.log("[NOTIF] in handleMessage");

    if(message != null){
      final String route = message.data["route"];
      debugPrint("Route : $route");
      if(route == OwnProfileView.routeName){
        DocumentSnapshot followerDoc = await FirebaseFirestore.instance.collection("users").doc(message.data["userId"]).get();
        DocumentSnapshot recipientDoc = await FirebaseFirestore.instance.collection("users").doc(message.data["recipientId"]).get();
        navigatorKey.currentState!.push(
          MaterialPageRoute(
            settings: RouteSettings(
              name:ProfileViewStandalone.routeName,
              arguments: {
                "route":message.data
              }
            ),
            builder: (context) => ProfileViewStandalone(
              followerData : UserProfile.fromFirestore(data: followerDoc),
              recipientData : UserProfile.fromFirestore(data: recipientDoc)
            )
          )
        );
      } else if(route == PostViewOwnerStandalone.routeName) {
        Post post = Post.fromFirestore(data: await FirebaseFirestore.instance.collection("posts").doc(message.data["postId"]).get());
        DocumentSnapshot followerDoc = await FirebaseFirestore.instance.collection("users").doc(message.data["userId"]).get();
        navigatorKey.currentState!.push(
          MaterialPageRoute(
            settings: RouteSettings(
              name:PostViewOwnerStandalone.routeName,
              arguments: {
                "route":message.data
              }
            ),
            builder: (context) => PostViewOwnerStandalone(
              post: post,
              viewer: UserProfile.fromFirestore(data: followerDoc),
            )
          )
        );
      } else if(route == CommentViewStandalone.routeName) {
        Post post = Post.fromFirestore(data: await FirebaseFirestore.instance.collection("posts").doc(message.data["postId"]).get());
        Comment comment = Comment.fromFirestore(doc: await FirebaseFirestore.instance.collection("comments").doc(message.data["commentId"]).get());
        navigatorKey.currentState!.push(
          MaterialPageRoute(
            settings: RouteSettings(
              name:CommentViewStandalone.routeName,
              arguments: {
                "route":message.data
              }
            ),
            builder: (context) => CommentViewStandalone(
              post: post,
              comment: comment,
            )
          )
        );
      } else {
        DocumentSnapshot followerDoc = await FirebaseFirestore.instance.collection("users").doc(message.data["userId"]).get();
        DocumentSnapshot recipientDoc = await FirebaseFirestore.instance.collection("users").doc(message.data["recipientId"]).get();
        navigatorKey.currentState!.push(
          MaterialPageRoute(
            settings: RouteSettings(
              name:ProfileViewStandalone.routeName,
              arguments: {
                "route":message.data
              }
            ),
            builder: (context) => ProfileViewStandalone(
              followerData : UserProfile.fromFirestore(data: followerDoc),
              recipientData : UserProfile.fromFirestore(data: recipientDoc)
            )
          )
        );
      }
    } else {
      FirebaseCrashlytics.instance.log("[NOTIF][handleMessage] Message is null");
      debugPrint("[NOTIF][handleMessage] Message is null");
    }
  }

  Future initPushNotifications(FlutterLocalNotificationsPlugin fl) async {
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true, // Required to display a heads up notification
      badge: true,
      sound: true,
    );
    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
    FirebaseMessaging.onBackgroundMessage(handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
/*     FirebaseMessaging.onMessage.listen((message) {
      showNotification(message.notification!.toMap(), fl);
    }); */
  }

  class FirebasePush {
    final _firebaseMessaging = FirebaseMessaging.instance;
    Future<void> initNotifications() async {
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
      const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/launcher_icon');
      const DarwinInitializationSettings ios = DarwinInitializationSettings(requestAlertPermission: true, requestBadgePermission: true, defaultPresentBadge: true);
      const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: ios
      );
      flutterLocalNotificationsPlugin.initialize(initializationSettings);
      logging(settings.authorizationStatus);
      initPushNotifications(flutterLocalNotificationsPlugin);
    }
  }