import 'package:flutter/cupertino.dart';

class NotifyProvider extends ChangeNotifier {
  int _notifyCount = 0;

  Future<void> setNotifyCount(int newCount) async {
    await Future.delayed(const Duration(milliseconds: 100), () {});
    _notifyCount = newCount;
    notifyListeners();
  }

  set setNotifyCountIncrement(int newCount) {
    _notifyCount += newCount;
    notifyListeners();
  }

  get getNotifyCount => _notifyCount;
}
