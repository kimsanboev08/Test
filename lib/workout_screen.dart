import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'custom_app_bar.dart';
import 'workout_details_dialog.dart';
import 'exercise_list.dart';

class WorkoutScreen extends StatefulWidget {
  WorkoutScreen({Key? key}) : super(key: key);

  @override
  _WorkoutScreenState createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  final List<Map<String, dynamic>> selectedExercises =
      []; // Stores selected exercises
  List<Map<String, dynamic>> customWorkouts = []; // Stores custom workouts
  final TextEditingController workoutNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchCustomWorkouts(); // Fetch user workouts on initialization
  }

  Future<void> _fetchCustomWorkouts() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('workouts')
          .where('userId', isEqualTo: userId)
          .get();

      setState(() {
        customWorkouts = snapshot.docs.map((doc) {
          return {
            'id': doc.id,
            'title': doc.data()['title'],
          };
        }).toList();
      });
    } catch (e) {
      print('Error fetching custom workouts: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchGlobalWorkouts() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('workouts')
        .where('userId', isEqualTo: 'global')
        .get();

    return snapshot.docs
        .map((doc) => {
              'id': doc.id,
              'title': doc.data()['title'],
            })
        .toList();
  }

  void _saveWorkout() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final workoutName = workoutNameController.text.trim();

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in!')),
      );
      return;
    }

    if (workoutName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Workout name is required!')),
      );
      return;
    }

    try {
      final workoutRef =
          await FirebaseFirestore.instance.collection('workouts').add({
        'userId': userId,
        'title': workoutName,
      });

      final workoutId = workoutRef.id;

      final exerciseNames = selectedExercises.map((e) => e['name']).toSet();
      final exercisesSnapshot = await FirebaseFirestore.instance
          .collection('exercises')
          .where('name', whereIn: exerciseNames.toList())
          .get();

      final exerciseIdMap = {
        for (var doc in exercisesSnapshot.docs) doc['name']: doc.id
      };

      for (var exercise in selectedExercises) {
        final exerciseId = exerciseIdMap[exercise['name']];
        if (exerciseId == null) continue;

        for (int i = 1; i <= exercise['sets']; i++) {
          await FirebaseFirestore.instance.collection('workout_exercises').add({
            'workoutId': workoutId,
            'exerciseId': exerciseId,
            'setNumber': i,
            'reps': 0,
            'weight': 0,
          });
        }
      }

      setState(() {
        customWorkouts.add({
          'id': workoutId,
          'title': workoutName,
        });
        selectedExercises.clear();
        workoutNameController.clear();
      });

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Workout saved successfully!')),
      );
    } catch (e) {
      print('Error saving workout: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save workout.')),
      );
    }
  }

  void _showAddExercisePrompt(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.9,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Add Workout Name',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  TextField(
                    controller: workoutNameController,
                    decoration: const InputDecoration(
                      labelText: 'Workout Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      _showExerciseList(context, setModalState);
                    },
                    child: const Text('Add Exercises'),
                  ),
                  const SizedBox(height: 20),
                  if (selectedExercises.isNotEmpty)
                    Expanded(
                      child: ListView.builder(
                        itemCount: selectedExercises.length,
                        itemBuilder: (context, index) {
                          final exercise = selectedExercises[index];
                          return ListTile(
                            leading: Image.network(
                              exercise['image_url'],
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.image, size: 60),
                            ),
                            title: Text(exercise['name']),
                            subtitle: Text(exercise['category']),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Sets: ${exercise['sets']}',
                                  style: const TextStyle(fontSize: 14),
                                ),
                                const SizedBox(width: 10),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline),
                                  onPressed: () {
                                    setState(() {
                                      exercise['sets'] += 1;
                                    });
                                    setModalState(() {});
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ElevatedButton(
                    onPressed: _saveWorkout,
                    child: const Text('Save'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showExerciseList(BuildContext context, StateSetter setModalState) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return ExerciseListPopup(
          onSelectedExercisesChanged: (selectedExercises) {
            setState(() {
              for (var exercise in selectedExercises) {
                if (!exercise.containsKey('sets')) {
                  exercise['sets'] = 1;
                }
              }
              this.selectedExercises.clear();
              this.selectedExercises.addAll(selectedExercises);
            });
            setModalState(() {});
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(screenTitle: 'Workouts'),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'My Sets',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: CarouselSlider(
                options: CarouselOptions(
                  height: 200,
                  enlargeCenterPage: true,
                  enableInfiniteScroll: false,
                  viewportFraction: 0.7,
                ),
                items: [
                  ...customWorkouts.asMap().entries.map((entry) {
                    final index = entry.key;
                    final workout = entry.value;
                    final imageName =
                        'assets/images/w${(index % 5) + 1}.jpg'; // Cycle through w1.jpg to w5.jpg

                    return GestureDetector(
                      onTap: () {
                        showWorkoutDetailsDialog(
                          context,
                          workout['id'],
                          workout['title'],
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 5.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15.0),
                          image: DecorationImage(
                            image: AssetImage(imageName),
                            fit: BoxFit.cover,
                          ),
                          border: Border.all(
                            color: Colors.grey.shade400, // Outline color
                            width: 2, // Outline width
                          ),
                        ),
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              workout['title'],
                              style: const TextStyle(
                                fontSize: 18.0,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                  // Add button to carousel
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 5.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15.0),
                      color: Colors.grey.withOpacity(0.2),
                    ),
                    child: InkWell(
                      onTap: () {
                        _showAddExercisePrompt(context);
                      },
                      child: const Center(
                        child: Icon(Icons.add, size: 60.0, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                'Our Collections',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: fetchGlobalWorkouts(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Center(
                        child: Text('Error fetching workouts.'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No workouts found.'));
                  }

                  final workouts = snapshot.data!;

                  // Map global workout titles to images
                  final Map<String, String> workoutImages = {
                    'Quick Workouts': 'assets/images/quick.jpg',
                    'Full Body Routine': 'assets/images/fullBody.jpg',
                    'Strength Training': 'assets/images/strength.jpg',
                    'Advanced Cardio': 'assets/images/cardio.png',
                    'Beginner Workouts': 'assets/images/beginner.png',
                  };

                  return ListView.builder(
                    scrollDirection: Axis.vertical,
                    itemCount: workouts.length,
                    itemBuilder: (context, index) {
                      final workout = workouts[index];
                      final imagePath = workoutImages[workout['title']] ??
                          'assets/images/test.jpg'; // Default image if title not found

                      return InkWell(
                        onTap: () => showWorkoutDetailsDialog(
                          context,
                          workout['id'],
                          workout['title'],
                        ),
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            vertical: 8.0,
                            horizontal: 10.0,
                          ),
                          height: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15.0),
                            image: DecorationImage(
                              image: AssetImage(imagePath),
                              fit: BoxFit.cover,
                            ),
                            border: Border.all(
                              color: Colors.grey
                                  .shade400, // Outline color for visibility
                              width: 2, // Border width
                            ),
                          ),
                          child: Center(
                            child: Text(
                              workout['title'],
                              style: const TextStyle(
                                fontSize: 18.0,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                backgroundColor: Colors.black54,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
