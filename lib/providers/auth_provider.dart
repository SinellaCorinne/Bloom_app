// providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  String? _token;
  bool _isLoading = false;
  String? _userName;

  bool get isAuthenticated => _token != null;
  bool get isLoading => _isLoading;
  String get userName => _userName ?? "Utilisateur";

  // Tentative de connexion
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = await _api.login(email, password);
      _token = data['jwt'];

      // ✅ Extraction du nom (Adapte 'username' selon la structure de ton JSON API)
      _userName = data['user']['username'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', _token!);
      await prefs.setString('userName', _userName!); // Optionnel: sauver en local

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  // providers/auth_provider.dart

  // Inscription d'un nouvel utilisateur
  Future<bool> register(String username, String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = await _api.register(username, email, password);
      _token = data['jwt'];

      // ✅ Extraction du nom après inscription
      _userName = data['user']['username'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', _token!);
      await prefs.setString('userName', _userName!);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _token = null;
    _userName = null; // ✅ On vide le nom à la déconnexion
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }
}