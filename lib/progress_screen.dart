import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'custom_app_bar.dart';

class ProgressScreen extends StatefulWidget {
  @override
  _ProgressScreenState createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  String? selectedBodyPart;
  String selectedTimePeriod = 'Last 3 Months';
  Map<String, List<Map<String, dynamic>>> progressData = {};

  final List<String> bodyParts = [
    'Weight',
    'Calories',
    'Shoulders',
    'Neck',
    'Left Bicep',
    'Right Bicep',
    'Left Forearm',
    'Right Forearm',
    'Waist',
    'Left Thigh',
    'Right Thigh',
    'Left Calf',
    'Right Calf',
  ];

  final List<String> timePeriods = [
    'Last 3 Months',
    'Last 6 Months',
    'Last Year',
    'Last 2 Years',
  ];

  @override
  void initState() {
    super.initState();
    fetchProgressData();
  }

  Future<void> fetchProgressData() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        final snapshot = await FirebaseFirestore.instance
            .collection('user_progress')
            .where('userId', isEqualTo: userId)
            .get();

        final List<Map<String, dynamic>> allData = snapshot.docs
            .map((doc) => {
                  'date': doc['dateEntered'].toDate(),
                  ...doc.data(),
                })
            .toList();

        // Organize data into progressData map
        final Map<String, List<Map<String, dynamic>>> organizedData = {};
        for (var bodyPart in bodyParts) {
          final dbKey = bodyPart
              .replaceAll(' ', '')
              .toLowerCase(); // Match database field names

          organizedData[bodyPart] = allData
              .where((entry) => entry.containsKey(dbKey))
              .map((entry) => {
                    'date': entry['date'],
                    'value': (entry[dbKey] is int
                            ? (entry[dbKey] as int).toDouble()
                            : entry[dbKey]) ??
                        0.0, // Ensure value is a double
                  })
              .toList()
            ..sort((a, b) => a['date'].compareTo(b['date']));
        }

        setState(() {
          progressData = organizedData;
          selectedBodyPart = bodyParts.first; // Default selection
        });
      }
    } catch (e) {
      print('Error fetching progress data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(screenTitle: 'Progress'),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Body Part Dropdown
                Expanded(
                  child: DropdownButton<String>(
                    value: selectedBodyPart,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedBodyPart = newValue;
                      });
                    },
                    items:
                        bodyParts.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(width: 10),
                // Time Period Dropdown
                Expanded(
                  child: DropdownButton<String>(
                    value: selectedTimePeriod,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedTimePeriod = newValue!;
                      });
                    },
                    items: timePeriods
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Progress Chart
            Expanded(
              child: selectedBodyPart != null &&
                      progressData[selectedBodyPart!] != null &&
                      progressData[selectedBodyPart!]!.isNotEmpty
                  ? LineChart(
                      LineChartData(
                        gridData: FlGridData(show: true),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  value.toStringAsFixed(1),
                                  style: const TextStyle(fontSize: 12),
                                );
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final index = value.toInt();
                                final dates = progressData[selectedBodyPart!]!
                                    .map((e) => e['date'])
                                    .toList();
                                if (index >= 0 && index < dates.length) {
                                  final date = dates[index];
                                  return Text(
                                    '${date.month}/${date.day}',
                                    style: const TextStyle(fontSize: 12),
                                  );
                                }
                                return const Text('');
                              },
                              reservedSize: 32,
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: true),
                        lineBarsData: [
                          LineChartBarData(
                            spots: progressData[selectedBodyPart!]!
                                .asMap()
                                .entries
                                .map((entry) => FlSpot(
                                    entry.key.toDouble(), entry.value['value']))
                                .toList(),
                            isCurved: true,
                            barWidth: 4,
                            color: Colors.blue,
                            belowBarData: BarAreaData(show: false),
                          ),
                        ],
                      ),
                    )
                  : const Center(
                      child: Text(
                        'No data available for this body part.',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
