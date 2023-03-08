import 'package:flutter/material.dart';
import 'package:gamers_kingdom/login_page.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gamers Kingdom Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: const Color.fromRGBO(68, 129, 235, 1),
        iconTheme: const IconThemeData(
          color:  Color.fromRGBO(68, 129, 235, 1),
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
            foregroundColor: MaterialStateProperty.all<Color>(Colors.blue),
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
                  return Colors.blue.withOpacity(0.04);
                }
                if (states.contains(MaterialState.focused) ||
                    states.contains(MaterialState.pressed)) {
                  return Colors.blue.withOpacity(0.12);
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
          contentPadding: const EdgeInsets.symmetric(horizontal: 12.0),
        ),
        textTheme: TextTheme(
          titleLarge: GoogleFonts.lalezar(
            fontSize:35,
            fontWeight:FontWeight.w400,
            color: Theme.of(context).primaryColor,
            letterSpacing: 1
          ),
          titleMedium: GoogleFonts.lalezar(
            fontSize:20,
            fontWeight:FontWeight.w400,
            color: Theme.of(context).primaryColor,
            letterSpacing: 1
          ),
          titleSmall: GoogleFonts.lalezar(
            fontSize:16,
            fontWeight:FontWeight.w400,
            color: Theme.of(context).primaryColor,
            letterSpacing: 1
          ),
          headlineSmall: GoogleFonts.poppins(
            fontSize: 16,
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
      home: const HomePage(),
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
    return const Scaffold(
      body: LoginPage(),
    );
  }
}
