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
          size: 20, // ⬅️ أصغر
        ),
      );

  Widget buildWordBox(String title, Color color) {
    final words = wordMatchResults.entries
        .where((entry) =>
            (color == Colors.green && entry.value) ||
            (color == Colors.red && !entry.value))
        .map((entry) => Chip(
              label: Text(entry.key,
                  style: TextStyle(color: color, fontSize: 12)), // ⬅️ أصغر
              backgroundColor: color.withOpacity(0.2),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            ))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.bold, color: color)), // ⬅️ أصغر
        Wrap(spacing: 4, runSpacing: 4, children: words),
        const SizedBox(height: 8),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = wordMatchResults.length;
    final correct = wordMatchResults.values.where((v) => v).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('📊 نتيجة التقييم', style: TextStyle(fontSize: 18)), // ⬅️ أصغر
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('ما تم نطقه:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(recognizedText,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Colors.blueGrey)),
            const Divider(height: 24, thickness: 1.5),
            Text('التقييم: ${score.toStringAsFixed(1)}%',
                style: const TextStyle(fontSize: 16, color: Colors.black87)),
            Text('عدد الكلمات الصحيحة: $correct من $total',
                style: TextStyle(fontSize: 13, color: Colors.grey[700])),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: buildStars(),
            ),
            const SizedBox(height: 16),
            buildWordBox("✅ الكلمات الصحيحة:", Colors.green),
            buildWordBox("❌ الكلمات الخاطئة:", Colors.red),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: onNext,
              icon: const Icon(Icons.navigate_next, size: 18),
              label: const Text("جملة جديدة", style: TextStyle(fontSize: 14)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                minimumSize: Size(MediaQuery.of(context).size.width * 0.5, 38), // ⬅️ أصغر
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
