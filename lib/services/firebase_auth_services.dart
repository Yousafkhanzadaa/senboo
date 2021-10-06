import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirebaseAuthServices extends ChangeNotifier {
  SharedPreferences? persistSignInOut;
  FirebaseAuth auth = FirebaseAuth.instance;
  bool signIned = false;

  bool get getStatus => signIned;

  // sign In function -------------------------------------
  Future<UserCredential> signIn() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleUser!.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw e;
    }
  }

  // Sign out function -------------------------------------
  void signOut() async {
    try {
      await auth.signOut();
      GoogleSignIn().signOut();
    } catch (e) {
      // print(e);
      throw e;
    }
  }

  // get current status function -------------------------------------
  Stream<User?>? get currentStatus => auth.authStateChanges();
}
