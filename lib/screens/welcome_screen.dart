import 'package:flutter/material.dart';
import 'package:bloom_app/screens/register_screen.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../theme.dart';
import 'login_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final themeProvider = context.watch<ThemeProvider>();
    final currentTheme = themeProvider.currentTheme;

    String welcomeImageUrl;
    switch (currentTheme) {
      case AppThemeMode.pinkLight:
        welcomeImageUrl = 'assets/images/welcome_pink_light.png';
        break;
      case AppThemeMode.pinkDark:
        welcomeImageUrl = 'assets/images/welcome_pink_dark.png';
        break;
      case AppThemeMode.blueLight:
        welcomeImageUrl = 'assets/images/welcome_blue_light.png';
        break;
      case AppThemeMode.blueDark:
        welcomeImageUrl = 'assets/images/welcome_blue_dark.png';
        break;
    }

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(gradient: themeProvider.authGradient),
        child: SafeArea(
          child: Column(
            children: [
              // ── Illustration centrale dynamique ──────────────────────────
              Expanded(
                flex: 8,
                child: Padding(
                  padding: const EdgeInsets.only(top: 40, left: 20, right: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 32,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      welcomeImageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.spa_outlined,
                        size: 150,
                        color: Colors.white54,
                      ),
                    ),
                  ),
                ),
              ),

              // ── Zone de texte et bouton ──────────────────────────────────
              Expanded(
                flex: 6,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Titre Bloom
                    Text(
                      'Bloom',
                      style: TextStyle(
                        fontSize: 56,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontStyle: FontStyle.italic,
                        letterSpacing: 2,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Grow your productivity',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        letterSpacing: 1.2,
                      ),
                    ),

                    const SizedBox(height: 50),

                    // Bouton Get Started
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 50),
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: cs.primary,
                            elevation: 6,
                            shadowColor: Colors.black.withOpacity(0.25),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            "Get started",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Indicateur visuel de scroll / pagination
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: i == 0 ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: i == 0
                              ? Colors.white
                              : Colors.white.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      )),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}