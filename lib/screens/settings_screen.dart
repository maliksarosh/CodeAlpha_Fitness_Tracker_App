import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness_tracker_app/screens/auth/welcome_screen.dart';
import 'package:fitness_tracker_app/theme/theme_provider.dart';
import 'package:fitness_tracker_app/screens/edit_profile_screen.dart'; // Import the new screen

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    // The AuthWrapper StreamBuilder will handle navigating to the WelcomeScreen automatically.
    // We add a pushAndRemoveUntil to ensure a clean navigation stack if needed,
    // though the stream often handles it. This is a robust way to do it.
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const WelcomeScreen()),
          (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        children: [
          Card(
            child: Column(
              children: [
                // THIS TILE IS NOW FUNCTIONAL
                _buildSettingsTile(
                    'Personal Information', Iconsax.user_edit, context,
                    onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const EditProfileScreen()),
                  );
                }),
                ListTile(
                  leading: const Icon(Iconsax.moon),
                  title: const Text('Dark Mode'),
                  trailing: Switch.adaptive(
                    value: themeProvider.isDarkMode,
                    onChanged: (value) {
                      themeProvider.toggleTheme(value);
                    },
                  ),
                ),
                _buildSettingsTile(
                  'Log Out',
                  Iconsax.logout,
                  context,
                  isDestructive: true,
                  onTap: () => _logout(context),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSettingsTile(String title, IconData icon, BuildContext context,
      {bool isDestructive = false, VoidCallback? onTap}) {
    final color = isDestructive
        ? Colors.red.shade400
        : Theme.of(context).textTheme.bodyLarge?.color;
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: TextStyle(color: color)),
      trailing:
          const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
      onTap: onTap,
    );
  }
}
