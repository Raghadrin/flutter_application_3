// lib/letters/englishLetters/practice/dyslexia_summary_screen.dart

import 'package:flutter/material.dart';

/// Helper data class for each card
class _TypeCard {
  final String title, emoji, description;
  final List<String> symptoms;
  const _TypeCard({
    required this.title,
    required this.emoji,
    required this.description,
    required this.symptoms,
  });
}

/// A full set of dyslexia types + a final “What You Can Do” card
const List<_TypeCard> _cards = [
  _TypeCard(
    title: 'Phonological Dyslexia',
    emoji: '🔤',
    description:
      'Struggles to break words into sounds and spell them.',
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
    description:
      'Slow at naming letters, numbers or colors, slowing fluency.',
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
    description:
      'Has both sound‐and naming difficulties.',
    symptoms: [
      'Weak phonemic awareness',
      'Slow naming speed',
      'Spelling & fluency issues',
    ],
  ),
  _TypeCard(
    title: 'Surface Dyslexia',
    emoji: '👁️',
    description:
      'Reads phonetically but can’t sight‐read irregular words.',
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
    description:
      'Text may blur, shift or appear double.',
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
    description:
      'Runs in families; shows up early.',
    symptoms: [
      'Often genetic',
      'Early school diagnosis',
    ],
  ),
  _TypeCard(
    title: 'Acquired Dyslexia',
    emoji: '⚠️',
    description:
      'Occurs after brain trauma or illness.',
    symptoms: [
      'Normal reading before',
      'Language disrupted post-injury',
    ],
  ),
  _TypeCard(
    title: 'What You Can Do',
    emoji: '💡',
    description:
      'Steps to boost reading confidence:',
    symptoms: [
      'Get a specialist assessment',
      'Use multisensory programs',
      'Practice daily, briefly',
      'Offer audiobooks/TTS',
      'Celebrate every win! 🎉',
    ],
  ),
];

class DyslexiaSummaryScreen extends StatefulWidget {
  final List<String> mistakeCategories;

  const DyslexiaSummaryScreen({Key? key, required this.mistakeCategories})
      : super(key: key);

  @override
  _DyslexiaSummaryScreenState createState() => _DyslexiaSummaryScreenState();
}

class _DyslexiaSummaryScreenState extends State<DyslexiaSummaryScreen> {
  final PageController _controller = PageController(viewportFraction: 0.85);
  int _currentPage = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_cards.length, (i) {
        final isActive = i == _currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 12 : 8,
          height: isActive ? 12 : 8,
          decoration: BoxDecoration(
            color:
                isActive ? Colors.orange.shade700 : Colors.orange.shade200,
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🧠 Dyslexia Summary'),
        backgroundColor: Colors.orange.shade700,
      ),
      body: Column(
        children: [
          if (widget.mistakeCategories.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'You had challenges in:\n${widget.mistakeCategories.join(', ')}',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[800]),
              ),
            ),

          Expanded(
            child: PageView.builder(
              controller: _controller,
              onPageChanged: (i) => setState(() => _currentPage = i),
              itemCount: _cards.length,
              itemBuilder: (context, i) {
                final c = _cards[i];
                final isActive = i == _currentPage;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  margin: EdgeInsets.symmetric(
                      vertical: isActive ? 16 : 32, horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.shade300
                            .withOpacity(isActive ? 0.6 : 0.3),
                        blurRadius: isActive ? 24 : 12,
                        spreadRadius: isActive ? 4 : 1,
                      ),
                    ],
                  ),
                  child: Transform.scale(
                    scale: isActive ? 1.0 : 0.9,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Hero(
                              tag: 'card_${c.title}',
                              child: Material(
                                color: Colors.transparent,
                                child: Text(
                                  '${c.emoji}  ${c.title}',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(c.description,
                              style: const TextStyle(fontSize: 16)),
                          const SizedBox(height: 16),

                          // each symptom in its own little box
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: c.symptoms.map((s) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(s,
                                    style: const TextStyle(fontSize: 14)),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(12),
            child: _buildIndicator(),
          ),

          if (_currentPage == _cards.length - 1)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade400,
                  minimumSize: const Size.fromHeight(48),
                ),
                onPressed: () =>
                    Navigator.popUntil(context, (r) => r.isFirst),
                child: const Text('Done', style: TextStyle(fontSize: 18)),
              ),
            ),
        ],
      ),
    );
  }
}
