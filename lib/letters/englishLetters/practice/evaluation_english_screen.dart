// lib/letters/englishLetters/practice/evaluation_english_screen.dart

import 'package:flutter/material.dart';
import 'practice_mispronounced_screen.dart';

/// Dyslexia–friendly category explanations
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

class EvaluationEnglishScreen extends StatefulWidget {
  final String recognizedText;
  final double score;
  final int stars;
  final Map<String, bool> wordMatchResults;
  final VoidCallback onNext;
  final Map<String, Map<String, String>> wordCategories;

  const EvaluationEnglishScreen({
    Key? key,
    required this.recognizedText,
    required this.score,
    required this.stars,
    required this.wordMatchResults,
    required this.onNext,
    required this.wordCategories,
  }) : super(key: key);

  @override
  _EvaluationEnglishScreenState createState() =>
      _EvaluationEnglishScreenState();
}

class _EvaluationEnglishScreenState extends State<EvaluationEnglishScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  /// Buckets wrong words by category, only if we have a description
  Map<String, List<String>> get _categoryBuckets {
    final buckets = <String, List<String>>{};
    widget.wordMatchResults.forEach((word, correct) {
      if (!correct) {
        final info = widget.wordCategories[word.toLowerCase()] ?? {};
        final cat = info['category'];
        // only include if we actually have a friendly description for it
        if (cat != null && categoryDescriptions.containsKey(cat)) {
          buckets.putIfAbsent(cat, () => []).add(word);
        }
      }
    });
    return buckets;
  }

  List<Widget> _buildStars() => List.generate(
        3,
        (i) => Icon(
          i < widget.stars ? Icons.star : Icons.star_border,
          color: Colors.orange.shade600,
          size: 20,
        ),
      );

  Widget _buildWordBox(String title, Color color) {
    final showCorrect = color == Colors.green;
    final words = widget.wordMatchResults.entries
        .where((e) => e.value == showCorrect)
        .map((e) => e.key)
        .toList();
    if (words.isEmpty) return const SizedBox();
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: color, fontSize: 14)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: words
                .map((w) => Chip(
                      label: Text(w, style: TextStyle(color: color)),
                      backgroundColor: Colors.white,
                      side: BorderSide(color: color),
                    ))
                .toList(),
          )
        ],
      ),
    );
  }

  /// Shows each category (sorted by number of mistakes) with its explanation
  Widget _buildCategoryAreas() {
    final buckets = _categoryBuckets.entries.toList()
      ..sort((a, b) => b.value.length.compareTo(a.value.length));

    if (buckets.isEmpty) return const SizedBox();

    return SizeTransition(
      sizeFactor: CurvedAnimation(
        parent: _animController,
        curve: Curves.easeOutBack,
      ),
      axisAlignment: -1.0,
      child: Card(
        elevation: 4,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Colors.orange.shade50,
        margin: const EdgeInsets.symmetric(vertical: 12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("📚 Learning Spots",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.orange.shade800)),
              const SizedBox(height: 12),
              for (final entry in buckets) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.error_outline,
                        color: Colors.orange.shade600, size: 24),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("📂 ${entry.key}",
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.orange.shade700)),
                          const SizedBox(height: 6),
                          Text(
                            categoryDescriptions[entry.key]!,
                            style: TextStyle(
                                fontSize: 14, color: Colors.orange.shade900),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: entry.value
                                .map((w) => Chip(
                                      label: Text(w,
                                          style: TextStyle(
                                              color:
                                                  Colors.orange.shade700)),
                                      backgroundColor: Colors.orange.shade50,
                                    ))
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ]
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.wordMatchResults.length;
    final correct =
        widget.wordMatchResults.values.where((v) => v).length;
    final mispronounced = widget.wordMatchResults.entries
        .where((e) => !e.value)
        .map((e) => e.key)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('📊 Evaluation'),
        backgroundColor: Colors.orange.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text('Recognized:',
                  style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(widget.recognizedText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.black87)),
              const Divider(height: 24),

              Text('Score: ${widget.score.toStringAsFixed(1)}%',
                  style: TextStyle(fontSize: 18, color: Colors.black87)),
              Text('Correct: $correct / $total',
                  style: TextStyle(fontSize: 16, color: Colors.grey[700])),
              const SizedBox(height: 8),
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _buildStars()),
              const SizedBox(height: 16),

              _buildWordBox("✅ Correct:", Colors.green),
              _buildWordBox("❌ Incorrect:", Colors.red),
              _buildCategoryAreas(),

              const SizedBox(height: 16),

              // Buttons stacked vertically
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: const Text("Try Again"),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade400),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(height: 8),
                  if (mispronounced.isNotEmpty)
                    ElevatedButton.icon(
                      icon: const Icon(Icons.record_voice_over),
                      label: const Text("Practice  Mispronounced Words"),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange.shade400),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PracticeMispronouncedScreen(
                            words: mispronounced,
                            wordCategories: widget.wordCategories,
                          ),
                        ),
                      ),
                    ),
                  if (mispronounced.isNotEmpty) const SizedBox(height: 8),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.navigate_next),
                    label: const Text("Next"),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade400),
                    onPressed: widget.onNext,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
