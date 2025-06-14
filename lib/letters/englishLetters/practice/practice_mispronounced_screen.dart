import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'dyslexia_summary_screen.dart';

class PracticeMispronouncedScreen extends StatefulWidget {
  final List<String> words;
  final Map<String, Map<String, String>> wordCategories;
  final int maxAttempts;

  const PracticeMispronouncedScreen({
    Key? key,
    required this.words,
    required this.wordCategories,
    this.maxAttempts = 3,
  }) : super(key: key);

  @override
  _PracticeMispronouncedScreenState createState() =>
      _PracticeMispronouncedScreenState();
}

class _PracticeMispronouncedScreenState
    extends State<PracticeMispronouncedScreen>
    with TickerProviderStateMixin {
  late FlutterTts _tts;
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _lastResult = '';
  int _currentIndex = 0;
  late int _attemptsLeft;
  int? _wordScore;
  int? _wordStars;

  /// Collect every mis-pronounced word's category
  final Set<String> _mistakeCategories = {};

  final List<String> _encourage = [
    'I’m proud of you! 💖',
    'Keep going, champ! 🌟',
    'You can do it! 👍',
    'Every try is progress! 🌱',
  ];

  late AnimationController _fbController;
  late Animation<Offset> _fbOffset;

  @override
  void initState() {
    super.initState();
    _tts = FlutterTts()..setLanguage('en-US');
    _speech = stt.SpeechToText();
    _attemptsLeft = widget.maxAttempts;

    _fbController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fbOffset = Tween<Offset>(
      begin: const Offset(0, 1.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _fbController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _fbController.dispose();
    super.dispose();
  }

  String get _word => widget.words[_currentIndex];
  Map<String, String> get _info =>
      widget.wordCategories[_word.toLowerCase()] ?? {};
  String get _category => _info['category'] ?? 'Unknown';
  String get _description => _info['description'] ?? '';
  String get _enc => _encourage[
      min(widget.maxAttempts - _attemptsLeft, _encourage.length - 1)];

  double get _computedScore {
    final used = widget.maxAttempts - _attemptsLeft + 1;
    if (used <= 0) return 0;
    return ((widget.maxAttempts - used + 1) / widget.maxAttempts) * 100;
  }

  int get _computedStars {
    final s = _computedScore.round();
    if (s >= 90) return 3;
    if (s >= 60) return 2;
    if (s > 0) return 1;
    return 0;
  }

  Future<void> _speak() => _tts.speak(_word);

  Future<void> _toggleListen() async {
    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
      _evaluate(_lastResult);
    } else {
      final ok = await _speech.initialize();
      if (!ok) return;
      setState(() {
        _isListening = true;
        _lastResult = '';
      });
      _speech.listen(
        localeId: 'en_US',
        onResult: (r) => setState(() => _lastResult = r.recognizedWords),
      );
    }
  }

  void _showBanner(String msg, {bool success = false}) async {
    final entry = OverlayEntry(builder: (_) {
      return Positioned(
        bottom: 0, left: 0, right: 0,
        child: SlideTransition(
          position: _fbOffset,
          child: Material(
            color: success ? Colors.green.shade300 : Colors.orange.shade300,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(msg,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.black, fontSize: 16)),
            ),
          ),
        ),
      );
    });
    Overlay.of(context)!.insert(entry);
    await _fbController.forward();
    await Future.delayed(const Duration(seconds: 2));
    await _fbController.reverse();
    entry.remove();
  }

  void _evaluate(String spoken) {
    if (spoken.trim().toLowerCase() == _word.toLowerCase()) {
      _wordScore = _computedScore.round();
      _wordStars = _computedStars;
      _showBanner('Perfect! Score: $_wordScore%', success: true);
    } else {
      _mistakeCategories.add(_category);
      _attemptsLeft--;
      if (_attemptsLeft > 0) {
        _showBanner('Not quite—$_attemptsLeft tries left. $_enc');
      } else {
        _wordScore = 0;
        _wordStars = 0;
        _showBanner('Let’s try next time! Score: 0%', success: false);
      }
    }
  }

  void _next() {
    if (_currentIndex < widget.words.length - 1) {
      setState(() {
        _currentIndex++;
        _attemptsLeft = widget.maxAttempts;
        _lastResult = '';
        _wordScore = null;
        _wordStars = null;
      });
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => DyslexiaSummaryScreen(
            mistakeCategories: _mistakeCategories.toList(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange.shade50,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),

            // Category + description
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 32),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(_category,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  if (_description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(_description, style: const TextStyle(fontSize: 16)),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Word card
            Card(
              elevation: 4,
              margin: const EdgeInsets.symmetric(horizontal: 32),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Text(_word,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 36, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 16),

            // “You said”
            if (_lastResult.isNotEmpty) ...[
              const Text('You said:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(_lastResult,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 22, fontStyle: FontStyle.italic)),
              const SizedBox(height: 16),
            ],

            // Score & stars
            if (_wordScore != null && _wordStars != null) ...[
              Text('Score: $_wordScore%',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  3,
                  (i) => Icon(
                      i < _wordStars! ? Icons.star : Icons.star_border),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Encouragement
            Text(_enc,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 22, fontStyle: FontStyle.italic)),
            const SizedBox(height: 24),

            // Play & Record buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _CircleButton(
                  icon: Icons.volume_up,
                  label: 'Play Word',
                  color: Colors.orange.shade300,
                  iconColor: Colors.black,
                  textColor: Colors.black,
                  onTap: _speak,
                ),
                const SizedBox(width: 24),
                _CircleButton(
                  icon: _isListening ? Icons.stop : Icons.mic,
                  label: 'Record',
                  color: Colors.orange.shade300,
                  iconColor: Colors.black,
                  textColor: Colors.black,
                  onTap: _toggleListen,
                ),
              ],
            ),
            const Spacer(flex: 3),

            // Next
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: ElevatedButton(
                onPressed: _next,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade400,
                  minimumSize: const Size.fromHeight(52),
                  textStyle: const TextStyle(fontSize: 20),
                ),
                child: const Text('Next'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

/// A circular button with icon + label underneath
class _CircleButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color, iconColor, textColor;
  final VoidCallback onTap;

  const _CircleButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.iconColor,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 32),
          ),
        ),
        const SizedBox(height: 4),
        Text(label,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: textColor)),
      ],
    );
  }
}
