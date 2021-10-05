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
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
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
            Expanded(child: _quote()),
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
      height: 80,
      width: 80,
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
          "Share you imagination",
          style: Theme.of(context).textTheme.bodyText1,
        )
      ],
    );
  }

  // Quote --------------------------------------------
  Widget _quote() {
    return Text(
      " The world is a canvas for your imagination. You are the painter. There are NO RULES",
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodyText1!.copyWith(fontSize: 19),
    );
  }

  // // Terms and conditions --------------------------------------------
  // Widget _termsContitions() {
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.center,
  //     children: [
  //       Checkbox(
  //         value: agreed,
  //         activeColor: Theme.of(context).primaryColor,
  //         onChanged: (value) {
  //           setState(() {
  //             agreed = value!;
  //           });
  //         },
  //       ),
  //       Text(
  //         "Agreed to all terms and conditinos",
  //         textAlign: TextAlign.center,
  //         style: Theme.of(context).textTheme.bodyText1,
  //       ),
  //     ],
  //   );
  // }

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

  // show loading
  _showLoading() {
    showDialog(
      context: context,
      barrierDismissible: false,
      useSafeArea: true,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: _cardDecoration(),
            height: MediaQuery.of(context).size.height * 0.35,
            width: MediaQuery.of(context).size.width * 0.9,
            child: Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
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
      borderRadius: BorderRadius.circular(25),
      boxShadow: [
        BoxShadow(
          color: Theme.of(context).primaryColor.withOpacity(0.40),
          blurRadius: 5,
          offset: Offset(0, 0),
          spreadRadius: 1,
        ),
      ],
    );
  }
}
