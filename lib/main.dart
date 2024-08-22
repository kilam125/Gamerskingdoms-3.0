import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gamers_kingdom/api/firebase_push.dart';
import 'package:gamers_kingdom/dashboard.dart';
import 'package:gamers_kingdom/firebase_options.dart';
import 'package:gamers_kingdom/login_page.dart';
import 'package:gamers_kingdom/sign_up.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebasePush().initNotifications();
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});


  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();
    try {
      FirebaseAuth.instance.authStateChanges().listen((user) {
        bool result = user != null;
        debugPrint("InListening : ${result?"/Dashboard":"/LoginPage"}");
        if (result) {
          debugPrint("Checking mail validation");
          if (user.emailVerified) {
            debugPrint("Mail already verified");
            navigatorKey.currentState!.pushReplacementNamed(
              Dashboard.routeName,
              arguments: {
                "email":user.email
              }
            );
          }
        } else {
          debugPrint("Not Authenticated");
          navigatorKey.currentState!.pushReplacementNamed(
            HomePage.routeName,
            arguments: {}
          );
        }
      });
    } catch (e) {
      debugPrint("Error : $e");
    }
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
      title: 'Gamers Kingdoms',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      theme: ThemeData(
        useMaterial3: false,
        primarySwatch: blackSwatch,
        primaryColor: const Color.fromARGB(255, 0, 0, 0),
        appBarTheme: AppBarTheme(
          color: Colors.white,
          iconTheme: const IconThemeData(color: Colors.black),
          actionsIconTheme: const IconThemeData(color: Colors.black),
          titleTextStyle: GoogleFonts.lalezar(
              fontSize:28,
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
            backgroundColor: WidgetStateProperty.resolveWith((states) {
              // If the button is pressed, return green, otherwise blue
              if (states.contains(WidgetState.pressed)) {
                return Theme.of(context).primaryColor.withOpacity(.5);
              }
              return Theme.of(context).primaryColor;
            }),
            textStyle: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.hovered)) {
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
      onUnknownRoute: (settings) => MaterialPageRoute(
        settings: RouteSettings(
          name:HomePage.routeName,
        ),
        builder: (context) => const HomePage()
      ),
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
              arguments: settings.arguments
            ),
            builder: (context) => Dashboard(
              email: FirebaseAuth.instance.currentUser!.email!,
            )
          );
        } else {
          return MaterialPageRoute(
            settings: RouteSettings(
              name:HomePage.routeName,
            ),
            builder: (context) => const HomePage()
          );
        }
/*         if(FirebaseAuth.instance.currentUser == null) {
          return MaterialPageRoute(
            settings: RouteSettings(
              name:HomePage.routeName,
            ),
            builder: (context) => const HomePage()
          );
        } else {
          return MaterialPageRoute(
            settings: RouteSettings(
              name:Dashboard.routeName,
              arguments: settings.arguments
            ),
            builder: (context) => Dashboard(
              email: FirebaseAuth.instance.currentUser!.email!,
            )
          );
        } */
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
    if(FirebaseAuth.instance.currentUser != null){
      return Dashboard(
        email: FirebaseAuth.instance.currentUser!.email!,
      );
    } else {
      return WillPopScope(
        onWillPop: (){
          return Future.value(false);
        },
        child: Scaffold(
          body: SingleChildScrollView(
            child: Container(
              height: MediaQuery.of(context).size.height,
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
              child: Column(
                children: [
                  if(kDebugMode)
                  const Flexible(
                    flex:3,
                    child: Text("On unkown route", style: TextStyle(fontSize: 50),)
                  ),
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
        ),
      );
    }
  }
}
