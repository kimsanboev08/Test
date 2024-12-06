import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> populateWorkouts() async {
  final firestore = FirebaseFirestore.instance;

  // Predefined global workouts
  final List<Map<String, dynamic>> globalWorkouts = [
    {'title': 'Beginner Workouts'},
    {'title': 'Advanced Cardio'},
    {'title': 'Full Body Routine'},
    {'title': 'Strength Training'},
    {'title': 'Quick Workouts'},
  ];

  // Associated exercises for each workout
  final Map<String, List<Map<String, dynamic>>> workoutExercises = {
    'Beginner Workouts': [
      // 1
      {
        'exercise': 'Reverse Curl (Dumbbell)',
        'setNumber': 1,
        'reps': 12,
        'weight': 10
      },
      {'exercise': 'Plank', 'setNumber': 1, 'reps': 0, 'weight': 0},
      {'exercise': 'Calf Raise', 'setNumber': 1, 'reps': 15, 'weight': 0},
      {'exercise': 'Lateral Raise', 'setNumber': 1, 'reps': 12, 'weight': 5},
      {'exercise': 'Leg Press', 'setNumber': 1, 'reps': 12, 'weight': 50},

      // 2
      {
        'exercise': 'Reverse Curl (Dumbbell)',
        'setNumber': 2,
        'reps': 12,
        'weight': 10
      },
      {'exercise': 'Plank', 'setNumber': 2, 'reps': 0, 'weight': 0},
      {'exercise': 'Calf Raise', 'setNumber': 2, 'reps': 15, 'weight': 0},
      {'exercise': 'Lateral Raise', 'setNumber': 2, 'reps': 12, 'weight': 5},
      {'exercise': 'Leg Press', 'setNumber': 2, 'reps': 12, 'weight': 50},

      // 3
      {'exercise': 'Calf Raise', 'setNumber': 3, 'reps': 15, 'weight': 0},
      {'exercise': 'Lateral Raise', 'setNumber': 3, 'reps': 12, 'weight': 5},
    ],
    'Advanced Cardio': [
      // 1
      {'exercise': 'Jump Rope', 'setNumber': 1, 'reps': 0, 'weight': 0},
      {'exercise': 'Burpees', 'setNumber': 1, 'reps': 15, 'weight': 0},
      {
        'exercise': 'Mountain Climbers',
        'setNumber': 1,
        'reps': 20,
        'weight': 0
      },
      {'exercise': 'Running', 'setNumber': 1, 'reps': 0, 'weight': 0},

      // 2
      {'exercise': 'Burpees', 'setNumber': 2, 'reps': 15, 'weight': 0},
      {
        'exercise': 'Mountain Climbers',
        'setNumber': 2,
        'reps': 20,
        'weight': 0
      },
    ],
    'Full Body Routine': [
      {'exercise': 'Deadlift', 'setNumber': 1, 'reps': 10, 'weight': 50},
      {
        'exercise': 'Bench Press (Barbell)',
        'setNumber': 1,
        'reps': 8,
        'weight': 40
      },
      {'exercise': 'Plank', 'setNumber': 1, 'reps': 0, 'weight': 0},
      {'exercise': 'Squat (Barbell)', 'setNumber': 1, 'reps': 10, 'weight': 60},
      {'exercise': 'Lateral Raise', 'setNumber': 1, 'reps': 12, 'weight': 5},

      // 2
      {'exercise': 'Deadlift', 'setNumber': 2, 'reps': 10, 'weight': 50},
      {
        'exercise': 'Bench Press (Barbell)',
        'setNumber': 2,
        'reps': 8,
        'weight': 40
      },
      {'exercise': 'Plank', 'setNumber': 2, 'reps': 0, 'weight': 0},
      {'exercise': 'Squat (Barbell)', 'setNumber': 2, 'reps': 10, 'weight': 60},
      {'exercise': 'Lateral Raise', 'setNumber': 2, 'reps': 12, 'weight': 5},

      // 3
      {'exercise': 'Deadlift', 'setNumber': 3, 'reps': 10, 'weight': 50},
      {
        'exercise': 'Bench Press (Barbell)',
        'setNumber': 3,
        'reps': 8,
        'weight': 40
      },
      {'exercise': 'Lateral Raise', 'setNumber': 3, 'reps': 12, 'weight': 5},
    ],
    'Strength Training': [
      {'exercise': 'Deadlift', 'setNumber': 1, 'reps': 8, 'weight': 70},
      {'exercise': 'Squat (Barbell)', 'setNumber': 1, 'reps': 10, 'weight': 80},
      {
        'exercise': 'Bench Press (Barbell)',
        'setNumber': 1,
        'reps': 10,
        'weight': 50
      },
      {
        'exercise': 'Overhead Triceps Extension',
        'setNumber': 1,
        'reps': 12,
        'weight': 10
      },

      // 2
      {'exercise': 'Deadlift', 'setNumber': 2, 'reps': 8, 'weight': 70},
      {'exercise': 'Squat (Barbell)', 'setNumber': 2, 'reps': 10, 'weight': 80},
      {
        'exercise': 'Bench Press (Barbell)',
        'setNumber': 2,
        'reps': 10,
        'weight': 50
      },
      {
        'exercise': 'Overhead Triceps Extension',
        'setNumber': 2,
        'reps': 12,
        'weight': 10
      },
    ],
    'Quick Workouts': [
      {'exercise': 'Jump Rope', 'setNumber': 1, 'reps': 0, 'weight': 0},
      {'exercise': 'Burpees', 'setNumber': 1, 'reps': 20, 'weight': 0},
      {'exercise': 'Plank', 'setNumber': 1, 'reps': 0, 'weight': 0},
      {'exercise': 'Running', 'setNumber': 1, 'reps': 0, 'weight': 0},
    ],
  };

  try {
    // Fetch all exercises from Firestore
    final exerciseSnapshot = await firestore.collection('exercises').get();
    final exercises = {
      for (var doc in exerciseSnapshot.docs) doc.data()['name']: doc.id
    }; // Map exercise name to its ID

    for (var workout in globalWorkouts) {
      // Add workout to `workouts` collection
      final workoutRef = await firestore.collection('workouts').add({
        'title': workout['title'],
        'userId': 'global', // Global identifier for public workouts
      });

      print('Added workout: ${workout['title']} with ID: ${workoutRef.id}');

      // Add exercises for this workout to `workout_exercises` collection
      final exercisesForWorkout = workoutExercises[workout['title']]!;
      for (var exercise in exercisesForWorkout) {
        final exerciseId = exercises[exercise['exercise']];
        if (exerciseId == null) {
          print(
              'Error: Exercise "${exercise['exercise']}" not found in database.');
          continue; // Skip this exercise if it doesn't exist
        }

        await firestore.collection('workout_exercises').add({
          'workoutId': workoutRef.id,
          'exerciseId': exerciseId, // Use exercise ID instead of name
          'setNumber': exercise['setNumber'],
          'reps': exercise['reps'],
          'weight': exercise['weight'],
        });

        print(
            'Added set for exercise ID: $exerciseId in workout: ${workout['title']}');
      }
    }

    print(
        'Workouts and exercises with multiple sets have been successfully populated.');
  } catch (e) {
    print('Error populating workouts: $e');
  }
}
