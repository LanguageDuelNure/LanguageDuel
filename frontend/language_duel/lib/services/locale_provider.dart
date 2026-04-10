import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');
  static const _prefsKey = 'selected_locale';

  Locale get locale => _locale;

  // Loads the saved language when the app starts
  Future<void> loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguageCode = prefs.getString(_prefsKey);
    
    if (savedLanguageCode != null && ['en', 'uk'].contains(savedLanguageCode)) {
      _locale = Locale(savedLanguageCode);
      notifyListeners();
    }
  }

  // Saves the language whenever the user changes it
  Future<void> setLocale(Locale locale) async {
    if (!['en', 'uk'].contains(locale.languageCode)) return;
    
    _locale = locale;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, locale.languageCode);
  }
}