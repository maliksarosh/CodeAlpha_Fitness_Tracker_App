import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitness_tracker_app/models/activity.dart' as app_activity;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<Map<String, dynamic>> _profileDataFuture;

  @override
  void initState() {
    super.initState();
    _profileDataFuture = _loadAllProfileData();
  }

  Future<Map<String, dynamic>> _loadAllProfileData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return {
        'userDoc': null,
        'totalWorkouts': 0,
        'totalMinutes': 0,
        'totalCalories': 0
      };
    }

    final userDocFuture =
        FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    final activitiesQueryFuture = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('activities')
        .get();

    final results = await Future.wait([userDocFuture, activitiesQueryFuture]);

    final userDoc = results[0] as DocumentSnapshot<Map<String, dynamic>>;
    final activitiesSnapshot =
        results[1] as QuerySnapshot<Map<String, dynamic>>;

    int totalWorkouts = activitiesSnapshot.docs.length;
    int totalMinutes = 0;
    int totalCalories = 0;

    for (var doc in activitiesSnapshot.docs) {
      final activity = app_activity.Activity.fromFirestore(doc);
      totalMinutes += activity.duration;
      totalCalories += activity.calories;
    }

    return {
      'userDoc': userDoc,
      'totalWorkouts': totalWorkouts,
      'totalMinutes': totalMinutes,
      'totalCalories': totalCalories,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('My Profile',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _profileDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text("Error loading profile data."));
          }

          final data = snapshot.data!;
          final userDoc =
              data['userDoc'] as DocumentSnapshot<Map<String, dynamic>>?;

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _profileDataFuture = _loadAllProfileData();
              });
            },
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              children: [
                _buildProfileHeader(userDoc),
                const SizedBox(height: 50),
                _buildStatsSection(data),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- THIS IS THE REDESIGNED WIDGET ---
  Widget _buildProfileHeader(DocumentSnapshot<Map<String, dynamic>>? userDoc) {
    if (userDoc == null || !userDoc.exists) {
      return const Center(child: Text("User data not found."));
    }

    final userData = userDoc.data()!;
    final String name = userData['name'] ?? 'Fitness User';
    final String email = userData['email'] ?? 'No email';

    // The layout is now a centered Column
    return Column(
      children: [
        // Using the app logo
        Image.asset(
          'assets/images/logo.png',
          height: 150,
          // Use a color filter to make it match the theme
        ),
        const SizedBox(height: 20),
        // Centered Name
        Text(name, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 8),
        // Centered Email
        Text(email, style: Theme.of(context).textTheme.bodyLarge),
      ],
    );
  }

  Widget _buildStatsSection(Map<String, dynamic> data) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatCard(
            'Workouts', data['totalWorkouts'].toString(), Iconsax.activity),
        _buildStatCard(
            'Time (min)', data['totalMinutes'].toString(), Iconsax.clock),
        _buildStatCard(
            'Calories', data['totalCalories'].toString(), Iconsax.flash_1),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).hintColor, size: 30),
        const SizedBox(height: 8),
        Text(value, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 4),
        Text(title, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}
