import 'package:flutter/material.dart';

class EvaluationEnglishScreen extends StatelessWidget {
  final String recognizedText;
  final double score;
  final int stars;
  final String level;
  final Map<String, bool> wordMatchResults;
  final VoidCallback onNext;

  const EvaluationEnglishScreen({
    Key? key,
    required this.recognizedText,
    required this.score,
    required this.stars,
    required this.level,
    required this.wordMatchResults,
    required this.onNext,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int totalWords = wordMatchResults.length;
    int correctWords = wordMatchResults.values.where((v) => v).length;

    return Scaffold(
      appBar: AppBar(title: const Text('📊 Evaluation')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Recognized Speech:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                recognizedText,
                style: const TextStyle(fontSize: 16),
              ),
            ),

            const SizedBox(height: 30),

            // Centered Result Info
            Column(
              children: [
                Text(
                  'Score: ${score.toStringAsFixed(1)}%',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Correct words: $correctWords / $totalWords',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    3,
                    (index) => Icon(
                      Icons.star,
                      color: index < stars ? Colors.amber : Colors.grey[300],
                      size: 28,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            const Text(
              '✅ Correct Words:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: wordMatchResults.entries
                  .where((e) => e.value)
                  .map(
                    (e) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        border: Border.all(color: Colors.green),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        e.key,
                        style: TextStyle(color: Colors.green[900]),
                      ),
                    ),
                  )
                  .toList(),
            ),

            const SizedBox(height: 24),

            const Text(
              '❌ Incorrect Words:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: wordMatchResults.entries
                  .where((e) => !e.value)
                  .map(
                    (e) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.red[100],
                        border: Border.all(color: Colors.red),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        e.key,
                        style: TextStyle(color: Colors.red[900]),
                      ),
                    ),
                  )
                  .toList(),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 244, 183, 70),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(fontSize: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Next'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
