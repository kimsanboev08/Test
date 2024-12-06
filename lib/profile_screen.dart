import 'package:flutter/material.dart';
import 'custom_app_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'measurement_dialog.dart'; // Import the dialog

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for text fields
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  File? _image;
  String? _originalUsername;
  String? _originalFirstName;
  String? _originalLastName;
  String? _originalDob;
  String? _originalEmail;
  String? _originalImageUrl;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;

      if (userId != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();

        if (userDoc.exists) {
          final userData = userDoc.data();
          setState(() {
            _originalUsername = userData?['username'] ?? '';
            _originalFirstName = userData?['first_name'] ?? '';
            _originalLastName = userData?['last_name'] ?? '';
            _originalDob = userData?['dob'] ?? '';
            _originalEmail = userData?['email'] ?? '';
            _originalImageUrl = userData?['image'];

            _usernameController.text = _originalUsername!;
            _nameController.text = _originalFirstName!;
            _lastNameController.text = _originalLastName!;
            _dobController.text = _originalDob!;
            _emailController.text = _originalEmail!;
          });
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;

      if (userId != null) {
        final updates = <String, dynamic>{
          'username': _usernameController.text.trim(),
          'first_name': _nameController.text.trim(),
          'last_name': _lastNameController.text.trim(),
          'dob': _dobController.text.trim(),
          'email': _emailController.text.trim(),
        };

        if (_image != null) {
          final storageRef = FirebaseStorage.instance
              .ref()
              .child('user_images')
              .child('$userId.jpg');
          await storageRef.putFile(_image!);
          final newImageUrl = await storageRef.getDownloadURL();
          updates['image'] = newImageUrl;
        } else if (_originalImageUrl != null) {
          updates['image'] = _originalImageUrl;
        }

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .set(updates);

        setState(() {
          _originalUsername = updates['username'];
          _originalFirstName = updates['first_name'];
          _originalLastName = updates['last_name'];
          _originalDob = updates['dob'];
          _originalEmail = updates['email'];
          _originalImageUrl = updates['image'];
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Changes saved successfully!')),
        );
      }
    } catch (e) {
      print('Error saving changes: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Failed to save changes. Please try again.')),
      );
    }
  }

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.of(context)
          .pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
    } catch (e) {
      print('Error during logout: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to log out. Please try again.')),
      );
    }
  }

  void _openMeasurementDialog() {
    showDialog(
      context: context,
      builder: (context) => MeasurementDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(screenTitle: 'Profile'),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Profile Image
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: _image != null
                        ? FileImage(_image!) as ImageProvider<Object>?
                        : (_originalImageUrl != null
                            ? NetworkImage(_originalImageUrl!)
                                as ImageProvider<Object>?
                            : null),
                    child: _image == null && _originalImageUrl == null
                        ? const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 30,
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 20),
                // Username Field
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your username';
                    }
                    if (value.trim().length < 4 || value.trim().length > 12) {
                      return 'Username must be between 4 and 12 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                // First Name Field
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'First Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your first name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                // Last Name Field
                TextFormField(
                  controller: _lastNameController,
                  decoration: const InputDecoration(
                    labelText: 'Last Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your last name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                // Date of Birth Field
                TextFormField(
                  controller: _dobController,
                  decoration: const InputDecoration(
                    labelText: 'Date of Birth (YYYY-MM-DD)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your date of birth';
                    }
                    try {
                      final dob = DateTime.parse(value);
                      if (dob.isAfter(DateTime.now())) {
                        return 'Date of birth cannot be in the future';
                      }
                    } catch (_) {
                      return 'Invalid date format';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                // Email Field
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                // Measurement Tracking Button
                ElevatedButton.icon(
                  onPressed: _openMeasurementDialog,
                  icon: const Icon(Icons.straighten),
                  label: const Text('Record Metrics'),
                ),
                const SizedBox(height: 20),
                // Save Changes Button
                ElevatedButton(
                  onPressed: _saveChanges,
                  child: const Text('Save Changes'),
                ),
                const SizedBox(height: 20),
                // Logout Button
                ElevatedButton.icon(
                  onPressed: _logout,
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout'),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.redAccent,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
