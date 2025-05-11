import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:confetti/confetti.dart';

class SentenceLearningScreen extends StatefulWidget {
  final String sentence;
  final String title;
  final String imagePath;
  final bool motivational;

  const SentenceLearningScreen({
    super.key,
    required this.sentence,
    required this.title,
    required this.imagePath,
    this.motivational = false,
  });

  @override
  State<SentenceLearningScreen> createState() => _SentenceLearningScreenState();
}

class _SentenceLearningScreenState extends State<SentenceLearningScreen> {
  final FlutterTts flutterTts = FlutterTts();
  final stt.SpeechToText speech = stt.SpeechToText();
  final ConfettiController confettiController = ConfettiController(duration: Duration(seconds: 2));

  bool isListening = false;
  bool isEvaluating = false;
  String recognizedText = '';
  double sentenceScore = 0;
  double wordScore = 0;
  int stars = 0;
  int currentWordIndex = -1;
  Color feedbackColor = Colors.transparent;
  List<String> words = [];

  @override
  void initState() {
    super.initState();
    words = widget.sentence.split(RegExp(r'\s+'));
    flutterTts.setLanguage("en-US");
    flutterTts.setSpeechRate(0.5);
  }

  Future<void> _playSentence() async {
    for (int i = 0; i < words.length; i++) {
      setState(() => currentWordIndex = i);
      await flutterTts.speak(words[i]);
      await Future.delayed(const Duration(milliseconds: 1000));
    }
    setState(() => currentWordIndex = -1);
  }

  void _startListening(bool isSentence) async {
    bool available = await speech.initialize(
      onStatus: (status) {
        if (status == "done") {
          _evaluateSpeech(isSentence);
        }
      },
    );

    if (!available) return;

    setState(() {
      isListening = true;
      recognizedText = '';
      if (isSentence) sentenceScore = 0;
      else wordScore = 0;
    });

    speech.listen(
      localeId: "en_US",
      partialResults: false,
      listenMode: stt.ListenMode.dictation,
      listenFor: Duration(seconds: 12),
      onResult: (val) async {
        setState(() {
          recognizedText = val.recognizedWords;
        });
        setState(() => isEvaluating = true);
        await Future.delayed(const Duration(seconds: 2)); // Buffer before scoring
        _evaluateSpeech(isSentence);
        setState(() => isEvaluating = false);
      },
    );
  }

  void _evaluateSpeech(bool isSentence) {
    String spoken = recognizedText.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '').trim();
    String target = isSentence
        ? widget.sentence.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '').trim()
        : words[currentWordIndex >= 0 ? currentWordIndex : 0].toLowerCase();

    int distance = _levenshtein(spoken, target);
    double score = ((1 - distance / max(target.length, 1)) * 100).clamp(0, 100).toDouble();

    setState(() {
      if (isSentence) {
        sentenceScore = score;
        if (score >= 80) {
          confettiController.play();
        }
      } else {
        wordScore = score;
      }
      stars = _getStars(score);
      isListening = false;
      feedbackColor = score >= 80 ? Colors.green : Colors.red;
    });
  }

  int _levenshtein(String s, String t) {
    if (s == t) return 0;
    if (s.isEmpty) return t.length;
    if (t.isEmpty) return s.length;

    List<List<int>> matrix = List.generate(s.length + 1, (_) => List<int>.filled(t.length + 1, 0));
    for (int i = 0; i <= s.length; i++) matrix[i][0] = i;
    for (int j = 0; j <= t.length; j++) matrix[0][j] = j;

    for (int i = 1; i <= s.length; i++) {
      for (int j = 1; j <= t.length; j++) {
        int cost = s[i - 1] == t[j - 1] ? 0 : 1;
        matrix[i][j] = [
          matrix[i - 1][j] + 1,
          matrix[i][j - 1] + 1,
          matrix[i - 1][j - 1] + cost
        ].reduce(min);
      }
    }
    return matrix[s.length][t.length];
  }

  int _getStars(double score) {
    if (score >= 90) return 3;
    if (score >= 70) return 2;
    if (score >= 50) return 1;
    return 0;
  }

  @override
  void dispose() {
    flutterTts.stop();
    speech.stop();
    confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0),
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.orange,
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          ConfettiWidget(
            confettiController: confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            emissionFrequency: 0.07,
            numberOfParticles: 30,
            blastDirection: pi / 2,
            gravity: 0.3,
            shouldLoop: false,
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      border: Border.all(color: Color(0xFFF7722F), width: 5),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: Offset(2, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(widget.imagePath, height: 180),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 6,
                          offset: Offset(2, 3),
                        ),
                      ],
                    ),
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      children: List.generate(words.length, (i) {
                        return GestureDetector(
                          onTap: () async {
                            setState(() => currentWordIndex = i);
                            await flutterTts.speak(words[i]);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                            decoration: BoxDecoration(
                              color: currentWordIndex == i ? Colors.yellow : null,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              words[i],
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _playSentence,
                    icon: const Icon(Icons.volume_up),
                    label: const Text("Play the Sentence"),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: () => _startListening(true),
                    icon: const Icon(Icons.mic),
                    label: const Text("Record Sentence"),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: () => _startListening(false),
                    icon: const Icon(Icons.record_voice_over),
                    label: const Text("Record Word"),
                  ),
                  const SizedBox(height: 20),
                  if (isEvaluating)
                    const CircularProgressIndicator(),
                  if (!isEvaluating) ...[
                    Text("You said: $recognizedText", style: const TextStyle(fontSize: 18)),
                    const SizedBox(height: 10),
                    Text(
                      "Score: ${sentenceScore.toStringAsFixed(1)}%",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: feedbackColor,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        3,
                        (i) => Icon(
                          i < stars ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 32,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}