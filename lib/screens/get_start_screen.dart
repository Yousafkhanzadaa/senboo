import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:senboo/services/firebase_auth_services.dart';

class GetStartedScreen extends StatefulWidget {
  const GetStartedScreen({Key? key}) : super(key: key);

  @override
  _GetStartedScreenState createState() => _GetStartedScreenState();
}

class _GetStartedScreenState extends State<GetStartedScreen> {
  bool agreed = false;

  @override
  void initState() {
    super.initState();
    // setupInteractedMessage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).primaryColor.withOpacity(0.40),
              blurRadius: 5,
              offset: Offset(0, 0),
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          children: [
            _logoContainer(),
            SizedBox(
              height: 10,
            ),
            _appName(),
            SizedBox(height: 60),
            Expanded(
                child: Column(
              children: [
                _quote(),
              ],
            )),
            // _termsContitions(),
            _getStartedButton(),
            SizedBox(
              height: 50,
            ),
          ],
        ),
      ),
    );
  }

  // Logo conainer --------------------------------------------
  Widget _logoContainer() {
    return Container(
      height: 100,
      width: 100,
      child: Image(
        image: AssetImage("assets/images/logo.png"),
      ),
    );
  }

  // app name and slogan --------------------------------------------
  Widget _appName() {
    return Column(
      children: [
        Text(
          "Senboo".toUpperCase(),
          style: Theme.of(context)
              .textTheme
              .headline3!
              .copyWith(fontWeight: FontWeight.w700),
        ),
        Text(
          "Share your Imagination",
          style: Theme.of(context).textTheme.bodyText1!.copyWith(
                fontSize: 16,
                color: Theme.of(context).primaryColor,
                // fontWeight: FontWeight.w700,
              ),
        )
      ],
    );
  }

  // Quote --------------------------------------------
  Widget _quote() {
    return Text(
      '“You can’t fail if you don’t quit. You can’t succeed if you don’t start.” — Michael Hyatt',
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodyText1!.copyWith(
            fontSize: 22,
            color: Theme.of(context).primaryColor,
            // fontWeight: FontWeight.w700,
          ),
    );
  }

  // GetStarted Button ----------------------------------------------------
  Widget _getStartedButton() {
    return Consumer<FirebaseAuthServices>(builder: (context, auth, child) {
      return ElevatedButton(
        onPressed: () async {
          _showLoading();
          await auth.signIn().whenComplete(() {
            Navigator.pop(context);
          });

          // auth.loadSignIn();
        },
        style: ButtonStyle(
            backgroundColor:
                MaterialStateProperty.all(Theme.of(context).primaryColor),
            shadowColor:
                MaterialStateProperty.all(Theme.of(context).primaryColor),
            padding: MaterialStateProperty.all(
                EdgeInsets.symmetric(vertical: 15, horizontal: 55)),
            shape: MaterialStateProperty.all(RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(35)))),
        child: Text(
          "Get Started".toUpperCase(),
          style: Theme.of(context).textTheme.subtitle2,
        ),
      );
    });
  }

  _showLoading() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width * 70,
            height: 200,
            decoration: _cardDecoration(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                    height: 100,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage("assets/images/svgs/loading.png")),
                    )),
                SizedBox(
                  height: 5,
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 9.0, horizontal: 60),
                  child: LinearProgressIndicator(
                    color: Theme.of(context).primaryColor,
                    minHeight: 2,
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  // CardDecoration --------------------------------------
  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(15),
      boxShadow: [
        BoxShadow(
          color: Theme.of(context).primaryColor.withOpacity(0.40),
          blurRadius: 3,
          offset: Offset(0, 0),
        ),
      ],
    );
  }
}
