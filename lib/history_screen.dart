import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'custom_app_bar.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  Future<Map<String, List<Map<String, dynamic>>>> fetchGroupedWorkouts() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return {};
    }

    final completedWorkoutsSnapshot = await FirebaseFirestore.instance
        .collection('workouts_completed')
        .where('userId', isEqualTo: userId)
        .get();

    final List<Map<String, dynamic>> workouts = [];

    for (var workoutDoc in completedWorkoutsSnapshot.docs) {
      final workoutId = workoutDoc.data()['workoutId'];
      final newId = workoutDoc.data()['newId'];
      final completedDate = workoutDoc.data()['completedDate'];

      // Parse the date
      final date = (completedDate as Timestamp).toDate();

      // Fetch workout details
      final workoutSnapshot = await FirebaseFirestore.instance
          .collection('workouts')
          .doc(workoutId)
          .get();

      final workoutName = workoutSnapshot.data()?['title'] ?? 'Unknown Workout';

      // Fetch exercises completed
      final exercisesSnapshot = await FirebaseFirestore.instance
          .collection('workout_exercises_completed')
          .where('newId', isEqualTo: newId)
          .get();

      final exercises = <Map<String, dynamic>>[];

      for (var exerciseDoc in exercisesSnapshot.docs) {
        final exerciseId = exerciseDoc.data()['exerciseId'];
        final setNumber = exerciseDoc.data()['setNumber'];

        // Fetch exercise details
        final exerciseSnapshot = await FirebaseFirestore.instance
            .collection('exercises')
            .doc(exerciseId)
            .get();

        final exerciseName =
            exerciseSnapshot.data()?['name'] ?? 'Unknown Exercise';

        exercises.add({
          'exerciseName': exerciseName,
          'setNumber': setNumber,
        });
      }

      workouts.add({
        'monthYearKey': DateFormat.yMMMM().format(date),
        'workoutName': workoutName,
        'completedDate': date, // Keep the raw date for sorting
        'formattedDate': DateFormat.yMMMd().format(date),
        'exercises': exercises,
      });
    }

    // Sort workouts by completedDate in descending order
    workouts.sort((a, b) => b['completedDate'].compareTo(a['completedDate']));

    // Group workouts by month and year
    final Map<String, List<Map<String, dynamic>>> groupedWorkouts = {};
    for (var workout in workouts) {
      final monthYearKey = workout['monthYearKey'];

      if (!groupedWorkouts.containsKey(monthYearKey)) {
        groupedWorkouts[monthYearKey] = [];
      }

      groupedWorkouts[monthYearKey]!.add(workout);
    }

    return groupedWorkouts;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(screenTitle: 'History'),
      body: FutureBuilder<Map<String, List<Map<String, dynamic>>>>(
        future: fetchGroupedWorkouts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(
              child: Text('Error fetching workout history.'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No completed workouts found.'),
            );
          }

          final groupedWorkouts = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: groupedWorkouts.keys.length,
            itemBuilder: (context, index) {
              final monthYear = groupedWorkouts.keys.elementAt(index);
              final workouts = groupedWorkouts[monthYear]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Month and Year Header
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      monthYear,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ...workouts.map((workout) {
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      padding: const EdgeInsets.all(15),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        border: Border.all(color: Colors.grey.withOpacity(0.5)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            workout['workoutName'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            workout['formattedDate'],
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 10),
                          ...workout['exercises'].map<Widget>((exercise) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 2.0),
                              child: Text(
                                '${exercise['setNumber']} x ${exercise['exerciseName']}',
                                style: const TextStyle(fontSize: 16),
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    );
                  }),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
