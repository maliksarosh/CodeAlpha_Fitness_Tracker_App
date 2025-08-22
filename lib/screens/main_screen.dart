import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fitness_tracker_app/screens/dashboard_screen.dart';
import 'package:fitness_tracker_app/screens/history_screen.dart';
import 'package:fitness_tracker_app/screens/profile_screen.dart';
import 'package:fitness_tracker_app/screens/settings_screen.dart';
// THIS IS THE LINE WITH THE FIX
import 'package:fitness_tracker_app/screens/add_activity_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final GlobalKey<DashboardScreenState> _dashboardKey = GlobalKey();

  bool _isGoalSet = false;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      DashboardScreen(
        key: _dashboardKey,
        onGoalStatusChanged: (isSet) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && _isGoalSet != isSet) {
              setState(() {
                _isGoalSet = isSet;
              });
            }
          });
        },
      ),
      const HistoryScreen(),
      const ProfileScreen(),
      const SettingsScreen(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _showAddActivitySheet() {
    if (_isGoalSet) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => AddActivityScreen(
          onActivitySaved: () {
            _dashboardKey.currentState?.refreshActivities();
          },
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.orange.shade800,
          content: const Text(
              'Please set a daily goal first by tapping the trophy icon!'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBody: true,
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddActivitySheet,
        backgroundColor: Theme.of(context).hintColor,
        elevation: 0,
        child: Icon(Iconsax.add,
            color: isDarkMode ? Colors.black : Colors.white, size: 32),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 10.0,
        elevation: 0,
        color: isDarkMode ? const Color(0xFF1F1F1F) : Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildNavItem(
                      outlineIcon: Iconsax.home,
                      boldIcon: Iconsax.home_1,
                      index: 0),
                  _buildNavItem(
                      outlineIcon: Iconsax.clock,
                      boldIcon: Iconsax.clock,
                      index: 1),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildNavItem(
                      outlineIcon: Iconsax.user,
                      boldIcon: Iconsax.user,
                      index: 2),
                  _buildNavItem(
                      outlineIcon: Iconsax.setting_2,
                      boldIcon: Iconsax.setting_3,
                      index: 3),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
      {required IconData outlineIcon,
      required IconData boldIcon,
      required int index}) {
    final isSelected = _selectedIndex == index;
    return IconButton(
      iconSize: 28,
      icon: Icon(isSelected ? boldIcon : outlineIcon,
          color:
              isSelected ? Theme.of(context).hintColor : Colors.grey.shade600),
      onPressed: () => _onItemTapped(index),
      tooltip: _getTooltip(index),
    );
  }

  String _getTooltip(int index) {
    switch (index) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'History';
      case 2:
        return 'Profile';
      case 3:
        return 'Settings';
      default:
        return '';
    }
  }
}
