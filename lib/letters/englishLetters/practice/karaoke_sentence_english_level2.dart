import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_3/letters/englishLetters/practice/final_feedback_screen.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'evaluation_english_screen.dart';

class KaraokeSentenceEnglishLevel2Screen extends StatefulWidget {
  const KaraokeSentenceEnglishLevel2Screen({super.key});

  @override
  State<KaraokeSentenceEnglishLevel2Screen> createState() =>
      _KaraokeSentenceEnglishLevel2ScreenState();
}

class _KaraokeSentenceEnglishLevel2ScreenState
    extends State<KaraokeSentenceEnglishLevel2Screen>
    with TickerProviderStateMixin {
  final FlutterTts flutterTts = FlutterTts();
  late stt.SpeechToText speech;
  bool isListening = false;
  bool isPlaying = false;

  String recognizedText = '';
  double score = 0.0;
  int stars = 0;
  int currentSentenceIndex = 0;

  int matchedWordCount = 0;
  Map<String, bool> wordMatchResults = {};
  List<String> spokenWordSequence = [];
  late Map<String, List<String>> categoryIssues;

  final Map<String, String> wordCategories = {
    'school': 'Places',
    'window': 'Objects',
    'umbrella': 'Objects',
    'cat': 'Animals',
    'rain': 'Weather',
    'bench': 'Places',
    'parents': 'People',
    'home': 'Places',
    'sunny': 'Weather',
    'puddles': 'Nature',
    'clouds': 'Weather',
    'sky': 'Nature',
    'face': 'Body Parts',
    'story': 'Concepts',
  };

  List<Map<String, String>> sentences = [
    {
      "text":
          "Maya looked out the window and saw gray clouds gathering in the sky. She knew it would rain soon, so she reached for her bright yellow umbrella and hurried outside."
    },
    {
      "text":
          "As she stepped onto the wet sidewalk, raindrops began to fall gently. She smiled as she jumped over puddles and splashes echoed under her feet, feeling the cool breeze on her face."
    },
    {
      "text":
          "Suddenly, she noticed a small shivering cat hiding beneath a bench. Without hesitation, Maya bent down and shared her umbrella, covering them both from the rain."
    },
    {
      "text":
          "When she arrived home, Maya's parents were surprised to see the cat. She told them the whole story, and they decided to keep it, naming it Sunny for bringing light to a rainy day."
    }
  ];

  Map<String, String> get currentSentence => sentences[currentSentenceIndex];

  @override
  void initState() {
    super.initState();
    speech = stt.SpeechToText();
    flutterTts.setLanguage("en-US");
    flutterTts.setSpeechRate(0.45);
  }

  Future<void> speakSentence() async {
    if (isPlaying) {
      await flutterTts.stop();
      setState(() => isPlaying = false);
    } else {
      setState(() => isPlaying = true);
      await flutterTts.speak(currentSentence["text"]!);
      flutterTts.setCompletionHandler(() => setState(() => isPlaying = false));
    }
  }

  Future<void> startListening() async {
    bool available = await speech.initialize(
      onStatus: (val) async {
        if (val == 'done') {
          setState(() => isListening = false);
          await evaluateResult();
          if (!mounted) return;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EvaluationEnglishScreen(
                recognizedText: recognizedText,
                score: score,
                stars: stars,
                level: 'level2',
                wordMatchResults: wordMatchResults,
                onNext: () {
                  Navigator.pop(context);
                  nextSentence();
                },
                categoryIssues: categoryIssues,
              ),
            ),
          );
        }
      },
      onError: (val) => print('Error: $val'),
    );

    if (available) {
      setState(() {
        isListening = true;
        recognizedText = "";
        wordMatchResults.clear();
        spokenWordSequence.clear();
        matchedWordCount = 0;
      });

      speech.listen(
        localeId: 'en_US',
        listenMode: stt.ListenMode.dictation,
        partialResults: true,
        listenFor: const Duration(seconds: 90),
        pauseFor: const Duration(seconds: 5),
        onResult: (val) {
          recognizedText = val.recognizedWords;
          updateMatchedWords();
          matchedWordCount = recognizedText
              .split(RegExp(r'\s+'))
              .where((w) => w.trim().isNotEmpty)
              .length;
        },
      );
    }
  }

  void updateMatchedWords() {
    String expected = currentSentence["text"] ?? "";
    List<String> expectedWords = expected
        .split(RegExp(r'\s+'))
        .map((w) => w.replaceAll(RegExp(r'[^\w]'), '').toLowerCase())
        .toList();
    List<String> spokenWords = recognizedText
        .split(RegExp(r'\s+'))
        .map((w) => w.replaceAll(RegExp(r'[^\w]'), '').toLowerCase())
        .toList();

    Map<String, bool> newResults = {};
    for (var word in expectedWords) {
      newResults[word] =
          spokenWords.any((spoken) => levenshtein(word, spoken) <= 1);
    }

    setState(() {
      wordMatchResults = newResults;
      spokenWordSequence = spokenWords;
    });
  }

  Future<void> evaluateResult() async {
    int correct = wordMatchResults.values.where((v) => v).length;
    int total = wordMatchResults.length;
    score = total > 0 ? (correct / total) * 100 : 0.0;
    stars = score >= 90 ? 3 : (score >= 60 ? 2 : (score > 0 ? 1 : 0));

    List<String> correctWords = wordMatchResults.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();
    List<String> wrongWords = wordMatchResults.entries
        .where((e) => !e.value)
        .map((e) => e.key)
        .toList();
    categoryIssues = getCategoryAnalysis();

    await saveEvaluation(
      sentence: currentSentence["text"]!,
      recognizedText: recognizedText,
      correctWords: correctWords,
      wrongWords: wrongWords,
      score: score,
      stars: stars,
    );
  }

  Future<void> saveEvaluation({
    required String sentence,
    required String recognizedText,
    required List<String> correctWords,
    required List<String> wrongWords,
    required double score,
    required int stars,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      final parentId = user.uid;
      final childrenSnapshot = await FirebaseFirestore.instance
          .collection('parents')
          .doc(parentId)
          .collection('children')
          .get();
      if (childrenSnapshot.docs.isEmpty) return;
      final childId = childrenSnapshot.docs.first.id;
      await FirebaseFirestore.instance
          .collection('parents')
          .doc(parentId)
          .collection('children')
          .doc(childId)
          .collection('karaoke')
          .doc('enKaraoke')
          .collection('level2')
          .add({
        'sentence': sentence,
        'recognizedText': recognizedText,
        'correctWords': correctWords,
        'wrongWords': wrongWords,
        'score': score,
        'stars': stars,
        'timestamp': FieldValue.serverTimestamp(),
        'categoryIssues': categoryIssues,
      });
    } catch (e) {
      print("Error saving evaluation: $e");
    }
  }

  Map<String, List<String>> getCategoryAnalysis() {
    Map<String, List<String>> categoryIssues = {};

    wordMatchResults.forEach((word, isCorrect) {
      if (!isCorrect) {
        String? category = wordCategories[word.toLowerCase()];
        if (category != null) {
          categoryIssues.putIfAbsent(category, () => []).add(word);
        }
      }
    });

    return categoryIssues;
  }

  void nextSentence() {
    setState(() {
      if (currentSentenceIndex < 2) {
        currentSentenceIndex++;
      } else {
        // Go to FinalFeedbackScreen instead of showing a dialog
        var totalStars = stars;
        var totalScore = totalStars;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => FinalFeedbackScreen(
              averageScore: totalScore / sentences.length,
              totalStars: (totalStars / sentences.length).round(),
              level: 'level2',
            ),
          ),
        );
      }
      recognizedText = '';
      score = 0.0;
      stars = 0;
      wordMatchResults.clear();
      spokenWordSequence.clear();
      matchedWordCount = 0;
    });
  }

  List<InlineSpan> buildHighlightedSentence() {
    String sentence = currentSentence["text"]!;
    List<String> words = sentence.split(RegExp(r'\s+'));

    return words.asMap().entries.map((entry) {
      int index = entry.key;
      String word = entry.value;
      String cleanWord = word.replaceAll(RegExp(r'[^\w]'), '').toLowerCase();
      Color wordColor = Colors.black;

      if (isListening && index < matchedWordCount) {
        wordColor = Colors.blue;
      } else if (!isListening && recognizedText.isNotEmpty) {
        if (wordMatchResults.containsKey(cleanWord)) {
          wordColor = wordMatchResults[cleanWord]! ? Colors.green : Colors.red;
        }
      }

      return TextSpan(
        text: '$word ',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: wordColor,
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(title: const Text('🎤 Karaoke Reading - Level 2')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 4))
                ],
              ),
              child: SingleChildScrollView(
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(children: buildHighlightedSentence()),
                ),
              ),
            ),
            LinearProgressIndicator(
              value: (currentSentenceIndex + 1) / sentences.length,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(
                  Color.fromARGB(255, 109, 175, 252)),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: Icon(isPlaying ? Icons.stop : Icons.volume_up),
              label: Text(isPlaying ? 'Stop Reading' : 'Read Sentence'),
              onPressed: speakSentence,
              style: ElevatedButton.styleFrom(
                backgroundColor: isPlaying
                    ? const Color.fromARGB(255, 255, 170, 170)
                    : const Color.fromARGB(255, 255, 231, 176),
                foregroundColor: Colors.black,
                minimumSize: Size(screenWidth * 0.8, 44),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: Icon(isListening ? Icons.stop : Icons.mic),
              label: Text(isListening ? 'Stop' : 'Start Speaking'),
              onPressed: () {
                if (isListening) {
                  speech.stop();
                  setState(() => isListening = false);
                } else {
                  startListening();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isListening
                    ? const Color.fromARGB(255, 255, 204, 204)
                    : const Color.fromARGB(255, 204, 255, 204),
                foregroundColor: Colors.black,
                minimumSize: Size(screenWidth * 0.8, 44),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Levenshtein Distance Helper
int levenshtein(String s1, String s2) {
  List<List<int>> dp =
      List.generate(s1.length + 1, (_) => List.filled(s2.length + 1, 0));
  for (int i = 0; i <= s1.length; i++) dp[i][0] = i;
  for (int j = 0; j <= s2.length; j++) dp[0][j] = j;
  for (int i = 1; i <= s1.length; i++) {
    for (int j = 1; j <= s2.length; j++) {
      int cost = s1[i - 1] == s2[j - 1] ? 0 : 1;
      dp[i][j] = [dp[i - 1][j] + 1, dp[i][j - 1] + 1, dp[i - 1][j - 1] + cost]
          .reduce((a, b) => a < b ? a : b);
    }
  }
  return dp[s1.length][s2.length];
}
