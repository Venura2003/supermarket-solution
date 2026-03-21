import 'package:flutter/material.dart';
import '../services/theme_prefs.dart';
import '../theme/app_theme.dart';

class ThemeModeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  int _selectedThemeIndex = 0;
  Color? _customPrimaryColor = const Color(0xFF1976D2); // Force blue
  double _sidebarTint = 0.12;
  bool _headerFullColor = true; // Always use full color header

  final List<ThemeData> _themePresets = [
    AppTheme.lightTheme,
    AppTheme.lightTheme.copyWith(
      colorScheme: AppTheme.colorScheme.copyWith(primary: const Color(0xFF6A1B9A), background: const Color(0xFFF7F3FB), surface: Colors.white),
      scaffoldBackgroundColor: const Color(0xFFF7F3FB),
    ),
    AppTheme.lightTheme.copyWith(
      colorScheme: AppTheme.colorScheme.copyWith(primary: const Color(0xFF00897B), background: const Color(0xFFF2F7F5), surface: Colors.white),
      scaffoldBackgroundColor: const Color(0xFFF2F7F5),
    ),
    AppTheme.lightTheme.copyWith(
      colorScheme: AppTheme.colorScheme.copyWith(primary: const Color(0xFFEF6C00), background: const Color(0xFFFFF8F1), surface: Colors.white),
      scaffoldBackgroundColor: const Color(0xFFFFF8F1),
    ),
    // Dark theme preset
    AppTheme.darkTheme.copyWith(
      colorScheme: AppTheme.darkColorScheme.copyWith(primary: const Color(0xFF90CAF9)),
      scaffoldBackgroundColor: const Color(0xFF0B0B0B),
      appBarTheme: AppTheme.darkTheme.appBarTheme.copyWith(backgroundColor: const Color(0xFF121212)),
    ),
  ];

  ThemeModeProvider() {
    _loadPrefs();
  }
  
  List<ThemeData> get presets => _themePresets;

  ThemeMode get themeMode => _themeMode;
  int get selectedThemeIndex => _selectedThemeIndex;
  Color? get customPrimaryColor => _customPrimaryColor;
  double get sidebarTint => _sidebarTint;
  bool get headerFullColor => _headerFullColor;
  
  ThemeData get currentTheme {
      // If index is out of bounds, fallback to 0
      final index = (_selectedThemeIndex >= 0 && _selectedThemeIndex < _themePresets.length) ? _selectedThemeIndex : 0;
      final ThemeData baseTheme = _themePresets[index];
      
      return (_customPrimaryColor != null)
        ? baseTheme.copyWith(
            colorScheme: baseTheme.colorScheme.copyWith(primary: _customPrimaryColor),
            appBarTheme: baseTheme.appBarTheme.copyWith(backgroundColor: baseTheme.colorScheme.surface),
          )
        : baseTheme;
  }

  // Load preferences on startup
  Future<void> _loadPrefs() async {
    final idx = await ThemePrefs.loadSelectedTheme();
    final tint = await ThemePrefs.loadSidebarTint();
    if (idx != null) _selectedThemeIndex = idx;
    if (tint != null) _sidebarTint = tint;
    // Force header color and blue for all platforms
    _headerFullColor = true;
    _customPrimaryColor = const Color(0xFF1976D2);
    // Determine ThemeMode based on selected preset (Index 4 is dark)
    _themeMode = (_selectedThemeIndex == 4) ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void toggleTheme() {
    // Determine target mode
    final iscurrentlyLight = _themeMode == ThemeMode.light;
    _themeMode = iscurrentlyLight ? ThemeMode.dark : ThemeMode.light;
    
    // Attempt to switch to a corresponding preset if possible 
    // Simplified logic: index 0 (light) <-> index 4 (dark)
    if (_themeMode == ThemeMode.dark) {
        _selectedThemeIndex = 4;
    } else {
        _selectedThemeIndex = 0;
    }
    
    _savePrefs();
    notifyListeners(); 
  }

  void setSelectedTheme(int index) {
    if (index >= 0 && index < _themePresets.length) {
      _selectedThemeIndex = index;
      // Index 4 is intended to be Dark Mode in current presets
      _themeMode = (index == 4) ? ThemeMode.dark : ThemeMode.light;
      _savePrefs();
      notifyListeners();
    }
  }

  void setCustomPrimaryColor(Color? color) {
    _customPrimaryColor = color;
    _savePrefs();
    notifyListeners();
  }
  
  void setSidebarTint(double tint) {
    _sidebarTint = tint;
    _savePrefs();
    notifyListeners();
  }

  void setHeaderFullColor(bool enabled) {
    _headerFullColor = enabled;
    _savePrefs();
    notifyListeners();
  }

  Future<void> _savePrefs() async {
    await ThemePrefs.saveSelectedTheme(_selectedThemeIndex);
    await ThemePrefs.saveCustomPrimary(_customPrimaryColor);
    await ThemePrefs.saveSidebarTint(_sidebarTint);
    await ThemePrefs.saveHeaderFullColor(_headerFullColor);
  }
}
