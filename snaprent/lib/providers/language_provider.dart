import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final languageProvider = StateNotifierProvider<LanguageNotifier, Locale>(
  (ref) => throw UnimplementedError(), // Will be overridden in main
);

class LanguageNotifier extends StateNotifier<Locale> {
  final SharedPreferences _prefs;
  final Locale _systemLocale;
  final List<Locale> _supportedLocales = const [Locale('en'), Locale('fr')];
  static const _languageKey = 'appLanguage';

  LanguageNotifier(this._prefs, this._systemLocale)
    : super(const Locale('en')) {
    _initLocale();
  }

  void _initLocale() {
    // Check if the system language is one of the supported locales
    if (_supportedLocales.contains(_systemLocale)) {
      state = _systemLocale;
    } else {
      // Otherwise, load from storage or use a default
      final persistedLanguageCode = _prefs.getString(_languageKey);
      if (persistedLanguageCode != null) {
        state = Locale(persistedLanguageCode);
      }
    }
  }

  Future<void> setLanguage(Locale locale) async {
    if (locale != state) {
      state = locale;
      await _prefs.setString(_languageKey, locale.languageCode);
    }
  }
}
