import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitness_tracker_app/models/activity.dart' as app_activity;

class AddActivityScreen extends StatefulWidget {
  final VoidCallback onActivitySaved;
  const AddActivityScreen({super.key, required this.onActivitySaved});
  @override
  State<AddActivityScreen> createState() => _AddActivityScreenState();
}

class _AddActivityScreenState extends State<AddActivityScreen> {
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _caloriesController = TextEditingController();
  bool _isLoading = false;
  @override
  void dispose() {
    _typeController.dispose();
    _durationController.dispose();
    _caloriesController.dispose();
    super.dispose();
  }

  Future<void> _saveActivity() async {
    FocusScope.of(context).unfocus();
    if (_typeController.text.trim().isEmpty ||
        _durationController.text.isEmpty ||
        _caloriesController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            backgroundColor: Colors.red,
            content: Text('Please fill all fields.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Handle user not logged in case
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final newActivity = app_activity.Activity(
      type: _typeController.text.trim(),
      duration: int.tryParse(_durationController.text.trim()) ?? 0,
      calories: int.tryParse(_caloriesController.text.trim()) ?? 0,
      date: Timestamp.now(), // Use a Firestore Timestamp
    );

    try {
      // Add the new activity to the 'activities' sub-collection of the current user
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('activities')
          .add(newActivity.toMap());

      widget.onActivitySaved();

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              backgroundColor: Colors.red,
              content: Text('Failed to save activity.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF2C2C2E)
            : Colors.white,
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(25), topRight: Radius.circular(25)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Add New Activity',
                  style: Theme.of(context).textTheme.headlineMedium),
              IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop()),
            ],
          ),
          const SizedBox(height: 25),
          _buildTextField(
              label: 'Workout Type',
              icon: Iconsax.activity,
              controller: _typeController),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                  child: _buildTextField(
                      label: 'Duration (min)',
                      icon: Iconsax.clock,
                      keyboardType: TextInputType.number,
                      controller: _durationController)),
              const SizedBox(width: 20),
              Expanded(
                  child: _buildTextField(
                      label: 'Calories Burned',
                      icon: Iconsax.flash_1,
                      keyboardType: TextInputType.number,
                      controller: _caloriesController)),
            ],
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _saveActivity,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).hintColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.black)
                  : Text('Save Activity',
                      style: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.black
                              : Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18)),
            ),
          ),
          Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom)),
        ],
      ),
    );
  }

  Widget _buildTextField(
      {required String label,
      required IconData icon,
      required TextEditingController controller,
      TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 22),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.grey, width: 1.5)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade600, width: 1.5)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                BorderSide(color: Theme.of(context).hintColor, width: 2)),
      ),
    );
  }
}
