import 'package:flutter/material.dart';

class LanguageProvider extends ChangeNotifier {
  bool _isArabic = true; // default

  bool get isArabic => _isArabic;

  void toggleLanguage(bool value) {
    _isArabic = value;
    notifyListeners();
  }

  void setArabic() {
    _isArabic = true;
    notifyListeners();
  }

  void setEnglish() {
    _isArabic = false;
    notifyListeners();
  }
}
