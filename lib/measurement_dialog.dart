import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MeasurementDialog extends StatefulWidget {
  const MeasurementDialog({Key? key}) : super(key: key);

  @override
  _MeasurementDialogState createState() => _MeasurementDialogState();
}

class _MeasurementDialogState extends State<MeasurementDialog> {
  final Map<String, TextEditingController> _controllers = {
    'weight': TextEditingController(),
    'calories': TextEditingController(),
    'shoulders': TextEditingController(),
    'neck': TextEditingController(),
    'leftBicep': TextEditingController(),
    'rightBicep': TextEditingController(),
    'leftForearm': TextEditingController(),
    'rightForearm': TextEditingController(),
    'waist': TextEditingController(),
    'leftThigh': TextEditingController(),
    'rightThigh': TextEditingController(),
    'leftCalf': TextEditingController(),
    'rightCalf': TextEditingController(),
  };

  @override
  void initState() {
    super.initState();
    _loadLatestMeasurements();
  }

  Future<void> _loadLatestMeasurements() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;

      if (userId != null) {
        final snapshot = await FirebaseFirestore.instance
            .collection('user_progress')
            .where('userId', isEqualTo: userId)
            .get();

        if (snapshot.docs.isNotEmpty) {
          // Save all documents locally and filter to find the latest
          final allDocuments = snapshot.docs.map((doc) => doc.data()).toList();

          // Sort documents by dateEntered descending
          allDocuments.sort((a, b) {
            final dateA = a['dateEntered']?.toDate();
            final dateB = b['dateEntered']?.toDate();
            return dateB.compareTo(dateA); // Latest date first
          });

          final latestData = allDocuments.first;

          setState(() {
            _controllers.forEach((key, controller) {
              controller.text = latestData[key]?.toString() ?? '';
            });
          });
        }
      }
    } catch (e) {
      print('Error loading measurements: $e');
    }
  }

  Future<void> _saveMeasurements() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;

      if (userId != null) {
        final data = {
          'userId': userId,
          'dateEntered': DateTime.now(),
        };

        _controllers.forEach((key, controller) {
          data[key] = double.tryParse(controller.text) ?? 0.0;
        });

        await FirebaseFirestore.instance.collection('user_progress').add(data);

        Navigator.pop(context); // Close the dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Measurements saved successfully!')),
        );
      }
    } catch (e) {
      print('Error saving measurements: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save measurements.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Body Measurements',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ..._controllers.entries.map((entry) {
                String label = entry.key.replaceAllMapped(
                    RegExp(r'(?<=[a-z])(?=[A-Z])'), (match) => ' ');

                // Add units for specific measurements
                if (entry.key == 'weight')
                  label += ' (lbs)';
                else
                  label += ' (inches)';

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextField(
                    controller: entry.value,
                    decoration: InputDecoration(
                      labelText: label,
                      hintText: 'Enter ${label.toLowerCase()}',
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                );
              }).toList(),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveMeasurements,
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
