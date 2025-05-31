import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class EvaluationEnglishScreen extends StatefulWidget {
  final String recognizedText;
  final double score;
  final int stars;
  final Map<String, bool> wordMatchResults;
  final VoidCallback onNext;
  final dynamic level;

  const EvaluationEnglishScreen({
    super.key,
    required this.recognizedText,
    required this.score,
    required this.stars,
    required this.level,
    required this.wordMatchResults,
    required this.onNext,
  });

  @override
  State<EvaluationEnglishScreen> createState() =>
      _EvaluationEnglishScreenState();
}

class _EvaluationEnglishScreenState extends State<EvaluationEnglishScreen> {
  String? parentId;
  String? childId;
  List<double> last5Scores = [];

  @override
  void initState() {
    super.initState();
    fetchPreviousAttempts();
  }

  Future<void> fetchPreviousAttempts() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    parentId = user.uid;

    final childrenSnapshot = await FirebaseFirestore.instance
        .collection('parents')
        .doc(parentId)
        .collection('children')
        .get();

    if (childrenSnapshot.docs.isEmpty) return;

    childId = childrenSnapshot.docs.first.id;

    final attemptsSnapshot = await FirebaseFirestore.instance
        .collection('parents')
        .doc(parentId)
        .collection('children')
        .doc(childId)
        .collection('karaoke')
        .doc('enKaraoke') // <-- Note this for English
        .collection(widget.level.toString())
        .orderBy('timestamp', descending: true)
        .limit(5)
        .get();

    setState(() {
      last5Scores = attemptsSnapshot.docs.reversed
          .map((doc) => (doc['score'] as num).toDouble())
          .toList();
    });
  }

  List<Widget> buildStars() => List.generate(
        3,
        (i) => Icon(
          i < widget.stars ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 16,
        ),
      );

  Widget buildWordBox(String title, Color color) {
    final isCorrect = color == Colors.green;
    final wordList = widget.wordMatchResults.entries
        .where((entry) => entry.value == isCorrect)
        .map((entry) => entry.key)
        .toList();

    if (wordList.isEmpty) {
      return const SizedBox(); // No box if no words
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: wordList.map((word) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: color),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  word,
                  style: TextStyle(fontSize: 12, color: color),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  String getFeedback() {
    if (last5Scores.length < 2) return "Keep trying to receive feedback.";

    final improvement = last5Scores.last - last5Scores.first;
    if (improvement >= 10) return "Excellent! Great improvement 👏";
    if (improvement >= 3) return "Good job, keep training 👍";
    return "Try to focus more next time 💪";
  }

  Widget buildChart() {
    if (last5Scores.isEmpty) {
      return const Text(
        "Not enough data for chart.",
        style: TextStyle(fontSize: 12),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          "📊 Last attempts:",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.deepPurple,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.deepPurple.shade50,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.15),
                spreadRadius: 1,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(12),
          child: AspectRatio(
            aspectRatio: 1.8,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 100,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: Colors.deepPurpleAccent.withOpacity(0.8),
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${rod.toY.toStringAsFixed(1)}%',
                        const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 20,
                      reservedSize: 32,
                      getTitlesWidget: (value, meta) => Text(
                        '${value.toInt()}%',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) => Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'Try ${value.toInt() + 1}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ),
                  rightTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.grey[300],
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(last5Scores.length, (index) {
                  final value = last5Scores[index];
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: value,
                        width: 20,
                        borderRadius: BorderRadius.circular(8),
                        gradient: LinearGradient(
                          colors: [Colors.deepPurple, Colors.deepPurpleAccent],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(getFeedback(), style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.wordMatchResults.length;
    final correct = widget.wordMatchResults.values.where((v) => v).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('📊 Evaluation', style: TextStyle(fontSize: 18)),
        centerTitle: true,
        toolbarHeight: 40,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Text(
                'Recognized Speech:',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                widget.recognizedText,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: Colors.blueGrey),
              ),
              const Divider(height: 20, thickness: 1),
              Text(
                'Score: ${widget.score.toStringAsFixed(1)}%',
                style: const TextStyle(fontSize: 19, color: Colors.black87),
              ),
              Text(
                'Correct Words: $correct out of $total',
                style: TextStyle(fontSize: 19, color: Colors.grey[700]),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: buildStars(),
              ),
              const SizedBox(height: 12),
              buildWordBox("✅ Correct:", Colors.green),
              buildWordBox("❌ Incorrect:", Colors.red),
              buildChart(),
              ElevatedButton.icon(
                onPressed: widget.onNext,
                icon: const Icon(Icons.navigate_next, size: 16),
                label: const Text("Next", style: TextStyle(fontSize: 15)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  minimumSize:
                      Size(MediaQuery.of(context).size.width * 0.45, 34),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
