import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

class SettingsNotifier extends StateNotifier<SettingsState> {
  final SharedPreferences _prefs;

  SettingsNotifier(this._prefs)
      : super(SettingsState(
          themeMode: ThemeMode.values[_prefs.getInt('themeMode') ?? 0],
          seedColor: Color(_prefs.getInt('seedColor') ?? 0xFF22C55E),
        ));

  void setThemeMode(ThemeMode mode) {
    _prefs.setInt('themeMode', mode.index);
    state = state.copyWith(themeMode: mode);
  }

  void setSeedColor(Color color) {
    _prefs.setInt('seedColor', color.value);
    state = state.copyWith(seedColor: color);
  }
}

class SettingsState {
  final ThemeMode themeMode;
  final Color seedColor;

  SettingsState({required this.themeMode, required this.seedColor});

  SettingsState copyWith({ThemeMode? themeMode, Color? seedColor}) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      seedColor: seedColor ?? this.seedColor,
    );
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SettingsNotifier(prefs);
});
