// Updated EvaluationEnglishScreen with old visual style and overflow fix

import 'package:flutter/material.dart';
import 'practice_mispronounced_screen.dart';

const Map<String, String> categoryDescriptions = {
  'Time': '⏰ Time words help us know when things happen, like “before” or “after.”',
  'Connectors/Other': '🔗 Connector words link ideas and sentences together.',
  'Action Verbs': '🏃 Action words tell us what someone or something does.',
  'Objects': '📦 Object words name things you can touch or see.',
  'Descriptive Words': '🎨 Descriptive words paint a picture of size, color, or feeling.',
  'Daily Life': '🍽️ Daily Life words are about things we do every day.',
  'People': '🧑‍🤝‍🧑 People words name characters or groups of people.',
  'School Vocabulary': '🎒 School words are about what you learn and do at school.',
  'Animals': '🐾 Animal words name creatures big and small.',
  'Weather': '☔️ Weather words talk about rain, sun, clouds, and wind.',
  'Places': '📍 Place words tell us where things happen.',
  'Body Parts': '🦵 Body Part words name parts of your body.',
  'Nature': '🍃 Nature words are about the world around us.',
  'Action Nouns': '📣 Action Nouns are sounds or movements you can see or hear.',
  'Nouns': '📝 Nouns name ideas or things you cannot always see.',
  'Concepts': '💡 Concepts are special ideas or questions in a sentence.',
  'Space Vocabulary': '🌌 Space words talk about stars, planets, and rockets.',
  'Clothing': '👕 Clothing words name what we wear.',
  'Emotion/Support': '❤️ Emotion words show how we feel inside.',
};

class EvaluationEnglishScreen extends StatelessWidget {
  final String recognizedText;
  final double score;
  final int stars;
  final Map<String, bool> wordMatchResults;
  final VoidCallback onNext;
  final Map<String, Map<String, String>> wordCategories;
  final String level;

  const EvaluationEnglishScreen({
    Key? key,
    required this.recognizedText,
    required this.score,
    required this.stars,
    required this.wordMatchResults,
    required this.onNext,
    required this.wordCategories,
    required this.level,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final wrongWords = wordMatchResults.entries.where((e) => !e.value).map((e) => e.key).toList();
    final correctWords = wordMatchResults.entries.where((e) => e.value).map((e) => e.key).toList();

    final mistakeCategories = wrongWords
        .map((w) => wordCategories[w]?['category'])
        .whereType<String>()
        .toSet()
        .toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange.shade700,
        title: const Text('📊 Evaluation'),
      ),
      backgroundColor: const Color(0xFFFFF8F1),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(child: Text('Recognized:', style: Theme.of(context).textTheme.titleSmall)),
            const SizedBox(height: 4),
            Center(child: Text(recognizedText, textAlign: TextAlign.center)),
            const Divider(height: 32),
            Center(
              child: Column(
                children: [
                  Text('Score: ${score.toStringAsFixed(1)}%', style: const TextStyle(fontSize: 20)),
                  Text('Correct: ${correctWords.length} / ${wordMatchResults.length}'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (i) => Icon(i < stars ? Icons.star : Icons.star_border, color: Colors.amber)),
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.green.shade200),
                borderRadius: BorderRadius.circular(12),
                color: Colors.green.shade50,
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('✔️ Correct:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Wrap(spacing: 8, runSpacing: 6, children: correctWords.map((w) => Chip(label: Text(w))).toList()),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.red.shade200),
                borderRadius: BorderRadius.circular(12),
                color: Colors.red.shade50,
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('❌ Incorrect:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Wrap(spacing: 8, runSpacing: 6, children: wrongWords.map((w) => Chip(label: Text(w))).toList()),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (mistakeCategories.isNotEmpty)
              Container(
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('📚 Learning Spots', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    for (final cat in mistakeCategories)
                      if (categoryDescriptions[cat]?.isNotEmpty == true)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('📁 $cat', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(categoryDescriptions[cat]!, style: const TextStyle(fontSize: 13)),
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 8,
                                runSpacing: 6,
                                children: wrongWords
                                    .where((w) => wordCategories[w]?['category'] == cat)
                                    .map((w) => Chip(label: Text(w)))
                                    .toList(),
                              )
                            ],
                          ),
                        ),
                  ],
                ),
              ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              onPressed: () => Navigator.pop(context),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange.shade300),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.record_voice_over),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent),
              onPressed: wrongWords.isEmpty
                  ? null
                  : () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => PracticeMispronouncedScreen(
                            words: wrongWords,
                            wordCategories: wordCategories,
                            maxAttempts: 3,
                            level: level,
                          ),
                        ),
                      );
                    },
              label: const Text('Practice Mispronounced Words'),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.navigate_next),
              onPressed: onNext,
              label: const Text('Next'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent),
            ),
          ],
        ),
      ),
    );
  }
}
