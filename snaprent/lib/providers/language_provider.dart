import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final languageProvider = StateNotifierProvider<LanguageNotifier, Locale>((ref) {
  return LanguageNotifier.uninitialized();
});

class LanguageNotifier extends StateNotifier<Locale> {
  final SharedPreferences? _prefs;

  LanguageNotifier(this._prefs, Locale initialLocale) : super(initialLocale) {
    _loadLanguage();
  }

  factory LanguageNotifier.uninitialized() {
    return LanguageNotifier(null, const Locale('en'));
  }

  Future<void> _loadLanguage() async {
    if (_prefs != null) {
      final langCode = _prefs!.getString('language');
      if (langCode != null) {
        state = Locale(langCode);
      }
    }
  }

  Future<void> setLanguage(String langCode) async {
    if (_prefs != null) {
      await _prefs!.setString('language', langCode);
    }
    print('Setting language to $langCode');
    state = Locale(langCode);
  }
}
