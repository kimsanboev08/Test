import 'package:flutter/material.dart';

class ProfileImageNotifier extends ValueNotifier<String> {
  ProfileImageNotifier(String value) : super(value);
}

// Create a global instance of the notifier
final profileImageNotifier =
    ProfileImageNotifier('assets/images/uchiha-madara.png');
