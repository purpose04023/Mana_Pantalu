import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

class LocaleNotifier extends StateNotifier<String> {
  final SharedPreferences _prefs;
  LocaleNotifier(this._prefs) : super(_prefs.getString('language') ?? 'te');

  void setLocale(String lang) {
    state = lang;
    _prefs.setString('language', lang);
  }

  void toggle() {
    setLocale(state == 'te' ? 'en' : 'te');
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, String>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return LocaleNotifier(prefs);
});

class WelcomeSeenNotifier extends StateNotifier<bool> {
  final SharedPreferences _prefs;
  WelcomeSeenNotifier(this._prefs) : super(_prefs.getBool('welcome_seen') ?? false);

  void markSeen() {
    state = true;
    _prefs.setBool('welcome_seen', true);
  }
}

final welcomeSeenProvider = StateNotifierProvider<WelcomeSeenNotifier, bool>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return WelcomeSeenNotifier(prefs);
});
