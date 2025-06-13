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
                'Recognized Speech',
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
              Column(
                children: [
                  buildWordBox("✅ Correct:", Colors.green),
                  buildWordBox("❌ Incorrect:", Colors.red),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.refresh, size: 16),
                    label:
                        const Text("Try Again", style: TextStyle(fontSize: 15)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      minimumSize:
                          Size(MediaQuery.of(context).size.width * 0.45, 34),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: widget.onNext,
                    icon: const Icon(Icons.navigate_next, size: 16),
                    label: const Text("Next", style: TextStyle(fontSize: 15)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      minimumSize:
                          Size(MediaQuery.of(context).size.width * 0.45, 34),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
