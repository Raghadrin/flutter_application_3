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
  String selectedSubject = 'All'; // new filter option

  List<Map<String, dynamic>> get filteredAttempts {
    if (selectedSubject == 'All') return quizAttempts;
    return quizAttempts.where((a) => a['subject'] == selectedSubject).toList();
  }

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
    for (int i = 0; i < filteredAttempts.length; i++) {
      final score = (filteredAttempts[i]['score'] as num).toDouble();
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
                          title: Text(' Child: ${childData!['name']}',
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
                      DropdownButton<String>(
                        value: selectedSubject,
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() {
                            selectedSubject = value;
                          });
                        },
                        items: [
                          const DropdownMenuItem(
                              value: 'All', child: Text('All Subjects')),
                          ...['arabic', 'math', 'english']
                              .map((subj) => DropdownMenuItem(
                                    value: subj,
                                    child: Text(
                                      subj[0].toUpperCase() + subj.substring(1),
                                      style: GoogleFonts.poppins(),
                                    ),
                                  )),
                        ],
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
                          height: 250,
                          child: LineChart(
                            LineChartData(
                              minY: 0,
                              maxY: 100,
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: false,
                                getDrawingHorizontalLine: (value) => FlLine(
                                  color:
                                      isDark ? Colors.white24 : Colors.black12,
                                  strokeWidth: 1,
                                ),
                              ),
                              titlesData: FlTitlesData(
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 40,
                                    getTitlesWidget: (value, _) => Text(
                                      '${value.toInt()}%',
                                      style: TextStyle(
                                          color: textColor, fontSize: 12),
                                    ),
                                  ),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, _) {
                                      int index = value.toInt();
                                      if (index < filteredAttempts.length) {
                                        final date = filteredAttempts[index]
                                                ['timestamp']
                                            ?.toDate();
                                        return Text(
                                          date != null
                                              ? '${date.month}/${date.day}'
                                              : '${index + 1}',
                                          style: TextStyle(
                                              color: textColor, fontSize: 10),
                                        );
                                      }
                                      return const Text('');
                                    },
                                    reservedSize: 30,
                                  ),
                                ),
                                topTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false)),
                                rightTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false)),
                              ),
                              borderData: FlBorderData(
                                show: true,
                                border:
                                    Border.all(color: Colors.grey, width: 1),
                              ),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: _buildScoreSpots(),
                                  isCurved: true,
                                  color: isDark
                                      ? Colors.orangeAccent
                                      : Colors.deepPurple,
                                  barWidth: 4,
                                  belowBarData: BarAreaData(
                                    show: true,
                                    color: (isDark
                                            ? Colors.orangeAccent
                                            : Colors.deepPurple)
                                        .withOpacity(0.2),
                                  ),
                                  // dotData: FlDotData(
                                  //   show: true,
                                  //   dotSize: 4,
                                  //   dotColor: isDark
                                  //       ? Colors.amber
                                  //       : Colors.deepPurple,
                                  // ),
                                )
                              ],
                              lineTouchData: LineTouchData(
                                touchTooltipData: LineTouchTooltipData(
                                  tooltipBgColor: Colors.black.withOpacity(0.7),
                                  getTooltipItems: (touchedSpots) {
                                    return touchedSpots.map((touchedSpot) {
                                      final score =
                                          touchedSpot.y.toStringAsFixed(1);
                                      return LineTooltipItem(
                                        'Score: $score%',
                                        TextStyle(color: Colors.white),
                                      );
                                    }).toList();
                                  },
                                ),
                                touchCallback: (event, _) {},
                                handleBuiltInTouches: true,
                              ),
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
                          itemCount: filteredAttempts.length,
                          itemBuilder: (context, index) {
                            final attempt = filteredAttempts[index];
                            final subject = attempt['subject'] ?? 'Unknown';
                            final level = attempt['level'] ?? 'N/A';
                            final score =
                                (attempt['score'] as num?)?.toDouble() ?? 0;
                            final timestamp = attempt['timestamp']?.toDate();
                            final formattedDate = timestamp != null
                                ? '${timestamp.day}/${timestamp.month}/${timestamp.year}'
                                : 'N/A';

                            IconData icon;
                            Color iconColor;

                            switch (subject) {
                              case 'math':
                                icon = Icons.calculate;
                                iconColor = Colors.blue;
                                break;
                              case 'arabic':
                                icon = Icons.language;
                                iconColor = Colors.orange;
                                break;
                              case 'english':
                                icon = Icons.translate;
                                iconColor = Colors.green;
                                break;
                              default:
                                icon = Icons.help_outline;
                                iconColor = Colors.grey;
                            }

                            return Card(
                              elevation: 3,
                              margin: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor:
                                          iconColor.withOpacity(0.1),
                                      child: Icon(icon, color: iconColor),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Subject: ${subject[0].toUpperCase()}${subject.substring(1)}',
                                            style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Level: $level',
                                            style: GoogleFonts.poppins(
                                                fontSize: 14),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Date: $formattedDate',
                                            style: GoogleFonts.poppins(
                                              fontSize: 13,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: score >= 80
                                            ? Colors.green[100]
                                            : Colors.red[100],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        '${score.toStringAsFixed(0)}%',
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.bold,
                                          color: score >= 80
                                              ? Colors.green[800]
                                              : Colors.red[800],
                                        ),
                                      ),
                                    ),
                                  ],
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
