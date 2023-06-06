import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:gamers_kingdom/main.dart';
import 'package:gamers_kingdom/models/user.dart';
import 'package:gamers_kingdom/profile_view.dart';
import 'package:gamers_kingdom/sign_up.dart';

  Future<void> showNotification(Map<String, dynamic> messageData, FlutterLocalNotificationsPlugin fl) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

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
      if(route == ProfileView.routeName){
        //DocumentSnapshot doc = await FirebaseFirestore.instance.collection("users").doc(message.data["userId"]).get();
        navigatorKey.currentState!.pushNamed(
          SignUp.routeName,
          arguments: {
            //"user":UserProfile.fromFirestore(data: doc)
          }
        );
      }
    } else {
      FirebaseCrashlytics.instance.log("[NOTIF][handleMessage] Message is null");
      debugPrint("[NOTIF][handleMessage] Message is null");
    }
  }

  Future<void> handleMessageInBck(RemoteMessage? message) async {
    debugPrint("[NOTIF] In handleMessageInBck");
    FirebaseCrashlytics.instance.log("[NOTIF][handleMessageInFr] in handleMessageInBck");
    if(message != null){
      final String route = message.data["route"];
      debugPrint("Route : $route");
      if(route == ProfileView.routeName){
        //DocumentSnapshot doc = await FirebaseFirestore.instance.collection("users").doc(message.data["userId"]).get();
        navigatorKey.currentState!.pushNamed(
          SignUp.routeName,
          arguments: {
            //"user":UserProfile.fromFirestore(data: doc)
          }
        );
      }
    } else {
      FirebaseCrashlytics.instance.log("[NOTIF][handleMessageInBck] Message is null");
      debugPrint("[NOTIF][handleMessageInBck] Message is null");
    }
  }

  Future<void> handleMessageInFr(RemoteMessage? message) async {
    debugPrint("[NOTIF] In handleMessageInFr");
    FirebaseCrashlytics.instance.log("[NOTIF][handleMessageInFr] in handleMessageInFr");
    if(message != null){
      final String route = message.data["route"];
      debugPrint("Route : $route");
      if(route == ProfileView.routeName){
        //DocumentSnapshot doc = await FirebaseFirestore.instance.collection("users").doc(message.data["userId"]).get();
        navigatorKey.currentState!.pushNamed(
          SignUp.routeName,
          arguments: {
            //"user":UserProfile.fromFirestore(data: doc)
          }
        );
      }
    } else {
      FirebaseCrashlytics.instance.log("[NOTIF][handleMessageInFr] Message is null");
      debugPrint("[NOTIF][handleMessageInFr] Message is null");
    }
  }

  Future initPushNotifications(FlutterLocalNotificationsPlugin fl) async {
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true, // Required to display a heads up notification
      badge: true,
      sound: true,
    );
    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
    FirebaseMessaging.onBackgroundMessage(handleMessageInBck);
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessageInFr);
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
      const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
      );
      flutterLocalNotificationsPlugin.initialize(initializationSettings);
      logging(settings.authorizationStatus);
      initPushNotifications(flutterLocalNotificationsPlugin);
    }
  }