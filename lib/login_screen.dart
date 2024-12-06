import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

final _firebase = FirebaseAuth.instance;

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  bool _isSignUpMode = false; // Toggle between Sign In and Sign Up
  bool _isLoading = false;
  File? _selectedImage;
  String? _errorMessage;

  final _imagePicker = ImagePicker();

  void _toggleMode() {
    setState(() {
      _isSignUpMode = !_isSignUpMode;
      _errorMessage = null;
    });
  }

  // Function to pick an image
  Future<void> _pickImage() async {
    final pickedFile =
        await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  // Function to validate email
  bool _isValidEmail(String email) {
    return email.contains('@');
  }

  // Function to validate password
  bool _isValidPassword(String password) {
    final passwordRegex = RegExp(r'^(?=.*[0-9]).{8,}$');
    return passwordRegex.hasMatch(password);
  }

  // Function to validate date of birth
  bool _isValidDOB(String dob) {
    try {
      final parsedDate = DateTime.parse(dob);
      return parsedDate.isBefore(DateTime.now());
    } catch (_) {
      return false;
    }
  }

  // Function to validate username
  bool _isValidUsername(String username) {
    return username.isNotEmpty && username.length >= 4 && username.length <= 12;
  }

  void _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // Additional fields for sign-up mode
    final username = _usernameController.text.trim();
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final dob = _dobController.text.trim();

    // General validation for both sign-in and sign-up
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill out all required fields.')),
      );
      return;
    }

    if (!_isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid email address.')),
      );
      return;
    }

    if (!_isValidPassword(password)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Password must be at least 8 characters long and include at least one number.',
          ),
        ),
      );
      return;
    }

    if (_isSignUpMode) {
      // Additional validation for sign-up
      if (username.isEmpty ||
          firstName.isEmpty ||
          lastName.isEmpty ||
          dob.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please fill out all fields.')),
        );
        return;
      }

      if (!_isValidDOB(dob)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Invalid date of birth. Cannot be in the future.')),
        );
        return;
      }

      if (!_isValidUsername(username)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Username must be between 4 and 12 characters.'),
          ),
        );
        return;
      }

      if (_selectedImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select an image.')),
        );
        return;
      }
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (_isSignUpMode) {
        // Create user in Firebase Auth
        final userCredentials = await _firebase.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Upload the image to Firebase Storage
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('user_images')
            .child('${userCredentials.user!.uid}.jpg');

        await storageRef.putFile(_selectedImage!);
        final imageUrl = await storageRef.getDownloadURL();

        // Save additional user details in Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredentials.user!.uid)
            .set({
          'username': username,
          'email': email,
          'first_name': firstName,
          'last_name': lastName,
          'dob': dob,
          'image': imageUrl,
          'created_at': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Account created successfully!')),
        );

        setState(() {
          _isLoading = false;
        });

        // Navigate to home screen
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        // Log in to existing account
        await _firebase.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login successful!')),
        );

        setState(() {
          _isLoading = false;
        });

        // Navigate to home screen
        Navigator.pushReplacementNamed(context, '/home');
      }
    } on FirebaseAuthException catch (error) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message ?? 'Authentication failed.')),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('An unexpected error occurred. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(_isSignUpMode ? 'Sign Up' : 'Sign In'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _isSignUpMode ? 'Create a new account' : 'Welcome back!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                if (_isSignUpMode) ...[
                  SizedBox(height: 16),
                  TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: 'Username',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _firstNameController,
                    decoration: InputDecoration(
                      labelText: 'First Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _lastNameController,
                    decoration: InputDecoration(
                      labelText: 'Last Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _dobController,
                    decoration: InputDecoration(
                      labelText: 'Date of Birth (YYYY-MM-DD)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: Icon(Icons.image),
                    label: Text('Pick Image'),
                  ),
                  if (_selectedImage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text('Image selected!'),
                    ),
                ],
                SizedBox(height: 16),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 16),
                if (_isLoading)
                  CircularProgressIndicator()
                else
                  ElevatedButton(
                    onPressed: _submit,
                    child: Text(_isSignUpMode ? 'Sign Up' : 'Sign In'),
                  ),
                SizedBox(height: 16),
                TextButton(
                  onPressed: _toggleMode,
                  child: Text(
                    _isSignUpMode
                        ? 'Already have an account? Sign In'
                        : 'Don’t have an account? Sign Up',
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
