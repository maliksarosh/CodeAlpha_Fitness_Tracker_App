import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  String? _selectedGender;
  bool _isLoading = true; // For initial data loading
  bool _isSaving = false; // For the save button action

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // Method to fetch the user's current data from Firestore
  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (userDoc.exists && mounted) {
      final data = userDoc.data()!;
      setState(() {
        _nameController.text = data['name'] ?? '';
        _selectedGender = data['gender'];
        _isLoading = false;
      });
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Method to update the user's data in Firestore
  void _updateUserDetails() async {
    if (_nameController.text.trim().isEmpty || _selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            backgroundColor: Colors.red,
            content: Text('Please fill in all details.')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _isSaving = false;
      });
      return;
    }

    try {
      // Use the 'update' method to change existing fields in the document
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'name': _nameController.text.trim(),
        'gender': _selectedGender,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              backgroundColor: Theme.of(context).hintColor,
              content: Text(
                'Profile updated successfully!',
                style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.black
                        : Colors.white),
              )),
        );
        Navigator.of(context).pop(); // Go back to the settings screen
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              backgroundColor: Colors.red,
              content: Text('Failed to update details: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Edit Profile'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    _buildTextField(
                        label: "Your Name",
                        icon: Iconsax.user,
                        controller: _nameController),
                    const SizedBox(height: 30),
                    _buildGenderSelector(),
                    const SizedBox(height: 60),
                    ElevatedButton(
                      onPressed: _isSaving ? null : _updateUserDetails,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: Theme.of(context).hintColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isSaving
                          ? const CircularProgressIndicator(color: Colors.black)
                          : Text(
                              "Save Changes",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.black
                                    : Colors.white,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildGenderSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Gender",
            style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color,
                fontSize: 16)),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _genderOption(icon: Iconsax.user, label: "Male"),
            _genderOption(icon: Iconsax.woman, label: "Female"),
            _genderOption(icon: Iconsax.people, label: "Other"),
          ],
        )
      ],
    );
  }

  Widget _genderOption({required IconData icon, required String label}) {
    final bool isSelected = _selectedGender == label;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color color = isSelected
        ? Theme.of(context).hintColor
        : (isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200);
    final Color contentColor = isSelected
        ? Theme.of(context).hintColor
        : (isDarkMode ? Colors.white : Colors.black87);

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGender = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 25),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color, width: 1.5),
        ),
        child: Column(
          children: [
            Icon(icon, color: contentColor, size: 30),
            const SizedBox(height: 8),
            Text(label,
                style: TextStyle(
                    color: contentColor, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      {required String label,
      required IconData icon,
      required TextEditingController controller}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 22),
        // Using theme styles for a consistent look
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade600)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                BorderSide(color: Theme.of(context).hintColor, width: 2)),
      ),
    );
  }
}
