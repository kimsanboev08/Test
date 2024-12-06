import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ExerciseListPopup extends StatefulWidget {
  final Function(List<Map<String, dynamic>>) onSelectedExercisesChanged;

  const ExerciseListPopup({Key? key, required this.onSelectedExercisesChanged})
      : super(key: key);

  @override
  _ExerciseListPopupState createState() => _ExerciseListPopupState();
}

class _ExerciseListPopupState extends State<ExerciseListPopup> {
  String? selectedCategory;
  List<Map<String, dynamic>> allExercises = [];
  List<Map<String, dynamic>> filteredExercises = [];
  List<Map<String, dynamic>> selectedExercises = []; // Selected exercises list

  @override
  void initState() {
    super.initState();
    fetchExercises();
  }

  Future<void> fetchExercises() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('exercises').get();
      final exercises = snapshot.docs.map((doc) => doc.data()).toList();

      setState(() {
        allExercises = exercises;
        filteredExercises = exercises; // Initially show all exercises
      });
    } catch (e) {
      print('Error fetching exercises: $e');
    }
  }

  void filterExercises(String? category) {
    setState(() {
      selectedCategory = category;
      if (category == null) {
        filteredExercises = allExercises; // Show all if no category is selected
      } else {
        filteredExercises = allExercises
            .where((exercise) => exercise['category'] == category)
            .toList();
      }
    });
  }

  void toggleExerciseSelection(Map<String, dynamic> exercise) {
    setState(() {
      if (selectedExercises.contains(exercise)) {
        selectedExercises.remove(exercise);
      } else {
        selectedExercises.add(exercise);
      }
      widget.onSelectedExercisesChanged(selectedExercises);
    });
  }

  void _showExerciseDetails(
      BuildContext context, Map<String, dynamic> exercise) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ExerciseDetailsPopup(exercise: exercise);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            decoration: const InputDecoration(
              labelText: 'Search Exercises',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Filter by Body Part',
            style: TextStyle(fontSize: 18),
          ),
          Wrap(
            spacing: 8.0,
            children: [
              FilterChip(
                label: const Text('All'),
                selected: selectedCategory == null,
                onSelected: (_) => filterExercises(null),
              ),
              FilterChip(
                label: const Text('Core'),
                selected: selectedCategory == 'Core',
                onSelected: (_) => filterExercises('Core'),
              ),
              FilterChip(
                label: const Text('Arms'),
                selected: selectedCategory == 'Arms',
                onSelected: (_) => filterExercises('Arms'),
              ),
              FilterChip(
                label: const Text('Back'),
                selected: selectedCategory == 'Back',
                onSelected: (_) => filterExercises('Back'),
              ),
              FilterChip(
                label: const Text('Chest'),
                selected: selectedCategory == 'Chest',
                onSelected: (_) => filterExercises('Chest'),
              ),
              FilterChip(
                label: const Text('Legs'),
                selected: selectedCategory == 'Legs',
                onSelected: (_) => filterExercises('Legs'),
              ),
              FilterChip(
                label: const Text('Shoulders'),
                selected: selectedCategory == 'Shoulders',
                onSelected: (_) => filterExercises('Shoulders'),
              ),
              FilterChip(
                label: const Text('Cardio'),
                selected: selectedCategory == 'Cardio',
                onSelected: (_) => filterExercises('Cardio'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Exercises',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: filteredExercises.length,
              itemBuilder: (BuildContext context, int index) {
                final exercise = filteredExercises[index];
                final isSelected = selectedExercises.contains(exercise);

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
                  leading: Image.network(
                    exercise['image_url'],
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.image, size: 60),
                  ),
                  title: Text(
                    exercise['name'],
                    style: const TextStyle(fontSize: 16),
                  ),
                  subtitle: Text(
                    exercise['category'],
                    style: const TextStyle(fontSize: 14),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.help_outline),
                    onPressed: () {
                      _showExerciseDetails(context, exercise);
                    },
                  ),
                  selected: isSelected,
                  selectedTileColor: Colors.grey[200],
                  onTap: () {
                    toggleExerciseSelection(exercise);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ExerciseDetailsPopup extends StatelessWidget {
  final Map<String, dynamic> exercise;

  const ExerciseDetailsPopup({Key? key, required this.exercise})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.network(
              exercise['image_url'],
              width: 300,
              height: 150,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.image, size: 300),
            ),
            const SizedBox(height: 20),
            Text(
              exercise['name'],
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Category: ${exercise['category']}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            Text(
              exercise['description'],
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Close',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
