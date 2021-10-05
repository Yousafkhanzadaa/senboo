import 'package:flutter/cupertino.dart';

class SignInController extends ChangeNotifier {
  bool? exists;
  bool? signin;
  List interestList = [];

  get getInterestList => interestList;

  set setInterestList(List list) {
    interestList = list;

    notifyListeners();
  }

  setExists(bool exist, bool signinn) {
    exists = exist;
    signin = signinn;
    notifyListeners();
  }

  get getExists => exists;
  get getSignin => signin;
}
