import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// On définit nos 4 thèmes
enum AppThemeMode { pinkLight, pinkDark, blueLight, blueDark }

class ThemeProvider extends ChangeNotifier {
  static const _keyThemeIndex = 'theme_index';
  static const _keyNotifications = 'notifications';

  AppThemeMode _currentTheme = AppThemeMode.pinkLight;
  bool _notifications = true;

  AppThemeMode get currentTheme => _currentTheme;
  bool get notifications => _notifications;

  ThemeProvider() {
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    int index = prefs.getInt(_keyThemeIndex) ?? 0;
    _currentTheme = AppThemeMode.values[index];
    _notifications = prefs.getBool(_keyNotifications) ?? true;
    notifyListeners();
  }

  // Cette méthode change le thème et le sauvegarde
  Future<void> setTheme(AppThemeMode mode) async {
    _currentTheme = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyThemeIndex, mode.index);
    notifyListeners();
  }

  Future<void> toggleNotifications(bool value) async {
    _notifications = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotifications, value);
    notifyListeners();
  }

  // Utile pour savoir si on est en mode sombre ou pas
  bool get isDark => _currentTheme == AppThemeMode.pinkDark || _currentTheme == AppThemeMode.blueDark;

  // Dégradé pour les écrans d'authentification
  LinearGradient get authGradient {
    if (_currentTheme == AppThemeMode.pinkLight || _currentTheme == AppThemeMode.pinkDark) {
      return const LinearGradient(colors: [Color(0xFFEDD5DF), Color(0xFFD186BF)], begin: Alignment.topCenter, end: Alignment.bottomCenter);
    } else {
      return const LinearGradient(colors: [Color(0xFFE0F2F1), Color(0xFF4A90D9)], begin: Alignment.topCenter, end: Alignment.bottomCenter);
    }
  }
// --- À AJOUTER DANS providers/theme_provider.dart ---

// Récupère l'accent de couleur (Rose ou Bleu) selon le thème choisi
  Color get accentColor {
    if (_currentTheme == AppThemeMode.pinkLight || _currentTheme == AppThemeMode.pinkDark) {
      return const Color(0xFFD186BF); // Ton Rose signature
    } else {
      return const Color(0xFF4A90D9); // Ton nouveau Bleu élégant
    }
  }
  // GÉNÉRATEUR DE THÈME DYNAMIQUE
  ThemeData get themeData {
    final Color primary = (_currentTheme == AppThemeMode.pinkLight || _currentTheme == AppThemeMode.pinkDark)
        ? const Color(0xFFD186BF) : const Color(0xFF4A90D9);

    final Color scaffoldBg = _getBg();
    final bool dark = isDark;

    return ThemeData(
      useMaterial3: true,
      brightness: dark ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: scaffoldBg,
      primaryColor: primary,
      cardColor: dark ? Colors.black : Colors.white,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: dark ? Brightness.dark : Brightness.light,
        surface: scaffoldBg,
      ),
      appBarTheme: AppBarTheme(backgroundColor: scaffoldBg, elevation: 0),
    );
  }

  Color _getBg() {
    switch (_currentTheme) {
      case AppThemeMode.pinkLight: return const Color(0xFFF2E0E8);
      case AppThemeMode.blueLight: return const Color(0xFFE8EFF8);
      case AppThemeMode.pinkDark: return const Color(0xFF1E021B);
      case AppThemeMode.blueDark: return const Color(0xFF0D1B2A);
    }
  }
}