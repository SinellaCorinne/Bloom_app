import 'package:bloom_app/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bloom_app/screens/welcome_screen.dart';
import 'providers/task_provider.dart';
import 'providers/theme_provider.dart';

void main() {
  runApp(const BloomApp());
}

class BloomApp extends StatelessWidget {
  const BloomApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],

      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Bloom',
            debugShowCheckedModeBanner: false,
            // ✅ On utilise uniquement 'theme' qui reçoit le thème dynamique
            // (Pink Light, Pink Dark, Blue Light ou Blue Dark)
            theme: themeProvider.themeData,
            home: const WelcomeScreen(),
          );
        },
      ),
    );
  }
}