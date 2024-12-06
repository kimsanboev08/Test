import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

final ValueNotifier<String?> profileImageNotifier =
    ValueNotifier<String?>(null);

Future<void> fetchUserProfileImage() async {
  try {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists && userDoc.data() != null) {
        final imageUrl = userDoc.data()!['image'];
        profileImageNotifier.value =
            imageUrl; // Update the notifier with the image URL
      } else {
        profileImageNotifier.value = null; // No image found
      }
    }
  } catch (e) {
    print("Error fetching user profile image: $e");
    profileImageNotifier.value = null; // Set to null on error
  }
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String screenTitle;

  const CustomAppBar({Key? key, required this.screenTitle}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Fetch user profile image on app bar build
    fetchUserProfileImage();

    return AppBar(
      backgroundColor: const Color.fromRGBO(197, 211, 210, 1),
      elevation: 0.0,
      leading: ValueListenableBuilder<String?>(
        valueListenable: profileImageNotifier,
        builder: (context, profileImage, child) {
          return Transform.translate(
            offset: const Offset(15, 0),
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[300], // Placeholder background color
                ),
                child: profileImage != null
                    ? ClipOval(
                        child: Image.network(
                          profileImage,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Center(
                            child: Icon(Icons.error, color: Colors.red),
                          ),
                        ),
                      )
                    : Center(
                        child: Icon(
                          Icons.person, // Placeholder icon
                          color: Colors.black54,
                          size: 24.0,
                        ),
                      ),
              ),
            ),
          );
        },
      ),
      title: Padding(
        padding: const EdgeInsets.only(left: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              screenTitle,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        Transform.translate(
          offset: const Offset(-10, 0),
          child: const IconButton(
            onPressed: null,
            icon: Icon(
              CupertinoIcons.bell,
              color: Colors.black,
              size: 26.0,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
