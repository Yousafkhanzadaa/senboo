import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:senboo/providers/color_provider.dart';
import 'package:senboo/providers/data_provider.dart';
import 'package:senboo/initial.dart';
import 'package:senboo/providers/edit_list_controller.dart';
import 'package:senboo/services/firebase_auth_services.dart';
import 'package:senboo/services/firestore_services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light));
  runApp(Senboo());
}

class Senboo extends StatefulWidget {
  @override
  _SenbooState createState() => _SenbooState();
}

class _SenbooState extends State<Senboo> {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return _buildScreen();
  }

  // App initializer ------------------------------------------
  FutureBuilder _buildScreen() {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        // _inOut();
        // error screen -------------------------------------
        if (snapshot.hasError) {
          return _errorScreen();
        }

        //initialization done-----------------------------------
        if (snapshot.connectionState == ConnectionState.done) {
          return MultiProvider(providers: [
            ChangeNotifierProvider<ColorProvider>(
              create: (_) => ColorProvider(),
            ),
            ChangeNotifierProvider<FirebaseAuthServices>(
              create: (_) => FirebaseAuthServices(),
            ),
            ChangeNotifierProvider<FirestoreServices>(
              create: (_) => FirestoreServices(),
            ),
            ChangeNotifierProvider<DataProvider>(
              create: (_) => DataProvider(),
            ),
            ChangeNotifierProvider<EditListController>(
              create: (_) => EditListController(),
            ),
          ], child: InitialService());
        }

        // loading -----------------------------------
        return _loadingScreen();
      },
    );
  }

  // Error Screen ----------------------------------------------------
  Widget _errorScreen() {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'senboo',
      theme: _themeData("0xff939597"),
      home: Scaffold(
        backgroundColor: Colors.red,
        body: Center(
          child: Text(
            "Something went wrong\nCheck you internet connection",
            style: Theme.of(context)
                .textTheme
                .headline1!
                .copyWith(color: Colors.white70),
          ),
        ),
      ),
    );
  }

  Widget _loadingScreen() {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'senboo',
      theme: _themeData("0xff939597"),
      home: Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).primaryColor,
          ),
        ),
      ),
    );
  }

  // Theme data is here --------------------------------------------------
  ThemeData _themeData(String? colorCode) {
    return ThemeData(
      primaryColor: Color(int.parse(colorCode ?? "0xff939597")),
      backgroundColor: Colors.white,
      cardColor: Colors.white,

      //DefaultFontFamily----------------------
      fontFamily: "Lato",

      // Text styling for headlines, title and body
      textTheme: const TextTheme(
        // heading1 -----------------------------------
        headline1: TextStyle(
          fontSize: 36,
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
        // heading2 -----------------------------------
        headline2: TextStyle(
          fontSize: 24,
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
        // heading3 -----------------------------------
        headline3: TextStyle(
          fontSize: 24,
          color: Color(0xFF3B3B3B),
        ),
        // Subtitle1 -----------------------------------
        subtitle1: TextStyle(
          fontSize: 20,
          color: Color(0xFF3B3B3B),
        ),
        // Subtitle2 -----------------------------------
        subtitle2: TextStyle(
          fontSize: 12,
          color: Colors.white,
        ),
        // bodyText1 -----------------------------------
        bodyText1: TextStyle(
          fontSize: 15,
          color: Color(0xFF616161),
        ),

        // bodyText2 -----------------------------------
        bodyText2: TextStyle(
          fontSize: 12,
          color: Color(0xFF616161),
        ),
      ),
    );
  }
}
