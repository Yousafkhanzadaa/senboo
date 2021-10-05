import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ColorProvider extends ChangeNotifier {
  String? primaryColorCode;
  SharedPreferences? colorPrefs;

  String? get getColorCode => primaryColorCode;

  // Set Color Code -------------------------------------------------------
  void setColor(String? colorCode) async {
    colorPrefs = await SharedPreferences.getInstance();
    colorPrefs!.setString('colorCode', colorCode ?? "0xff939597");

    notifyListeners();
  }

  loadColor() async {
    colorPrefs = await SharedPreferences.getInstance();
    primaryColorCode = colorPrefs!.getString('colorCode');
  }

  // // Get Color Code -------------------------------------------------------
}
