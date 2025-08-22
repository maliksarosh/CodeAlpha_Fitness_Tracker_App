import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'package:fitness_tracker_app/theme/app_theme.dart';
import 'package:fitness_tracker_app/theme/theme_provider.dart';
import 'package:fitness_tracker_app/screens/main_screen.dart';
import 'package:fitness_tracker_app/screens/auth/welcome_screen.dart';
import 'package:fitness_tracker_app/models/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await DatabaseHelper.instance.database;

  // Check the initial login state
  final prefs = await SharedPreferences.getInstance();
  final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: FitnessTrackerApp(isLoggedIn: isLoggedIn),
    ),
  );
}

class FitnessTrackerApp extends StatelessWidget {
  final bool isLoggedIn;
  const FitnessTrackerApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Fitness Tracker',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          debugShowCheckedModeBanner: false,
          // Directly choose the home screen based on the initial state
          home: isLoggedIn ? MainScreen() : const WelcomeScreen(),
        );
      },
    );
  }
}
