import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../theme.dart';

class ThemedField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final bool isDark;
  final bool obscureText;
  final Widget? suffixIcon;

  const ThemedField({
    required this.controller,
    required this.hintText,
    required this.icon,
    required this.isDark,
    this.obscureText = false,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    // ✅ Couleurs adaptatives
    final fillColor = isDark ? const Color(0xFF1A1A2E) : Colors.white;
    final hintColor = isDark ? Colors.white38 : const Color(0xFFB0B0B0);
    final iconColor = isDark ? Colors.white38 : const Color(0xFFB0B0B0);
    final textColor = isDark ? Colors.white : Colors.black87;
    final borderColor = isDark ? const Color(0xFF4A3A4A) : const Color(0xFFE0C0D0);

    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: TextStyle(color: textColor),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: hintColor, fontStyle: FontStyle.italic),
        prefixIcon: Icon(icon, color: iconColor),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: fillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: borderColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: cs.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      ),
    );
  }
}