import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:gamers_kingdom/dashboard.dart';
import 'package:gamers_kingdom/firebase_options.dart';
import 'package:gamers_kingdom/login_page.dart';
import 'package:gamers_kingdom/models/user.dart';
import 'package:gamers_kingdom/profile_view.dart';
import 'package:gamers_kingdom/sign_up.dart';
import 'package:google_fonts/google_fonts.dart';


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


Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint("Handling a background message");
/*   FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );
  flutterLocalNotificationsPlugin.initialize(initializationSettings);
  debugPrint(message.toString());
  showNotification(message.data, flutterLocalNotificationsPlugin); */
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});


  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  Future<void> settingsPermissions() async{
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

  @override
  void initState() {
    super.initState();
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/launcher_icon');
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
    settingsPermissions();
    FirebaseMessaging.instance.getInitialMessage().then((message) {
        debugPrint('Message clicked!');
      });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Handle foreground messages
      debugPrint('Received message: ${message.notification?.body}');
      showNotification(message.notification!.toMap(), flutterLocalNotificationsPlugin);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      // Handle background and terminated app messages
      debugPrint('Opened app from notification: ${message.notification?.body}');
      debugPrint('Data: ${message.data}');
      if(message.data["route"] == ProfileView.routeName){
        DocumentSnapshot doc = await FirebaseFirestore.instance.collection("users").doc(message.data["userId"]).get();
/*         Navigator.of(context).pushNamed(
          ProfileView.routeName,
          arguments: {
            "user":UserProfile.fromFirestore(data: doc)
          }
        ); */
        Navigator.of(
          context, 
          rootNavigator: false
        ).push(
          MaterialPageRoute(builder: (context){
            return ProfileView(user: UserProfile.fromFirestore(data: doc));
          })
        );
      }
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

    FirebaseAuth.instance.authStateChanges().listen((user) {
      bool result = user != null;
      debugPrint("InListening : ${result?"/Dashboard":"/LoginPage"}");
      if (result) {
        debugPrint("Checking mail validation");
        if (user.emailVerified) {
          debugPrint("Mail already verified");
          _navigatorKey.currentState!.pushReplacementNamed(
            Dashboard.routeName,
            arguments: {
              "email":user.email
            }
          );
        }
      } else {
        debugPrint("Not Authenticated");
/*         _navigatorKey.currentState!.pushReplacementNamed(
          HomePage.routeName,
        ); */
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Map<int, Color> blackMap = {
      50: const Color(0xFFFFD7C2),
      100: const Color.fromARGB(255, 0, 0, 0),
      200: const Color.fromARGB(255, 0, 0, 0),
      300: const Color.fromARGB(255, 0, 0, 0),
      400: const Color.fromARGB(255, 0, 0, 0),
      500: const Color.fromARGB(255, 0, 0, 0),
      600: const Color.fromARGB(255, 0, 0, 0),
      700: const Color.fromARGB(255, 0, 0, 0),
      800: const Color.fromARGB(255, 0, 0, 0),
      900: const Color.fromARGB(255, 0, 0, 0),
    };
    final MaterialColor blackSwatch = MaterialColor(const Color.fromARGB(255, 0, 0, 0).value, blackMap);

    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: 'Gamers Kingdoms',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: blackSwatch,
        primaryColor: const Color.fromARGB(255, 0, 0, 0),
        appBarTheme: AppBarTheme(
          color: Colors.white,
          iconTheme: const IconThemeData(color: Colors.black),
          actionsIconTheme: const IconThemeData(color: Colors.black),
          titleTextStyle: GoogleFonts.lalezar(
              fontSize:30,
              fontWeight:FontWeight.w400,
              color: Colors.black,
              letterSpacing: 1
            ),
        ),
        iconTheme: const IconThemeData(
          color:  Color.fromARGB(255, 0, 0, 0),
          size: 15
        ),
        iconButtonTheme: IconButtonThemeData(
          style: ButtonStyle(
            padding: MaterialStateProperty.resolveWith((states) {
              if (states.contains(MaterialState.hovered)) {
                return const EdgeInsets.all(8.0);
              }
              return const EdgeInsets.all(8.0);
            })
          )
        ),
        secondaryHeaderColor:  const Color.fromARGB(181, 203, 45, 45),
        hintColor:  const Color.fromARGB(23, 82, 81, 81),
        focusColor: const Color.fromARGB(53, 145, 145, 145),
        checkboxTheme: CheckboxThemeData(
          splashRadius: 0,
          side: BorderSide(color: Theme.of(context).focusColor),
          fillColor: MaterialStateProperty.resolveWith((states) {
            // If the button is pressed, return green, otherwise blue
            if (states.contains(MaterialState.pressed)) {
              return Theme.of(context).primaryColor.withOpacity(.5);
            }
            return Theme.of(context).primaryColor;
          })
        ),
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
            textStyle: MaterialStateProperty.resolveWith((states) {
              if (states.contains(MaterialState.hovered)) {
                return GoogleFonts.poppins(
                  fontSize:20,
                  fontWeight:FontWeight.w400,
                  color: Theme.of(context).primaryColor,
                  letterSpacing: 1
                );
              }
              return GoogleFonts.poppins(
                fontSize: 14,
                fontWeight:FontWeight.w400,
                color: Theme.of(context).primaryColor,
                letterSpacing: 1
              );
            }),
            overlayColor: MaterialStateProperty.resolveWith<Color?>(
              (Set<MaterialState> states) {
                if (states.contains(MaterialState.hovered)) {
                  return Colors.black.withOpacity(0.04);
                }
                if (states.contains(MaterialState.focused) ||
                    states.contains(MaterialState.pressed)) {
                  return Colors.black.withOpacity(0.12);
                }
                return null; // Defer to the widget's default.
              },
            ),
          )
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith((states) {
              // If the button is pressed, return green, otherwise blue
              if (states.contains(MaterialState.pressed)) {
                return Theme.of(context).primaryColor.withOpacity(.5);
              }
              return Theme.of(context).primaryColor;
            }),
            textStyle: MaterialStateProperty.resolveWith((states) {
              if (states.contains(MaterialState.hovered)) {
                return GoogleFonts.lalezar(
                  fontSize:30,
                  fontWeight:FontWeight.w100,
                  color: Theme.of(context).primaryColor,
                  letterSpacing: 1
                );
              }
              return GoogleFonts.lalezar(
                fontSize:20,
                fontWeight:FontWeight.w100,
                color: Theme.of(context).primaryColor,
                letterSpacing: 1
              );
            })
          )
        ),
        inputDecorationTheme: InputDecorationTheme(
          alignLabelWithHint: true,
          filled: true,
          fillColor: Theme.of(context).focusColor,
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Color(0x00000000)),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Color(0x00000000)),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6),
        ),
        textTheme: TextTheme(
          titleLarge: GoogleFonts.lalezar(
            fontSize:35,
            fontWeight:FontWeight.w400,
            color: Colors.black,
            letterSpacing: 1
          ),
          titleMedium: GoogleFonts.lalezar(
            fontSize:20,
            height: 1,
            fontWeight:FontWeight.w400,
            color: Colors.black,
            letterSpacing: 1
          ),
          titleSmall: GoogleFonts.lalezar(
            fontSize: 16,
            fontWeight:FontWeight.w400,
            color: Colors.black,
            letterSpacing: 1
          ),
          headlineSmall: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).hintColor
          ),
          headlineMedium: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).hintColor
          ),
          displaySmall: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).hintColor
          ),
          labelSmall: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            letterSpacing: 1,
            color: Theme.of(context).primaryColor
          ),
        )
      ),
      initialRoute:FirebaseAuth.instance.currentUser == null ? HomePage.routeName : Dashboard.routeName,
      onGenerateRoute: (settings){
        debugPrint("Name : ${settings.name}");
        if(settings.name!.contains(SignUp.routeName)){
          return MaterialPageRoute(
            settings: RouteSettings(
              name:SignUp.routeName,
            ),
            builder: (context) => const SignUp()
          );
        } else if(settings.name!.contains(Dashboard.routeName)) {
          return MaterialPageRoute(
            settings: RouteSettings(
              name:Dashboard.routeName,
            ),
            builder: (context) => Dashboard(
              email: FirebaseAuth.instance.currentUser!.email!,
            )
          );
        } else if(settings.name!.contains(HomePage.routeName)){
          return MaterialPageRoute(
            settings: RouteSettings(
              name:HomePage.routeName,
            ),
            builder: (context) => const HomePage()
          );
        }
        return null;
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  static String routeName = "/HomePage";
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    debugPrint("Routename : HomePage");
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          child: Column(
            children: [
              Flexible(
                flex: 3,
                child: Image.asset("assets/icon/main_logo_transparent.png")
              ),
              Flexible(
                flex: 7,
                child: LoginPage(
                  parentContext:context
                )
              ),
            ],
          ),
        ),
      ),
    );
  }
}
