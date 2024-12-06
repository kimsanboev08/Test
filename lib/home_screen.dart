import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'custom_app_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? selectedCategory;
  List<Map<String, dynamic>> allExercises = [];
  List<Map<String, dynamic>> filteredExercises = [];
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchExercises();
  }

  Future<void> fetchExercises() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('exercises').get();
      final exercises = snapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data()})
          .toList(); // Include document ID

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
      if (category == null || category == 'All') {
        filteredExercises = allExercises
            .where((exercise) => exercise['name']
                .toLowerCase()
                .contains(searchController.text.toLowerCase()))
            .toList();
      } else {
        filteredExercises = allExercises
            .where((exercise) =>
                exercise['category'] == category &&
                exercise['name']
                    .toLowerCase()
                    .contains(searchController.text.toLowerCase()))
            .toList();
      }
    });
  }

  void searchExercises(String query) {
    filterExercises(selectedCategory);
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
    return Scaffold(
      appBar: const CustomAppBar(screenTitle: 'Exercises'),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            // Search Bar
            TextField(
              controller: searchController,
              decoration: const InputDecoration(
                labelText: 'Search Exercises',
                border: OutlineInputBorder(),
              ),
              onChanged: searchExercises,
            ),
            const SizedBox(height: 10),
            // Dropdown for Category Filtering
            DropdownButton<String>(
              value: selectedCategory,
              isExpanded: true,
              hint: const Text('Filter by Category'),
              items: [
                const DropdownMenuItem(value: 'All', child: Text('All')),
                const DropdownMenuItem(value: 'Core', child: Text('Core')),
                const DropdownMenuItem(value: 'Arms', child: Text('Arms')),
                const DropdownMenuItem(value: 'Back', child: Text('Back')),
                const DropdownMenuItem(value: 'Chest', child: Text('Chest')),
                const DropdownMenuItem(value: 'Legs', child: Text('Legs')),
                const DropdownMenuItem(
                    value: 'Shoulders', child: Text('Shoulders')),
                const DropdownMenuItem(value: 'Cardio', child: Text('Cardio')),
              ],
              onChanged: (value) {
                filterExercises(value);
              },
            ),
            const SizedBox(height: 10),
            // Exercises List
            Expanded(
              child: filteredExercises.isEmpty
                  ? const Center(
                      child: Text('No exercises found.'),
                    )
                  : ListView.builder(
                      itemCount: filteredExercises.length,
                      itemBuilder: (context, index) {
                        final exercise = filteredExercises[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          color: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            side:
                                BorderSide(color: Colors.grey.withOpacity(0.5)),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(8.0),
                            leading: Container(
                              margin: const EdgeInsets.only(
                                  left: 5), // Margin for image
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.grey.withOpacity(0.5),
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Image.network(
                                exercise['image_url'],
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.image, size: 60),
                              ),
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
                          ),
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
