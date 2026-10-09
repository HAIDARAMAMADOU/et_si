import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _localePreferenceKey = 'et_si_locale';

final localeProvider = NotifierProvider<LocaleController, Locale>(
  LocaleController.new,
);

class LocaleController extends Notifier<Locale> {
  @override
  Locale build() {
    _restoreSavedLocale();
    return const Locale('fr');
  }

  Future<void> _restoreSavedLocale() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final languageCode = preferences.getString(_localePreferenceKey);
      if (languageCode == 'fr' || languageCode == 'en') {
        state = Locale(languageCode!);
      }
    } catch (_) {
      // If preferences cannot be read, keep French as the default language.
    }
  }

  Future<void> setLocale(Locale locale) async {
    if (locale.languageCode != 'fr' && locale.languageCode != 'en') return;
    state = Locale(locale.languageCode);
    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setString(_localePreferenceKey, locale.languageCode);
    } catch (_) {
      // The selected language remains active for the current session.
    }
  }
}
