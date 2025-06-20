import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'dyslexia_summary_ar.dart';

class PracticeMispronouncedArScreen extends StatefulWidget {
  final List<String> words;
  final Map<String, Map<String, String>> wordCategories;
  final int maxAttempts;
  final VoidCallback? onFinished;

  const PracticeMispronouncedArScreen({
    super.key,
    required this.words,
    required this.wordCategories,
    this.maxAttempts = 3,
    this.onFinished,
  });

  @override
  State<PracticeMispronouncedArScreen> createState() => _PracticeMispronouncedArScreenState();
}

class _PracticeMispronouncedArScreenState extends State<PracticeMispronouncedArScreen> with TickerProviderStateMixin {
  late FlutterTts _tts;
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _lastResult = '';
  int _currentIndex = 0;
  late int _attemptsLeft;
  int? _wordScore;
  int? _wordStars;

  final Set<String> _mistakeCategories = {};
  final Set<String> _allWrongWords = {};

  final List<String> _encourage = [
    'أحسنت! 💖',
    'استمر بالمحاولة! 🌟',
    'أنت تستطيع! 👍',
    'كل محاولة تقدم! 🌱',
  ];

  late AnimationController _fbController;
  late Animation<Offset> _fbOffset;

  late final List<String> _filteredWords;

  @override
  void initState() {
    super.initState();
    _tts = FlutterTts()..setLanguage('ar-SA');
    _speech = stt.SpeechToText();
    _attemptsLeft = widget.maxAttempts;

    _filteredWords = widget.words.where((w) => widget.wordCategories.containsKey(_clean(w))).toList();

    if (_filteredWords.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => DyslexiaSummaryArScreen(mistakeCategories: []),
          ),
        );
      });
    }

    _fbController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _fbOffset = Tween<Offset>(begin: const Offset(0, 1.0), end: Offset.zero)
        .animate(CurvedAnimation(parent: _fbController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _fbController.dispose();
    super.dispose();
  }

  String get _word => _filteredWords[_currentIndex];
  Map<String, String> get _info => widget.wordCategories[_clean(_word)]!;
  String get _category => _info['category'] ?? 'غير معروف';
  String get _description => _info['description'] ?? '';
  String get _enc => _encourage[min(widget.maxAttempts - _attemptsLeft, _encourage.length - 1)];

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

  String _clean(String word) => word.replaceAll(RegExp(r'[^ء-ي]'), '').toLowerCase();

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
        localeId: 'ar_SA',
        onResult: (r) => setState(() => _lastResult = r.recognizedWords),
      );
    }
  }

  void _showBanner(String msg, {bool success = false}) async {
    final entry = OverlayEntry(builder: (_) {
      return Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: SlideTransition(
          position: _fbOffset,
          child: Material(
            color: success ? Colors.green.shade300 : Colors.orange.shade300,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(msg, textAlign: TextAlign.center, style: const TextStyle(color: Colors.black, fontSize: 16)),
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
    if (_clean(spoken) == _clean(_word)) {
      _wordScore = _computedScore.round();
      _wordStars = _computedStars;
      _showBanner('ممتاز! النتيجة: $_wordScore%', success: true);
    } else {
      _allWrongWords.add(_word);
      _mistakeCategories.add(_category);
      _attemptsLeft--;
      if (_attemptsLeft > 0) {
        _showBanner('❌ تبقى $_attemptsLeft محاولة. $_enc');
      } else {
        _wordScore = 0;
        _wordStars = 0;
        _showBanner('حاول في الكلمة التالية! ❌', success: false);
      }
    }
  }

  void _next() {
    if (_currentIndex < _filteredWords.length - 1) {
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
          builder: (_) => DyslexiaSummaryArScreen(
            mistakeCategories: _mistakeCategories.toList(),
          ),
        ),
      );
    }
  }

  List<Widget> _buildStars() => List.generate(3, (i) => Icon(i < (_wordStars ?? 0) ? Icons.star : Icons.star_border, color: Colors.amber, size: 20));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange.shade50,
      appBar: AppBar(
        title: const Text('🎤 تدريب النطق'),
        backgroundColor: Colors.orange.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            const Spacer(),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.record_voice_over, size: 32, color: Colors.blue.shade600),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'لنتمرن معًا! انطق الكلمة بوضوح.',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue.shade800),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(_category, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(_description, style: const TextStyle(fontSize: 16)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 4,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Text(_word, style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
              ),
            ),
            if (_wordScore != null) ...[
              const SizedBox(height: 16),
              Text('قلت:', style: TextStyle(fontSize: 18, color: Colors.grey.shade700)),
              const SizedBox(height: 4),
              Text(_lastResult, style: const TextStyle(fontSize: 22, fontStyle: FontStyle.italic)),
              const SizedBox(height: 12),
              Text('النتيجة: $_wordScore%', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: _buildStars()),
              const SizedBox(height: 8),
              Text(_enc, style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic, fontWeight: FontWeight.w500)),
            ],
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _CircleButton(icon: Icons.volume_up, label: 'استمع', color: Colors.orange.shade300, iconColor: Colors.black, textColor: Colors.black, onTap: _speak),
                const SizedBox(width: 24),
                _CircleButton(icon: _isListening ? Icons.stop : Icons.mic, label: 'تسجيل', color: Colors.orange.shade300, iconColor: Colors.black, textColor: Colors.black, onTap: _toggleListen),
              ],
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _next,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange.shade400, minimumSize: const Size.fromHeight(48)),
              child: const Text("التالي", style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color iconColor;
  final Color textColor;
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
        Material(
          color: color,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Icon(icon, size: 32, color: iconColor),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }
}
