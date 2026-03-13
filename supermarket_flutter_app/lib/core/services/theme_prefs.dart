import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemePrefs {
  static const _keySelectedTheme = 'admin_selected_theme';
  static const _keyCustomPrimary = 'admin_custom_primary';
  static const _keySidebarTint = 'admin_sidebar_tint';
  static const _keyHeaderFullColor = 'admin_header_full_color';

  static Future<void> saveSelectedTheme(int index) async {
    final p = await SharedPreferences.getInstance();
    await p.setInt(_keySelectedTheme, index);
  }

  static Future<int?> loadSelectedTheme() async {
    final p = await SharedPreferences.getInstance();
    return p.getInt(_keySelectedTheme);
  }

  static Future<void> saveCustomPrimary(Color? color) async {
    final p = await SharedPreferences.getInstance();
    if (color == null) {
      await p.remove(_keyCustomPrimary);
    } else {
      await p.setInt(_keyCustomPrimary, color.value);
    }
  }

  static Future<Color?> loadCustomPrimary() async {
    final p = await SharedPreferences.getInstance();
    final v = p.getInt(_keyCustomPrimary);
    return v != null ? Color(v) : null;
  }

  static Future<void> saveSidebarTint(double tint) async {
    final p = await SharedPreferences.getInstance();
    await p.setDouble(_keySidebarTint, tint);
  }

  static Future<double?> loadSidebarTint() async {
    final p = await SharedPreferences.getInstance();
    return p.getDouble(_keySidebarTint);
  }

  static Future<void> saveHeaderFullColor(bool enabled) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_keyHeaderFullColor, enabled);
  }

  static Future<bool?> loadHeaderFullColor() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(_keyHeaderFullColor);
  }
}
