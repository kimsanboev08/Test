import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

Future<void> populateExercises() async {
  final List<Map<String, String>> exercises = [
    // Arms
    {
      'name': 'Reverse Curl (Barbell)',
      'category': 'Arms',
      'description':
          'Hold a barbell with an overhand grip, keeping your elbows tucked in. Curl the barbell upward while keeping your upper arms stationary. Lower the barbell back down in a controlled motion.',
      'image': 'ReverseCurlBarbell.jpg'
    },
    {
      'name': 'Reverse Curl (Dumbbell)',
      'category': 'Arms',
      'description':
          'Hold dumbbells with an overhand grip. Keep your elbows close to your body and curl the dumbbells upward. Slowly lower the dumbbells back to the starting position.',
      'image': 'ReverseCurlDumbbell.jpg'
    },
    {
      'name': 'Concentration Curl',
      'category': 'Arms',
      'description':
          'Sit on a bench, hold a dumbbell in one hand, and place your elbow on the inside of your thigh. Curl the dumbbell upward, keeping control.',
      'image': 'ConcentrationCurl.jpg'
    },
    {
      'name': 'Hammer Curl',
      'category': 'Arms',
      'description':
          'Hold a dumbbell in each hand with a neutral grip. Curl the dumbbells upward while keeping your palms facing inward.',
      'image': 'HammerCurl.jpg'
    },
    {
      'name': 'Triceps Kickback',
      'category': 'Arms',
      'description':
          'Hold a dumbbell in each hand. Bend forward slightly and extend your arms backward, straightening them completely.',
      'image': 'TricepsKickback.jpg'
    },
    {
      'name': 'Zottman Curl',
      'category': 'Arms',
      'description':
          'Hold dumbbells with a neutral grip. Curl them upward with palms up, then rotate your grip and lower them slowly with palms down.',
      'image': 'ZottmanCurl.jpg'
    },
    {
      'name': 'Overhead Triceps Extension',
      'category': 'Arms',
      'description':
          'Hold a dumbbell with both hands and raise it overhead. Lower it behind your head by bending your elbows, then extend your arms back to the starting position.',
      'image': 'OverheadTricepsExtension.jpg'
    },

    // Shoulders
    {
      'name': 'Reverse Fly (Dumbbell)',
      'category': 'Shoulders',
      'description':
          'Hold a dumbbell in each hand and hinge at the hips. Keep your back straight and raise the dumbbells outward while maintaining a slight bend in your elbows. Lower them back slowly.',
      'image': 'ReverseFlyDumbbell.jpg'
    },
    {
      'name': 'Lateral Raise',
      'category': 'Shoulders',
      'description':
          'Hold dumbbells at your sides. Lift your arms outward to shoulder height with a slight bend in your elbows, then lower slowly.',
      'image': 'LateralRaise.jpg'
    },
    {
      'name': 'Front Raise',
      'category': 'Shoulders',
      'description':
          'Hold a dumbbell in each hand at thigh level. Lift one arm forward to shoulder height, then lower and repeat with the other arm.',
      'image': 'FrontRaise.jpg'
    },
    {
      'name': 'Arnold Press',
      'category': 'Shoulders',
      'description':
          'Start with dumbbells at chest level with palms facing inward. Rotate your palms outward while pressing the dumbbells overhead.',
      'image': 'ArnoldPress.jpg'
    },

    // Chest
    {
      'name': 'Bench Press (Barbell)',
      'category': 'Chest',
      'description':
          'Lie on a bench and grip the barbell slightly wider than shoulder-width. Lower the bar to your chest and push it back up.',
      'image': 'BenchPressBarbell.jpg'
    },
    {
      'name': 'Incline Bench Press',
      'category': 'Chest',
      'description':
          'Lie on an incline bench and press a barbell or dumbbells upward. Lower them slowly back to your chest.',
      'image': 'InclineBenchPress.jpg'
    },
    {
      'name': 'Chest Dip',
      'category': 'Chest',
      'description':
          'Use parallel bars to lower your body while keeping your elbows close. Push yourself back up.',
      'image': 'ChestDip.jpg'
    },
    {
      'name': 'Cable Chest Fly',
      'category': 'Chest',
      'description':
          'Stand between two cable machines and pull the handles inward in a fly motion, bringing your hands together at chest level.',
      'image': 'CableChestFly.jpg'
    },

    // Back
    {
      'name': 'Lat Pulldown',
      'category': 'Back',
      'description':
          'Use a lat pulldown machine to pull the bar down to your chest while keeping your back straight.',
      'image': 'LatPulldown.jpg'
    },
    {
      'name': 'Deadlift',
      'category': 'Back',
      'description':
          'Stand with your feet shoulder-width apart, grip a barbell, and lift it by straightening your hips and knees.',
      'image': 'Deadlift.jpg'
    },
    {
      'name': 'Bent-Over Row',
      'category': 'Back',
      'description':
          'Hold a barbell or dumbbells. Bend your torso forward and pull the weights toward your lower chest.',
      'image': 'BentOverRow.jpg'
    },
    {
      'name': 'Cable Row',
      'category': 'Back',
      'description':
          'Sit at a cable row machine and pull the handle toward your torso while keeping your back straight.',
      'image': 'CableRow.jpg'
    },

    // Legs
    {
      'name': 'Squat (Barbell)',
      'category': 'Legs',
      'description':
          'Place a barbell on your upper back. Lower your body by bending your knees and hips, then stand back up.',
      'image': 'SquatBarbell.jpg'
    },
    {
      'name': 'Leg Press',
      'category': 'Legs',
      'description':
          'Sit on a leg press machine and push the platform upward by extending your knees.',
      'image': 'LegPress.jpg'
    },
    {
      'name': 'Calf Raise',
      'category': 'Legs',
      'description':
          'Stand on the edge of a platform or step. Raise your heels as high as possible, then lower them back down.',
      'image': 'CalfRaise.jpg'
    },

    // Core
    {
      'name': 'Plank',
      'category': 'Core',
      'description':
          'Hold your body in a straight line with your forearms on the ground and your toes supporting you.',
      'image': 'Plank.jpg'
    },
    {
      'name': 'Russian Twist',
      'category': 'Core',
      'description':
          'Sit on the ground with your knees bent. Hold a weight and twist your torso side to side.',
      'image': 'RussianTwist.jpg'
    },
    {
      'name': 'Bicycle Crunch',
      'category': 'Core',
      'description':
          'Lie on your back and bring your knees up. Alternate touching your elbow to the opposite knee.',
      'image': 'BicycleCrunch.jpg'
    },
    {
      'name': 'Side Plank',
      'category': 'Core',
      'description':
          'Lie on one side and prop yourself up with your forearm. Keep your body in a straight line.',
      'image': 'SidePlank.jpg'
    },

    // Cardio
    {
      'name': 'Running',
      'category': 'Cardio',
      'description':
          'Run at a comfortable pace, either on a treadmill or outdoors.',
      'image': 'Running.jpg'
    },
    {
      'name': 'Jump Rope',
      'category': 'Cardio',
      'description':
          'Hold a jump rope and swing it under your feet while jumping.',
      'image': 'JumpRope.jpg'
    },
    {
      'name': 'Burpees',
      'category': 'Cardio',
      'description':
          'Start in a standing position, drop into a squat, kick your feet back into a plank, then return to standing.',
      'image': 'Burpees.jpg'
    }
  ];

  for (var exercise in exercises) {
    try {
      // Fetch the image URL from Firebase Storage
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('exercises')
          .child(exercise['image']!);
      final imageUrl = await storageRef.getDownloadURL();

      // Add the exercise to Firestore with the fetched image URL
      await FirebaseFirestore.instance.collection('exercises').add({
        'name': exercise['name'],
        'category': exercise['category'],
        'description': exercise['description'],
        'image_url': imageUrl, // Use the actual download URL
      });

      print('Added exercise: ${exercise['name']}');
    } catch (e) {
      print('Error adding exercise: ${exercise['name']} - $e');
    }
  }

  print('All exercises have been processed.');
}
