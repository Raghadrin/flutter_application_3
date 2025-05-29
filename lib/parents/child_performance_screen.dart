import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CombinedChildPerformanceScreen extends StatefulWidget {
  final bool isDarkMode;
  const CombinedChildPerformanceScreen({super.key, this.isDarkMode = false});

  @override
  State<CombinedChildPerformanceScreen> createState() =>
      _CombinedChildPerformanceScreenState();
}

class _CombinedChildPerformanceScreenState
    extends State<CombinedChildPerformanceScreen> {
  Map<String, dynamic>? childData;
  List<Map<String, dynamic>> quizAttempts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChildAndAttempts();
  }

  Future<void> _loadChildAndAttempts() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      final parentId = user.uid;

      final childrenSnapshot = await FirebaseFirestore.instance
          .collection('parents')
          .doc(parentId)
          .collection('children')
          .get();

      if (childrenSnapshot.docs.isEmpty) return;

      final childDoc = childrenSnapshot.docs.first;
      final childId = childDoc.id;
      childData = childDoc.data();

      final Map<String, List<String>> subjectLevels = {
        'arabic': ['arabic1', 'arabic2', 'arabic3'],
        'math': ['math1', 'math2'],
        'english': ['english1', 'english2'],
      };

      List<Map<String, dynamic>> allAttempts = [];
      for (var subject in subjectLevels.keys) {
        for (var level in subjectLevels[subject]!) {
          final snapshot = await FirebaseFirestore.instance
              .collection('parents')
              .doc(parentId)
              .collection('children')
              .doc(childId)
              .collection(subject)
              .doc(level)
              .collection('attempts')
              .get();

          for (var doc in snapshot.docs) {
            final data = doc.data();
            data['subject'] = subject;
            data['level'] = level;
            allAttempts.add(data);
          }
        }
      }

      allAttempts.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));

      setState(() {
        quizAttempts = allAttempts;
        isLoading = false;
      });
    } catch (e) {
      print("Error: $e");
      setState(() => isLoading = false);
    }
  }

  List<FlSpot> _buildScoreSpots() {
    List<FlSpot> spots = [];
    for (int i = 0; i < quizAttempts.length; i++) {
      final score = (quizAttempts[i]['score'] as num).toDouble();
      spots.add(FlSpot(i.toDouble(), score));
    }
    return spots;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;
    final bgColor = isDark ? const Color(0xFF1F1B2E) : Colors.grey[100];
    final textColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Child Performance'),
        backgroundColor: isDark ? Colors.deepPurple : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.deepOrange,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : childData == null
              ? const Center(child: Text("No child selected."))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        color: isDark ? Colors.deepPurple[400] : Colors.white,
                        child: ListTile(
                          title: Text('👦 Child: ${childData!['name']}',
                              style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: textColor)),
                          subtitle: Text('Performance Overview',
                              style: GoogleFonts.poppins(
                                  color: textColor.withOpacity(0.7))),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (quizAttempts.isNotEmpty) ...[
                        Text('📈 Score Progression:',
                            style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: textColor)),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 200,
                          child: LineChart(
                            LineChartData(
                              titlesData: FlTitlesData(
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, _) => Text(
                                        '${value.toInt() + 1}',
                                        style: TextStyle(color: textColor)),
                                  ),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: true),
                                ),
                              ),
                              borderData: FlBorderData(show: true),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: _buildScoreSpots(),
                                  isCurved: true,
                                  barWidth: 3,
                                  color: isDark
                                      ? Colors.orange
                                      : Colors.deepPurple,
                                  belowBarData: BarAreaData(show: false),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      Text('📋 Attempts:',
                          style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textColor)),
                      const SizedBox(height: 10),
                      Expanded(
                        child: ListView.builder(
                          itemCount: quizAttempts.length,
                          itemBuilder: (context, index) {
                            final attempt = quizAttempts[index];
                            final timestamp = attempt['timestamp']?.toDate();
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              child: ListTile(
                                leading: const Icon(Icons.check_circle,
                                    color: Colors.green),
                                title: Text(
                                    '${attempt['score']}% in ${attempt['subject']} - ${attempt['level']}',
                                    style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w500)),
                                subtitle: Text(
                                    'Date: ${timestamp?.toString().split(' ').first ?? 'N/A'}'),
                              ),
                            );
                          },
                        ),
                      )
                    ],
                  ),
                ),
    );
  }
}
