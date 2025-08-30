import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final languageProvider = StateNotifierProvider<LanguageNotifier, Locale>(
  (ref) => throw UnimplementedError(),
);

class LanguageNotifier extends StateNotifier<Locale> {
  final SharedPreferences _prefs;
  static const String _languageKey = 'language';

  LanguageNotifier(this._prefs) : super(const Locale('en')) {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final langCode = _prefs.getString(_languageKey);
    if (langCode != null) {
      state = Locale(langCode);
    }
  }

  Future<void> setLanguage(String langCode) async {
    await _prefs.setString(_languageKey, langCode);
    state = Locale(langCode);
  }
}
