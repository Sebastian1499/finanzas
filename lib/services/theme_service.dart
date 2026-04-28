import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kThemeKey = 'app_theme_mode';

/// Notifier global — escuchado por main.dart para aplicar el tema.
final themeNotifier = ValueNotifier<ThemeMode>(ThemeMode.system);

/// Carga la preferencia guardada (llamar al inicio de main()).
Future<void> loadSavedTheme() async {
  final prefs = await SharedPreferences.getInstance();
  final stored = prefs.getString(_kThemeKey);
  themeNotifier.value = switch (stored) {
    'light' => ThemeMode.light,
    'dark'  => ThemeMode.dark,
    _       => ThemeMode.system,
  };
}

/// Persiste y aplica el nuevo tema.
Future<void> setTheme(ThemeMode mode) async {
  themeNotifier.value = mode;
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_kThemeKey, switch (mode) {
    ThemeMode.light  => 'light',
    ThemeMode.dark   => 'dark',
    ThemeMode.system => 'system',
  });
}
