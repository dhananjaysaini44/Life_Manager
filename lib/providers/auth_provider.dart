import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'settings_provider.dart';

final authProvider = StateNotifierProvider<AuthNotifier, bool>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return AuthNotifier(prefs);
});

class AuthNotifier extends StateNotifier<bool> {
  final SharedPreferences _prefs;
  static const _authKey = 'is_logged_in';

  AuthNotifier(this._prefs) : super(_prefs.getBool(_authKey) ?? false);

  Future<void> login() async {
    await _prefs.setBool(_authKey, true);
    state = true;
  }

  Future<void> logout() async {
    await _prefs.setBool(_authKey, false);
    state = false;
  }
}
