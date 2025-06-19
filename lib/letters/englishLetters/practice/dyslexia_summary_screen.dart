// lib/letters/englishLetters/practice/dyslexia_summary_screen.dart

import 'package:flutter/material.dart';
// import your three karaoke screens:
import 'karaoke_sentence_english_screen.dart';
import 'karaoke_sentence_english_level2.dart';
import 'karaoke_sentence_english_level3.dart';

/// A single card describing a dyslexia type (or your final tips card).
class _TypeCard {
  final String title;
  final String emoji;
  final String description;
  final List<String> symptoms;

  const _TypeCard({
    required this.title,
    required this.emoji,
    required this.description,
    required this.symptoms,
  });
}

/// Your full set of dyslexia types + final “What You Can Do” card
const List<_TypeCard> _cards = [
  _TypeCard(
    title: 'Phonological Dyslexia',
    emoji: '🔤',
    description: 'Struggles to break words into sounds and spell them.',
    symptoms: [
      'Poor spelling',
      'Hard to link letters→sounds',
      'Slow sounding out',
      'Avoids reading aloud',
      'Trouble with new words',
    ],
  ),
  _TypeCard(
    title: 'Rapid Naming Dyslexia',
    emoji: '⏱️',
    description: 'Slow at naming letters, numbers or colors, slowing fluency.',
    symptoms: [
      'Hesitation aloud',
      'Skips or swaps words',
      'Slow reading pace',
      'Uses gestures instead',
      'Takes time to answer',
    ],
  ),
  _TypeCard(
    title: 'Double Deficit',
    emoji: '🔀',
    description: 'Has both sound‐and naming difficulties.',
    symptoms: [
      'Weak phonemic awareness',
      'Slow naming speed',
      'Spelling & fluency issues',
    ],
  ),
  _TypeCard(
    title: 'Surface Dyslexia',
    emoji: '👁️',
    description: 'Reads phonetically but can’t sight‐read irregular words.',
    symptoms: [
      'Slow overall rate',
      'Confuses “was” vs “saw”',
      'Struggles with odd spellings',
      'b↔p, d↔q reversals',
      'Small sight vocabulary',
    ],
  ),
  _TypeCard(
    title: 'Visual Dyslexia',
    emoji: '👓',
    description: 'Text may blur, shift or appear double.',
    symptoms: [
      'Loses track of lines',
      'Words seem to wobble',
      'Letters “jump” around',
      'Eyestrain or headaches',
    ],
  ),
  _TypeCard(
    title: 'Developmental Dyslexia',
    emoji: '👶',
    description: 'Runs in families; shows up early.',
    symptoms: [
      'Often genetic',
      'Early school diagnosis',
    ],
  ),
  _TypeCard(
    title: 'Acquired Dyslexia',
    emoji: '⚠️',
    description: 'Occurs after brain trauma or illness.',
    symptoms: [
      'Normal reading before',
      'Language disrupted post-injury',
    ],
  ),
  _TypeCard(
    title: 'What You Can Do',
    emoji: '💡',
    description: 'Steps to boost reading confidence:',
    symptoms: [
      'Get a specialist assessment',
      'Use multisensory programs',
      'Practice daily, briefly',
      'Offer audiobooks/TTS',
      'Celebrate every win! 🎉',
    ],
  ),
];

class DyslexiaSummaryScreen extends StatelessWidget {
  /// All distinct words the user got wrong
  final List<String> wrongWords;

  /// All distinct categories in which they made mistakes
  final List<String> mistakeCategories;

  /// Which karaoke level to return to: 'level1', 'level2' or 'level3'
  final String level;

  const DyslexiaSummaryScreen({
    Key? key,
    required this.wrongWords,
    required this.mistakeCategories,
    required this.level,
  }) : super(key: key);

  /// Build a wrap of colored chips
  Widget _buildChipList(List<String> items, Color color) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: items
          .map((w) => Chip(label: Text(w), backgroundColor: color.withOpacity(0.2)))
          .toList(),
    );
  }

  /// Build each of the dyslexia-type cards
  Widget _buildTypeCard(_TypeCard card) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(card.emoji, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 8),
                Text(card.title,
                    style:
                        const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            Text(card.description, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            ...card.symptoms.map((s) => Row(
                  children: [
                    const Icon(Icons.check, size: 16, color: Colors.green),
                    const SizedBox(width: 6),
                    Expanded(child: Text(s)),
                  ],
                )),
          ],
        ),
      ),
    );
  }

  /// Select the right karaoke screen based on `level`
  Widget _karaokeForLevel() {
    switch (level) {
      case 'level2':
        return const KaraokeSentenceEnglishLevel2Screen();
      case 'level3':
        return const KaraokeSentenceEnglishLevel3Screen();
      case 'level1':
      default:
        return const KaraokeSentenceEnglishScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🔎 Your Mistakes & Tips')),
      body: Column(
        children: [
          // 1) Summary of wrong words & categories
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('You got these words wrong:',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                if (wrongWords.isEmpty)
                  const Text('🎉 None! Great job!',
                      style: TextStyle(fontSize: 16))
                else
                  _buildChipList(wrongWords, Colors.redAccent),
                const SizedBox(height: 16),
                const Text('Areas to practice:',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                if (mistakeCategories.isEmpty)
                  const Text('No specific category mistakes.',
                      style: TextStyle(fontSize: 16))
                else
                  _buildChipList(mistakeCategories, Colors.deepPurpleAccent),
              ],
            ),
          ),

          const Divider(),

          // 2) Dyslexia‐type cards
          Expanded(
            child: ListView.builder(
              itemCount: _cards.length,
              itemBuilder: (_, i) => _buildTypeCard(_cards[i]),
            ),
          ),

          // 3) Back to Karaoke button
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => _karaokeForLevel()),
                );
              },
              child:
                  const Text('Back to Karaoke', style: TextStyle(fontSize: 18)),
            ),
          ),
        ],
      ),
    );
  }
}
