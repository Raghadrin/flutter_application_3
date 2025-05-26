import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SentenceLearningScreen extends StatefulWidget {
  final String sentence;
  final String title;
  final bool motivational;

  const SentenceLearningScreen({
    super.key,
    required this.sentence,
    required this.title,
    this.motivational = false,
  });

  @override
  _SentenceLearningScreenState createState() => _SentenceLearningScreenState();
}

class _SentenceLearningScreenState extends State<SentenceLearningScreen> {
  late AudioPlayer _audioPlayer;
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _recognizedText = "";
  double _score = 0.0;
  int _stars = 0;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _speech = stt.SpeechToText();
  }

  Future<void> _playSentenceAudio() async {
    await _audioPlayer.stop();
    // انتبه هنا، تحتاج تجهز ملف صوتي للجملة كلها أو تسوي توليد صوتي
    // حالياً راح نستخدم TTS لاحقاً لو تبي، هنا بنوقف فقط
  }

  Future<void> _startListening() async {
    bool available = await _speech.initialize(
      onStatus: (val) {
        if (val == 'done') {
          setState(() => _isListening = false);
          _evaluateSpeech();
        }
      },
      onError: (val) {
        print('Error: $val');
      },
    );
    if (available) {
      setState(() {
        _isListening = true;
        _recognizedText = "";
      });
      _speech.listen(
        localeId: 'ar_SA',
        partialResults: true,
        onResult: (val) {
          setState(() {
            _recognizedText = val.recognizedWords;
          });
        },
      );
    }
  }

  void _evaluateSpeech() {
    if (_recognizedText.isEmpty) return;

    List<String> targetWords = widget.sentence.split(' ');
    List<String> spokenWords = _recognizedText.split(' ');

    int matchedWords = 0;
    for (var word in targetWords) {
      if (spokenWords.contains(word)) {
        matchedWords++;
      }
    }

    _score = (matchedWords / targetWords.length) * 100;

    if (_score >= 90) {
      _stars = 3;
    } else if (_score >= 60) {
      _stars = 2;
    } else if (_score > 0) {
      _stars = 1;
    } else {
      _stars = 0;
    }

    setState(() {});
  }

  List<Widget> _buildStars() {
    return List.generate(3, (index) {
      return Icon(
        index < _stars ? Icons.star : Icons.star_border,
        color: Colors.amber,
        size: 40,
      );
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Text(
              widget.sentence,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: const Icon(Icons.play_arrow),
              label: const Text('استمع للجملة'),
              onPressed: () {
                // انتبه هنا، تحتاج تضيف صوت للجملة أو تولدها صوتيًا
                _playSentenceAudio();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: Icon(_isListening ? Icons.stop : Icons.mic),
              label: Text(_isListening ? 'إيقاف' : 'ابدأ التحدث'),
              onPressed: () {
                if (_isListening) {
                  _speech.stop();
                  setState(() => _isListening = false);
                  _evaluateSpeech();
                } else {
                  _startListening();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _isListening ? Colors.red : Colors.green,
              ),
            ),
            const SizedBox(height: 30),
            if (_recognizedText.isNotEmpty) ...[
              const Text(
                'ما قلته:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                _recognizedText,
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Text(
                'دقتك: ${_score.toStringAsFixed(1)}%',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _buildStars(),
              ),
              if (widget.motivational && _stars >= 2) ...[
                const SizedBox(height: 20),
                Text(
                  'أحسنت! 🌟 استمر بالتقدم!',
                  style: TextStyle(fontSize: 20, color: Colors.green.shade700),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
