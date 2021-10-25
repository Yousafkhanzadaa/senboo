import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:senboo/providers/color_provider.dart';
import 'package:senboo/screens/get_start_screen.dart';
import 'package:senboo/screens/main_screen.dart';
import 'package:senboo/services/firebase_auth_services.dart';

class InitialService extends StatefulWidget {
  @override
  _InitialServiceState createState() => _InitialServiceState();
}

class _InitialServiceState extends State<InitialService> {
  bool? signin;
  @override
  void initState() {
    super.initState();
    // Color Provider
    ColorProvider _colorPro =
        Provider.of<ColorProvider>(context, listen: false);
    _colorPro.loadColor();

    _handleSignIn();
    // _createUserInFirestore();
  }

  _handleSignIn() {
    // GoogleSignIn Service -----------------------------
    FirebaseAuthServices firebaseAuthServices =
        Provider.of<FirebaseAuthServices>(context, listen: false);

    firebaseAuthServices.currentStatus!.listen((user) {
      if (user != null) {
        Future.delayed(Duration(milliseconds: 500)).then((value) {
          setState(() {
            signin = true;
          });
        });
      } else {
        setState(() {
          signin = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ColorProvider _colorPref = Provider.of<ColorProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'senboo',
      theme: _themeData(_colorPref.getColorCode),
      home: _checkSignIn(),
    );
  }

  _checkSignIn() {
    if (signin == true) {
      return MainScreen();
    }
    if (signin == false) {
      return GetStartedScreen();
    }
    return _loadingScreen();
  }

  Widget _loadingScreen() {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  // Theme data is here --------------------------------------------------
  ThemeData _themeData(String? colorCode) {
    return ThemeData(
      primaryColor: Color(int.parse(colorCode ?? "0xff000000")),
      // primaryColor: Color(int.parse(colorCode ?? "0xff939597")),
      backgroundColor: Colors.white,
      shadowColor: Colors.black12,
      cardColor: Colors.white,

      //DefaultFontFamily----------------------
      fontFamily: "Lato",

      // Text styling for headlines, title and body
      textTheme: const TextTheme(
        // heading1 -----------------------------------
        headline1: TextStyle(
          fontSize: 24,
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
