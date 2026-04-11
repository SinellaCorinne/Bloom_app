import 'package:flutter/material.dart';
import 'package:bloom_app/screens/register_screen.dart';
import 'package:bloom_app/screens/home_screen.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../theme.dart';
import '../widgets/themed_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  bool _obscure = true;

  void _login() async {
    final auth = context.read<AuthProvider>();
    bool success = await auth.login(_userController.text, _passController.text);

    if (success) {
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Échec de la connexion. Vérifiez vos accès.'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final currentTheme = themeProvider.currentTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    String loginImageUrl;
    switch (currentTheme) {
      case AppThemeMode.pinkLight:
        loginImageUrl = 'assets/images/login_pink_light.png';
        break;
      case AppThemeMode.pinkDark:
        loginImageUrl = 'assets/images/login_pink_dark.png';
        break;
      case AppThemeMode.blueLight:
        loginImageUrl = 'assets/images/login_blue_light.png';
        break;
      case AppThemeMode.blueDark:
        loginImageUrl = 'assets/images/login_blue_dark.png';
        break;
    }

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(gradient: themeProvider.authGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Image dynamique — légère ombre pour la faire ressortir
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      loginImageUrl,
                      height: 120,
                      width: 120,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.lock_person_rounded,
                        size: 100,
                        color: Colors.white54,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Titre Bloom
                  Text(
                    'Bloom',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontStyle: FontStyle.italic,
                      letterSpacing: 2,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Connectez-vous à votre compte',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 48),

                  // ── CHAMPS ────────────────────────────────────────────
                  // Carte légère derrière les champs
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.15),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        ThemedField(
                          controller: _userController,
                          hintText: "Nom d'utilisateur",
                          icon: Icons.person_outline,
                          isDark: isDark,
                        ),
                        const SizedBox(height: 16),
                        ThemedField(
                          controller: _passController,
                          hintText: 'Mot de passe',
                          icon: Icons.lock_outline,
                          isDark: isDark,
                          obscureText: _obscure,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscure
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: Colors.black26,
                            ),
                            onPressed: () => setState(() => _obscure = !_obscure),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Bouton de connexion — ombre + léger scale visuel
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: cs.primary,
                        elevation: 4,
                        shadowColor: Colors.black.withOpacity(0.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Se connecter',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Lien vers inscription
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RegisterScreen()),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        "Pas de compte ? S'inscrire",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _userController.dispose();
    _passController.dispose();
    super.dispose();
  }
}