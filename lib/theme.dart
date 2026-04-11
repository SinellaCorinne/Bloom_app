// theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  // Couleurs fixes (indépendantes du thème)
  static const Color primary     = Color(0xFFD186BF);
  static const Color primaryDark = Color(0xFFD815A9);

  // Priorités — identiques en light et dark
  static const Color priorityHighBg     = Color(0xFFF4A7BB);
  static const Color priorityHighText   = Color(0xFFC0456A);
  static const Color priorityMediumBg   = Color(0xFFDBEAFE);
  static const Color priorityMediumText = Color(0xFF3B82F6);
  static const Color priorityLowBg      = Color(0xFFD7FFE7);
  static const Color priorityLowText    = Color(0xFF079D43);

  // Gradient (welcome/login/register)
  static const gradientPrimary = LinearGradient(
    colors: [Color(0xFFEDD5DF), Color(0xFFD186BF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ── Couleurs contextuelles (lisent le thème) ──────────────────────────

  /// Fond des cards / champs de saisie
  static Color cardBg(BuildContext context) =>
      Theme.of(context).cardColor;

  /// Texte principal
  static Color textPrimary(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface;

  /// Texte secondaire / hint
  static Color textSecondary(BuildContext context) =>
      Theme.of(context).colorScheme.onSurfaceVariant;

  /// Fond global de l'écran
  static Color scaffoldBg(BuildContext context) =>
      Theme.of(context).scaffoldBackgroundColor;

  // ── Boutons ───────────────────────────────────────────────────────────

  static final buttonPrimary = ElevatedButton.styleFrom(
    backgroundColor: primary,
    foregroundColor: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 40),
    elevation: 2,
  );

  static final buttonSecondary = ElevatedButton.styleFrom(
    backgroundColor: Colors.white.withOpacity(0.85),
    foregroundColor: primary,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 40),
    elevation: 2,
  );

  // ── Badge priorité ────────────────────────────────────────────────────

  static Widget priorityBadge(String priority) {
    Color bg; Color fg;
    switch (priority.toLowerCase()) {
      case 'high':   bg = priorityHighBg;   fg = priorityHighText;   break;
      case 'medium': bg = priorityMediumBg; fg = priorityMediumText; break;
      default:       bg = priorityLowBg;    fg = priorityLowText;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(
        '${priority.toUpperCase()} PRIORITY',
        style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }

  // ── Champ de saisie (statique, pour les écrans auth) ──────────────────
  static InputDecoration inputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: label,
      hintStyle: const TextStyle(color: Color(0xFFB0B0B0), fontStyle: FontStyle.italic),
      prefixIcon: const Icon(Icons.abc, color: Color(0xFFB0B0B0)), // override à l'appel
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: Color(0xFFE0C0D0), width: 1)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: primary, width: 1.5)),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
    );
  }
}