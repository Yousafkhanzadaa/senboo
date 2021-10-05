import 'package:flutter/cupertino.dart';

class EditListController extends ChangeNotifier {
  List interestList = [];

  set setList(List list) {
    interestList = list;
    notifyListeners();
  }

  get getList => interestList;
}
