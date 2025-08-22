import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitness_tracker_app/models/activity.dart' as app_activity;
import 'package:intl/intl.dart';

class DashboardScreen extends StatefulWidget {
  final Function(bool) onGoalStatusChanged;

  const DashboardScreen({super.key, required this.onGoalStatusChanged});

  @override
  State<DashboardScreen> createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  int _dailyExercises = 0;
  int _dailyExerciseGoal = 0;
  final GlobalKey _trophyKey = GlobalKey();
  OverlayEntry? _overlayEntry;

  // This public getter allows the parent (MainScreen) to check the goal status
  bool get isGoalSet => _dailyExerciseGoal > 0;

  @override
  void initState() {
    super.initState();
    // No initial data load needed, FutureBuilder and StreamBuilder handle it
  }

  @override
  void dispose() {
    _removePopup();
    super.dispose();
  }

  // This can be called by the parent to trigger a refetch of the goal
  void refreshActivities() {
    setState(() {
      // Just trigger a rebuild. The FutureBuilder in _buildWelcomeHeader will refetch.
    });
  }

  void _calculateDailyProgress(List<app_activity.Activity> activities) {
    final todayStart = Timestamp.fromDate(DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day));
    int exercisesToday = 0;
    for (var activity in activities) {
      if (activity.date.compareTo(todayStart) >= 0) {
        exercisesToday++;
      }
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _dailyExercises != exercisesToday) {
        setState(() {
          _dailyExercises = exercisesToday;
        });
      }
    });
  }

  void _handleTrophyTap() {
    _showSetGoalDialog();
  }

  void _showSetupPopup() {
    if (_overlayEntry != null || !mounted || _trophyKey.currentContext == null)
      return;
    final RenderBox renderBox =
        _trophyKey.currentContext!.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);
    _overlayEntry = OverlayEntry(
        builder: (context) => Positioned(
            top: position.dy + 50,
            right: 20,
            child: Material(
                color: Colors.transparent,
                child: PlayAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 300),
                    builder: (context, value, child) =>
                        Opacity(opacity: value, child: child),
                    child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                            color: Theme.of(context).hintColor,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              const BoxShadow(
                                  color: Colors.black,
                                  blurRadius: 10,
                                  offset: const Offset(0, 4))
                            ]),
                        child: Text('Set your goal here!',
                            style: TextStyle(
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.black
                                    : Colors.white,
                                fontWeight: FontWeight.bold)))))));
    Overlay.of(context).insert(_overlayEntry!);
    Future.delayed(const Duration(milliseconds: 3000), () => _removePopup());
  }

  void _removePopup() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _showSetGoalDialog() async {
    if (!mounted) return;
    _removePopup();
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final TextEditingController goalController = TextEditingController();
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
                title: Text(_dailyExerciseGoal == 0
                    ? 'Set Your Daily Goal'
                    : 'Change Your Daily Goal'),
                content: TextField(
                    controller: goalController,
                    keyboardType: TextInputType.number,
                    autofocus: true,
                    decoration: InputDecoration(
                        hintText:
                            "e.g., ${_dailyExerciseGoal > 0 ? _dailyExerciseGoal : 3}")),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('CANCEL')),
                  TextButton(
                      onPressed: () async {
                        final int? newGoal = int.tryParse(goalController.text);
                        if (newGoal != null && newGoal > 0) {
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(user.uid)
                              .set({'dailyExerciseGoal': newGoal},
                                  SetOptions(merge: true));
                          refreshActivities();
                          if (!mounted) return;
                          Navigator.of(context).pop();
                        }
                      },
                      child: const Text('SAVE'))
                ]));
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: isDarkMode
            ? const BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color.fromARGB(255, 0, 0, 0), Color(0xFF1A1A1A)]))
            : null,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 70.0),
          child: SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              children: [
                _buildAppBar(),
                const SizedBox(height: 20),
                _buildWelcomeHeader(context),
                const SizedBox(height: 30),
                _buildProgressCard(context),
                const SizedBox(height: 30),
                _buildRecentActivities(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text('FITNESS TRACKING',
          style: Theme.of(context).textTheme.headlineMedium),
      Row(children: [
        IconButton(
            key: _trophyKey,
            icon: Icon(Iconsax.cup, color: Theme.of(context).hintColor),
            onPressed: _handleTrophyTap,
            tooltip: 'Set Daily Goal'),
        const SizedBox(width: 8),
        const CircleAvatar(
          radius: 23,
          backgroundImage: AssetImage('assets/images/logo.png'),
          backgroundColor: Colors.black,
        )
      ])
    ]);
  }

  Widget _buildWelcomeHeader(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Welcome,',
            style:
                Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 28)),
        Text('User!',
            style: Theme.of(context)
                .textTheme
                .headlineLarge
                ?.copyWith(color: Theme.of(context).hintColor))
      ]);
    }

    final Future<DocumentSnapshot<Map<String, dynamic>>> userDocFuture =
        FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: userDocFuture,
        builder: (context, snapshot) {
          String name = 'User';
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData &&
              snapshot.data!.exists) {
            final data = snapshot.data!.data()!;
            name = data['name'] ?? 'User';
            final int goal = data['dailyExerciseGoal'] ?? 0;

            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && _dailyExerciseGoal != goal) {
                setState(() {
                  _dailyExerciseGoal = goal;
                });
                widget.onGoalStatusChanged(goal > 0);
                if (goal == 0) {
                  _showSetupPopup();
                }
              }
            });
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Welcome,',
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(fontSize: 28)),
              Text('$name!',
                  style: Theme.of(context)
                      .textTheme
                      .headlineLarge
                      ?.copyWith(color: Theme.of(context).hintColor)),
            ],
          );
        });
  }

  Widget _buildProgressCard(BuildContext context) {
    double percentage =
        _dailyExerciseGoal > 0 ? _dailyExercises / _dailyExerciseGoal : 0;
    percentage = percentage.clamp(0.0, 1.0);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Daily Progress',
                      style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 8),
                  Text(
                    _dailyExerciseGoal == 0
                        ? 'Set a goal to begin!'
                        : '$_dailyExercises/$_dailyExerciseGoal exercises today',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            CircularPercentIndicator(
              radius: 35.0,
              lineWidth: 8.0,
              percent: percentage,
              center: Text('${(percentage * 100).toInt()}%',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
              progressColor: Theme.of(context).hintColor,
              backgroundColor: Colors.grey.shade300,
              circularStrokeCap: CircularStrokeCap.round,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivities(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Text("Please log in."));
    }
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('activities')
          .orderBy('date', descending: true)
          .limit(10)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text("Error loading activities."));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Text(
                _dailyExerciseGoal == 0
                    ? 'Set a goal and tap the + to begin!'
                    : 'No activities logged yet. Tap the + to begin!',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ),
          );
        }
        final activities = snapshot.data!.docs
            .map((doc) => app_activity.Activity.fromFirestore(doc))
            .toList();
        _calculateDailyProgress(activities);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Recent Activities',
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 15),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: activities.length,
              itemBuilder: (context, index) {
                final activity = activities[index];
                final formattedDate =
                    DateFormat('yyyy-MM-dd').format(activity.date.toDate());
                return Dismissible(
                  key: Key(activity.id!),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (direction) async {
                    return await showDialog<bool>(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                  title: const Text('Confirm Deletion'),
                                  content: Text(
                                      'Are you sure you want to delete the activity "${activity.type}"?'),
                                  actions: <Widget>[
                                    TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(false),
                                        child: const Text('CANCEL')),
                                    TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(true),
                                        child: const Text('DELETE'))
                                  ]);
                            }) ??
                        false;
                  },
                  onDismissed: (direction) {
                    FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .collection('activities')
                        .doc(activity.id)
                        .delete();
                  },
                  background: Container(
                      decoration: BoxDecoration(
                          color: Colors.red.shade700,
                          borderRadius: BorderRadius.circular(16)),
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      alignment: Alignment.centerRight,
                      child: const Icon(Iconsax.trash, color: Colors.white)),
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    color: Theme.of(context).brightness == Brightness.dark
                        ? null
                        : Theme.of(context).colorScheme.secondaryContainer,
                    child: ListTile(
                      leading: Icon(Icons.fitness_center,
                          color: Theme.of(context)
                              .colorScheme
                              .onSecondaryContainer),
                      title: Text(activity.type,
                          style: Theme.of(context).textTheme.titleMedium),
                      subtitle: Text(
                          '${activity.duration} mins - ${activity.calories} kcal',
                          style: Theme.of(context).textTheme.bodySmall),
                      trailing: Text(formattedDate,
                          style: Theme.of(context).textTheme.bodySmall),
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
