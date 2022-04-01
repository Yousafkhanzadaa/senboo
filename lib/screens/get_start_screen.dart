// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
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
      // appBar: AppBar(
      //   backgroundColor: Theme.of(context).primaryColor,
      //   elevation: 0,
      // ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: double.infinity,
        // padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        color: Theme.of(context).cardColor,
        child: Stack(
          children: [
            logoFade(),
            _logoContainer(),
            _overlay(),
          ],
        ),
      ),
    );
  }

  Widget logoFade() {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: SvgPicture.asset(
        'assets/images/svgs/logo_fade.svg',
        color: Colors.black12,
      ),
    );
  }

  Widget _overlay() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.35,
        padding: EdgeInsets.symmetric(
          vertical: 20,
          horizontal: 20,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).primaryColor.withOpacity(0.40),
              blurRadius: 3,
              offset: Offset(0, 0),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              "Log In or Sign Up",
              style: Theme.of(context)
                  .textTheme
                  .subtitle2!
                  .copyWith(color: Colors.black87, fontSize: 16),
            ),
            Spacer(),
            _getStartedButton(),
            Spacer(),
            Text(
              "Senboo",
              style: Theme.of(context).textTheme.bodyText1!.copyWith(
                    fontSize: 16,
                    color: Theme.of(context).primaryColor,
                    // fontWeight: FontWeight.w700,
                  ),
            )
          ],
        ),
      ),
    );
  }

  // Logo conainer --------------------------------------------
  Widget _logoContainer() {
    return Positioned(
      top: 0,
      right: 0,
      left: 0,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.65,
        width: MediaQuery.of(context).size.width,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 100,
              width: 100,
              child: Image(
                image: AssetImage("assets/images/logo.png"),
              ),
            ),
            _appName(),
          ],
        ),
      ),
    );
  }

  // app name and slogan --------------------------------------------
  Widget _appName() {
    return Column(
      children: [
        Text(
          "Senboo",
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

  // GetStarted Button ----------------------------------------------------
  Widget _getStartedButton() {
    return Consumer<FirebaseAuthServices>(builder: (context, auth, child) {
      return Container(
        width: MediaQuery.of(context).size.width * 0.8,
        child: ElevatedButton(
          onPressed: () async {
            _showLoading();
            await auth.signIn().whenComplete(() {
              Navigator.pop(context);
            });

            // auth.loadSignIn();
          },
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Color(0xFF397AF3)),
              shadowColor:
                  MaterialStateProperty.all(Theme.of(context).primaryColor),
              padding: MaterialStateProperty.all(
                  EdgeInsets.symmetric(vertical: 15, horizontal: 10)),
              shape: MaterialStateProperty.all(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(35)))),
          child: Row(
            children: [
              Icon(FontAwesomeIcons.google),
              Spacer(),
              Text(
                "Continue with Google",
                style: Theme.of(context)
                    .textTheme
                    .subtitle2!
                    .copyWith(fontSize: 14),
              ),
              Spacer(),
            ],
          ),
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
          child: Center(
            child: LoadingAnimationWidget.staggeredDotWave(
              size: 50,
              color: Theme.of(context).primaryColor,
            ),
          ),
        );
      },
    );
  }

  // CardDecoration --------------------------------------
  // BoxDecoration _cardDecoration() {
  //   return BoxDecoration(
  //     color: Theme.of(context).cardColor,
  //     borderRadius: BorderRadius.circular(15),
  //     boxShadow: [
  //       BoxShadow(
  //         color: Theme.of(context).primaryColor.withOpacity(0.40),
  //         blurRadius: 3,
  //         offset: Offset(0, 0),
  //       ),
  //     ],
  //   );
  // }
}
