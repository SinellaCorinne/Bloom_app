import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:bloom_app/screens/login_screen.dart';
import '../providers/theme_provider.dart';
import '../providers/auth_provider.dart'; // ✅ Import pour le nom
import '../theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  File? _profileImage;

  @override
  void initState() {
    super.initState();
    // ✅ On initialise avec les vraies données de l'utilisateur
    final auth = context.read<AuthProvider>();
    _nameController = TextEditingController(text: auth.userName);
    _emailController = TextEditingController(text: 'user@bloom.com');
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) {
      setState(() => _profileImage = File(picked.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final themeProvider = context.watch<ThemeProvider>();
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        surfaceTintColor: Colors.transparent,

        title: Text(
          'Bloom',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color:  cs.primary,
            fontStyle: FontStyle.italic,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: themeProvider.accentColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.notifications_outlined, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // ── Photo de profil ──────────────────
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    color: const Color(0xFFF0D8C8),
                  ),
                  child: CircleAvatar(
                    backgroundColor: const Color(0xFFF0D8C8),
                    backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                    child: _profileImage == null ? const Icon(Icons.person, size: 60, color: Colors.white70) : null,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: themeProvider.accentColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              authProvider.userName,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: cs.onSurface),
            ),
            const SizedBox(height: 30),

            // ── Formulaire & Préférences ──────────
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Full Name', style: TextStyle(fontWeight: FontWeight.bold, color: cs.onSurface, fontSize: 13)),
                  const SizedBox(height: 8),
                  _EditField(controller: _nameController, icon: Icons.person_outline),
                  const SizedBox(height: 16),
                  Text('Email Address', style: TextStyle(fontWeight: FontWeight.bold, color: cs.onSurface, fontSize: 13)),
                  const SizedBox(height: 8),
                  _EditField(controller: _emailController, icon: Icons.email_outlined),
                  const SizedBox(height: 20),
                  Text('PREFERENCES', style: TextStyle(color: cs.onSurfaceVariant, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1)),
                  const SizedBox(height: 8),

                  // Notifications
                  ListTile(
                    leading: Icon(Icons.notifications_outlined, color: themeProvider.accentColor),
                    title: Text('Push Notifications', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: cs.onSurface)),
                    trailing: Switch(
                      value: themeProvider.notifications,
                      onChanged: (v) => themeProvider.toggleNotifications(v),
                      activeColor: themeProvider.accentColor,
                    ),
                    contentPadding: EdgeInsets.zero,
                  ),
                  const Divider(),
                  const SizedBox(height: 10),

                  // Thèmes
                  const Text('CHOISIR UN THÈME', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 11)),
                  const SizedBox(height: 16),
                  _buildThemeOption(context, "Bloom Pink", AppThemeMode.pinkLight, const Color(0xFFD186BF)),
                  _buildThemeOption(context, "Pink Night", AppThemeMode.pinkDark, const Color(0xFF1A1A2E)),
                  _buildThemeOption(context, "Elegant Blue", AppThemeMode.blueLight, const Color(0xFF4A90D9)),
                  _buildThemeOption(context, "Deep Ocean", AppThemeMode.blueDark, const Color(0xFF0D1B2A)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Bouton Sign Out ──────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextButton(
                  onPressed: () => Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false,
                  ),
                  child: Text(
                    'Sign Out',
                    style: TextStyle(color: themeProvider.accentColor, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(BuildContext context, String title, AppThemeMode mode, Color color) {
    final provider = context.watch<ThemeProvider>();
    final isSelected = provider.currentTheme == mode;

    return InkWell(
      onTap: () => provider.setTheme(mode),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
            const SizedBox(width: 16),
            Text(title, style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? provider.accentColor : null,
            )),
            const Spacer(),
            if (isSelected) Icon(Icons.check_circle, color: provider.accentColor, size: 20)
            else const Icon(Icons.circle_outlined, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}

class _EditField extends StatelessWidget {
  final TextEditingController controller;
  final IconData icon;
  const _EditField({required this.controller, required this.icon});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A2E) : const Color(0xFFF8F0F5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        controller: controller,
        style: TextStyle(color: cs.onSurface, fontSize: 14),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: cs.onSurfaceVariant, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        ),
      ),
    );
  }
}