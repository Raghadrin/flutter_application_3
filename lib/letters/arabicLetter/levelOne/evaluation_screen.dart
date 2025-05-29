import 'package:flutter/material.dart';

class EvaluationScreen extends StatelessWidget {
  final String recognizedText;
  final double score;
  final int stars;
  final Map<String, bool> wordMatchResults;
  final VoidCallback onNext;

  const EvaluationScreen({
    super.key,
    required this.recognizedText,
    required this.score,
    required this.stars,
    required this.wordMatchResults,
    required this.onNext,
  });

  List<Widget> buildStars() => List.generate(
        3,
        (i) => Icon(
          i < stars ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 28,
        ),
      );

  Widget buildWordBox(String title, Color color) {
    final words = wordMatchResults.entries
        .where((entry) =>
            (color == Colors.green && entry.value) ||
            (color == Colors.red && !entry.value))
        .map((entry) => Chip(
              label: Text(entry.key,
                  style: TextStyle(color: color, fontSize: 14)),
              backgroundColor: color.withOpacity(0.2),
            ))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        Wrap(spacing: 4, runSpacing: 4, children: words),
        SizedBox(height: 12),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = wordMatchResults.length;
    final correct = wordMatchResults.values.where((v) => v).length;

    return Scaffold(
      appBar: AppBar(title: Text('📊 نتيجة التقييم')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text('ما تم نطقه:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text(recognizedText,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.blueGrey)),
            Divider(height: 30, thickness: 2),
            Text('التقييم: ${score.toStringAsFixed(1)}%',
                style: TextStyle(fontSize: 22, color: Colors.black87)),
            Text('عدد الكلمات الصحيحة: $correct من $total',
                style: TextStyle(fontSize: 16, color: Colors.grey[700])),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: buildStars(),
            ),
            SizedBox(height: 24),
            buildWordBox("✅ الكلمات الصحيحة:", Colors.green),
            buildWordBox("❌ الكلمات الخاطئة:", Colors.red),
            Spacer(),
            ElevatedButton.icon(
              onPressed: onNext,
              icon: Icon(Icons.navigate_next),
              label: Text("جملة جديدة"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                minimumSize: Size(MediaQuery.of(context).size.width * 0.6, 44),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
