import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLanguage extends ChangeNotifier {
  Locale _appLocale = Locale("fr");
  Locale get appLocale => _appLocale ?? Locale("fr");

  fetchLocale() async {
    var prefs = await SharedPreferences.getInstance();
    if (prefs.getString('language_code') == null) {
      _appLocale = Locale('fr');
      return Null;
    }
    _appLocale = Locale(prefs.getString('language_code'));
    return Null;
  }

  void changeLanguage(String type) async {
    var prefs = await SharedPreferences.getInstance();
    if (_appLocale.languageCode == type) {
      return;
    }
    if (type == "ar") {
      _appLocale = Locale("ar");
      await prefs.setString('language_code', 'ar');
    } else {
      _appLocale = Locale("fr");
      await prefs.setString('language_code', 'fr');
    }
    notifyListeners();
  }
}
