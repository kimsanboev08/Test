import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> populateProgress() async {
  final firestore = FirebaseFirestore.instance;

  // User ID
  //const userId = 'hKHqwRJjWjTtuVHCqFChwxcOUvm1';
  const userId = "TbIYjzPNsMU9Lguhli5Axaofh292";

  // Starting date (first entry in September)
  DateTime startingDate = DateTime(2024, 9, 1);

  // Progress data to insert
  List<Map<String, dynamic>> progressData = [
    {
      'weight': 150.0,
      'calories': 2000,
      'shoulders': 40.0,
      'neck': 15.0,
      'leftBicep': 12.0,
      'rightBicep': 12.0,
      'leftForearm': 10.0,
      'rightForearm': 10.0,
      'waist': 32.0,
      'leftThigh': 20.0,
      'rightThigh': 20.0,
      'leftCalf': 15.0,
      'rightCalf': 15.0,
    },
    {
      'weight': 152.0,
      'calories': 2100,
      'shoulders': 41.0,
      'neck': 15.2,
      'leftBicep': 12.5,
      'rightBicep': 12.5,
      'leftForearm': 10.5,
      'rightForearm': 10.5,
      'waist': 31.8,
      'leftThigh': 21.0,
      'rightThigh': 21.0,
      'leftCalf': 15.2,
      'rightCalf': 15.2,
    },
    {
      'weight': 155.0,
      'calories': 2200,
      'shoulders': 42.0,
      'neck': 15.5,
      'leftBicep': 13.0,
      'rightBicep': 13.0,
      'leftForearm': 11.0,
      'rightForearm': 11.0,
      'waist': 31.5,
      'leftThigh': 22.0,
      'rightThigh': 22.0,
      'leftCalf': 15.5,
      'rightCalf': 15.5,
    },
    {
      'weight': 157.0,
      'calories': 2300,
      'shoulders': 43.0,
      'neck': 15.8,
      'leftBicep': 13.5,
      'rightBicep': 13.5,
      'leftForearm': 11.5,
      'rightForearm': 11.5,
      'waist': 31.2,
      'leftThigh': 23.0,
      'rightThigh': 23.0,
      'leftCalf': 15.8,
      'rightCalf': 15.8,
    },
    {
      'weight': 160.0,
      'calories': 2400,
      'shoulders': 44.0,
      'neck': 16.0,
      'leftBicep': 14.0,
      'rightBicep': 14.0,
      'leftForearm': 12.0,
      'rightForearm': 12.0,
      'waist': 31.0,
      'leftThigh': 24.0,
      'rightThigh': 24.0,
      'leftCalf': 16.0,
      'rightCalf': 16.0,
    },
  ];

  try {
    final collection = FirebaseFirestore.instance.collection('user_progress');

    for (int i = 0; i < progressData.length; i++) {
      final progress = progressData[i];
      final dateEntered =
          startingDate.add(Duration(days: i * 14)); // Two-week intervals

      await collection.add({
        'userId': userId,
        'dateEntered': dateEntered,
        ...progress,
      });

      print('Progress document ${i + 1} added for date: $dateEntered');
    }

    print('All progress documents added successfully!');
  } catch (e) {
    print('Error adding progress data: $e');
  }
}
