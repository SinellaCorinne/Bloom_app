import 'package:flutter/material.dart';
import 'package:bloom_app/screens/login_screen.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../theme.dart';
import '../widgets/themed_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  final _confirmController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _obscurePass = true;
  bool _obscureConfirm = true;

  void _register() async {
    final auth = context.read<AuthProvider>();

    if (_userController.text.trim().isEmpty ||
        _passController.text.trim().isEmpty ||
        _confirmController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Veuillez remplir tous les champs'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      );
      return;
    }

    if (_passController.text != _confirmController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Les mots de passe ne correspondent pas ❌'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      );
      return;
    }

    bool success = await auth.register(
      _userController.text.trim(),
      _phoneController.text.trim(),
      _passController.text,
    );

    if (success) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('✅ Inscription réussie ! Connectez-vous.'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("❌ Échec de l'inscription. Réessayez."),
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

    String registerImageUrl;
    switch (currentTheme) {
      case AppThemeMode.pinkLight:
        registerImageUrl = 'assets/images/login_pink_light.png';
        break;
      case AppThemeMode.pinkDark:
        registerImageUrl = 'assets/images/login_pink_dark.png';
        break;
      case AppThemeMode.blueLight:
        registerImageUrl = 'assets/images/login_blue_light.png';
        break;
      case AppThemeMode.blueDark:
        registerImageUrl = 'assets/images/login_blue_dark.png';
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
                children: [
                  // ── Logo Dynamique ──────────────────────────────────────
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
                      registerImageUrl,
                      height: 110,
                      width: 110,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.person_add_alt_1_rounded,
                        size: 90,
                        color: Colors.white54,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Titre Bloom ──────────────────────────────────────────
                  Text(
                    'Bloom',
                    style: TextStyle(
                      fontSize: 40,
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
                    'Créez votre compte gratuit',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 40),

                  // ── Champs dans carte glassmorphism ───────────────────────
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
                        const SizedBox(height: 14),

                        ThemedField(
                          controller: _phoneController,
                          hintText: 'Téléphone',
                          icon: Icons.phone_outlined,
                          isDark: isDark,
                        ),
                        const SizedBox(height: 14),

                        ThemedField(
                          controller: _passController,
                          hintText: 'Mot de passe',
                          icon: Icons.lock_outline,
                          isDark: isDark,
                          obscureText: _obscurePass,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePass
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: Colors.black26,
                            ),
                            onPressed: () => setState(() => _obscurePass = !_obscurePass),
                          ),
                        ),
                        const SizedBox(height: 14),

                        ThemedField(
                          controller: _confirmController,
                          hintText: 'Confirmer mot de passe',
                          icon: Icons.lock_reset_outlined,
                          isDark: isDark,
                          obscureText: _obscureConfirm,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirm
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: Colors.black26,
                            ),
                            onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ── Bouton d'action ────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _register,
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
                        "S'inscrire",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ── Lien de navigation ───────────────────────────────────
                  GestureDetector(
                    onTap: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Déjà un compte ? Se connecter',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontStyle: FontStyle.italic,
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
    _confirmController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}