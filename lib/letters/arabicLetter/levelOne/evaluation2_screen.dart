import 'package:flutter/material.dart';

class Evaluation2Screen extends StatelessWidget {
  final String recognizedText;
  final double score;
  final int stars;
  final Map<String, bool> wordMatchResults;
  final VoidCallback onNext;

  const Evaluation2Screen({
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
          size: 16, // ⬅️ أصغر من قبل
        ),
      );

  Widget buildWordBox(String title, Color color) {
    final words = wordMatchResults.entries
        .where((entry) =>
            (color == Colors.green && entry.value) ||
            (color == Colors.red && !entry.value))
        .map((entry) => Chip(
              label: Text(entry.key,
                  style: TextStyle(color: color, fontSize: 10)), // ⬅️ أصغر
              backgroundColor: color.withOpacity(0.2),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            ))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.bold, color: color)), // ⬅️ أصغر
        Wrap(spacing: 3, runSpacing: 3, children: words),
        const SizedBox(height: 6),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = wordMatchResults.length;
    final correct = wordMatchResults.values.where((v) => v).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('📊 التقييم', style: TextStyle(fontSize: 16)), // ⬅️ أصغر
        centerTitle: true,
        toolbarHeight: 40,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            const Text('ما قيل:',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(recognizedText,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: Colors.blueGrey)),
            const Divider(height: 20, thickness: 1),
            Text('النسبة: ${score.toStringAsFixed(1)}%',
                style: const TextStyle(fontSize: 14, color: Colors.black87)),
            Text('كلمات صحيحة: $correct من $total',
                style: TextStyle(fontSize: 12, color: Colors.grey[700])),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: buildStars(),
            ),
            const SizedBox(height: 12),
            buildWordBox("✅ صحيح:", Colors.green),
            buildWordBox("❌ خطأ:", Colors.red),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: onNext,
              icon: const Icon(Icons.navigate_next, size: 16),
              label: const Text("التالي", style: TextStyle(fontSize: 12)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                minimumSize: Size(MediaQuery.of(context).size.width * 0.45, 34),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
