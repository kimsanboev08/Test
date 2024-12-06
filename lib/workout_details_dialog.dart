import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';

Future<Map<String, dynamic>> fetchWorkoutExercises(String workoutId) async {
  final exercisesSnapshot = await FirebaseFirestore.instance
      .collection('workout_exercises')
      .where('workoutId', isEqualTo: workoutId)
      .get();

  final exerciseIds =
      exercisesSnapshot.docs.map((doc) => doc.data()['exerciseId']).toSet();

  final exercises = await FirebaseFirestore.instance
      .collection('exercises')
      .where(FieldPath.documentId, whereIn: exerciseIds.toList())
      .get();

  final Map<String, Map<String, dynamic>> exerciseMap = {};

  for (var doc in exercisesSnapshot.docs) {
    final exerciseId = doc.data()['exerciseId'];
    final setNumber = doc.data()['setNumber'];

    if (exerciseMap.containsKey(exerciseId)) {
      exerciseMap[exerciseId]!['totalSets']++;
    } else {
      final exerciseData =
          exercises.docs.firstWhere((e) => e.id == exerciseId).data();
      exerciseMap[exerciseId] = {
        'exerciseName': exerciseData['name'],
        'exerciseCategory': exerciseData['category'],
        'exerciseImage': exerciseData['image_url'],
        'totalSets': 1,
        'setDetails': [],
      };
    }

    exerciseMap[exerciseId]!['setDetails'].add({
      'setNumber': setNumber,
      'reps': 0,
      'weight': 0,
    });
  }

  return exerciseMap;
}

void showWorkoutDetailsDialog(
    BuildContext context, String workoutId, String workoutTitle) async {
  final exerciseMap = await fetchWorkoutExercises(workoutId);

  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                workoutTitle,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView(
                  children: exerciseMap.values.map((exercise) {
                    return ListTile(
                      leading: Image.network(
                        exercise['exerciseImage'],
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.image, size: 60),
                      ),
                      title: Text(
                        '${exercise['totalSets']} x ${exercise['exerciseName']}',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(exercise['exerciseCategory']),
                    );
                  }).toList(),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close the current popup
                  showWorkoutTrackingPopup(
                    context,
                    workoutTitle,
                    workoutId,
                    exerciseMap.values.toList().cast<Map<String, dynamic>>(),
                  );
                },
                child: const Text('Start Workout'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      );
    },
  );
}

void showWorkoutTrackingPopup(BuildContext context, String workoutTitle,
    String workoutId, List<Map<String, dynamic>> exercises) {
  final Map<String, List<TextEditingController>> repsControllers = {};
  final Map<String, List<TextEditingController>> weightControllers = {};

  for (var exercise in exercises) {
    repsControllers[exercise['exerciseName']] = [];
    weightControllers[exercise['exerciseName']] = [];

    for (var i = 0; i < exercise['totalSets']; i++) {
      repsControllers[exercise['exerciseName']]!.add(TextEditingController());
      weightControllers[exercise['exerciseName']]!.add(TextEditingController());
    }
  }

  void _completeWorkout(
      BuildContext context,
      String workoutId,
      String workoutTitle,
      List<Map<String, dynamic>> exercises,
      Map<String, List<TextEditingController>> repsControllers,
      Map<String, List<TextEditingController>> weightControllers) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in!')),
      );
      return;
    }

    final completedDate = DateTime.now();
    final random = Random();
    final newId = random.nextInt(999999).toString(); // Generate a unique ID

    try {
      // Add to workouts_completed collection
      await FirebaseFirestore.instance.collection('workouts_completed').add({
        'userId': userId,
        'workoutId': workoutId,
        'newId': newId,
        'completedDate': completedDate,
      });

      // Map exercise names to IDs from Firestore
      final exerciseNames = exercises.map((e) => e['exerciseName']).toSet();
      final exercisesSnapshot = await FirebaseFirestore.instance
          .collection('exercises')
          .where('name', whereIn: exerciseNames.toList())
          .get();

      final exerciseIdMap = {
        for (var doc in exercisesSnapshot.docs) doc['name']: doc.id
      };

      // Save exercises to the workout_exercises_completed collection
      for (var exercise in exercises) {
        final exerciseId = exerciseIdMap[exercise['exerciseName']];
        if (exerciseId == null) continue; // Skip if no matching ID is found

        final setDetails = exercise['setDetails'];
        for (var setIndex = 0; setIndex < setDetails.length; setIndex++) {
          final reps = int.tryParse(
                  repsControllers[exercise['exerciseName']]![setIndex].text) ??
              0; // Fetch from input or default to 0
          final weight = double.tryParse(
                  weightControllers[exercise['exerciseName']]![setIndex]
                      .text) ??
              0.0; // Fetch from input or default to 0.0

          await FirebaseFirestore.instance
              .collection('workout_exercises_completed')
              .add({
            'newId': newId,
            'exerciseId': exerciseId,
            'setNumber': setIndex + 1,
            'reps': reps,
            'weight': weight,
          });
        }
      }

      Navigator.pop(context); // Close the workout tracking popup
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Workout completed successfully!')),
      );
    } catch (e) {
      print('Error completing workout: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to complete workout.')),
      );
    }
  }

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.grey[100],
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
    ),
    builder: (context) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 60,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Workout: $workoutTitle',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: exercises.length,
                itemBuilder: (context, index) {
                  final exercise = exercises[index];
                  final totalSets = exercise['totalSets'];

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            exercise['exerciseName'],
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          Table(
                            columnWidths: const {
                              0: FlexColumnWidth(1),
                              1: FlexColumnWidth(2),
                              2: FlexColumnWidth(2),
                            },
                            border: TableBorder.all(
                              color: Colors.grey.withOpacity(0.5),
                              width: 0.5,
                            ),
                            children: [
                              TableRow(
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                      'Set',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                      'Weight',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                      'Reps',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                              ...List.generate(totalSets, (setIndex) {
                                return TableRow(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        '${setIndex + 1}',
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: TextField(
                                        controller: weightControllers[exercise[
                                            'exerciseName']]![setIndex],
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 8.0, vertical: 4.0),
                                          hintText: 'Weight',
                                        ),
                                        keyboardType: TextInputType.number,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: TextField(
                                        controller: repsControllers[exercise[
                                            'exerciseName']]![setIndex],
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 8.0, vertical: 4.0),
                                          hintText: 'Reps',
                                        ),
                                        keyboardType: TextInputType.number,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                );
                              }),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                _completeWorkout(
                  context,
                  workoutId,
                  workoutTitle,
                  exercises,
                  repsControllers,
                  weightControllers,
                );
                Navigator.pop(context); // Close the tracking popup
              },
              child: const Text('Complete Workout'),
            ),
          ],
        ),
      );
    },
  );
}
