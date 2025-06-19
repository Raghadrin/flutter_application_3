// lib/letters/englishLetters/practice/karaoke_sentence_english_level2_screen.dart

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_3/letters/englishLetters/practice/evaluation_english_screen.dart';
import 'package:flutter_application_3/letters/englishLetters/practice/final_feedback_screen.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

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

  // accumulate level 2 scores
  final List<double> _sessionScores = [];

  final Map<String, Map<String, String>> wordCategoriesLevel2 = {
    // People
    "maya": {"category": "People", "description": "The girl in the story."},
    "parents": {"category": "People", "description": "Mom and Dad."},

    // Animals
    "cat": {
      "category": "Animals",
      "description": "A small pet that says 'meow.'"
    },
    "sunny": {
      "category": "Weather",
      "description": "Full of sunshine."
    }, // name of the cat

    // Objects
    "window": {
      "category": "Objects",
      "description": "An opening in a wall to see outside."
    },
    "umbrella": {
      "category": "Objects",
      "description": "Something you use to stay dry in rain."
    },
    "bench": {
      "category": "Places",
      "description": "A seat for two or more people."
    },
    "face": {
      "category": "Body Parts",
      "description": "The front part of your head."
    },
    "feet": {
      "category": "Body Parts",
      "description": "Parts at the end of your legs you stand on."
    },
    "light": {
      "category": "Objects",
      "description": "Brightness that helps you see."
    },

    // Weather
    "clouds": {
      "category": "Weather",
      "description": "White or gray things in the sky."
    },
    "rain": {
      "category": "Weather",
      "description": "Water drops falling from clouds."
    },
    "raindrops": {
      "category": "Weather",
      "description": "Individual drops of rain."
    },
    "puddles": {
      "category": "Nature",
      "description": "Small pools of water on the ground."
    },
    "rainy": {"category": "Weather", "description": "Having rain."},

    // Nature
    "sky": {"category": "Nature", "description": "The space above the earth."},
    "breeze": {"category": "Nature", "description": "A gentle wind."},

    // Places
    "outside": {
      "category": "Places",
      "description": "The area not inside a building."
    },
    "sidewalk": {
      "category": "Places",
      "description": "A path on the side of a street for walking."
    },
    "home": {"category": "Places", "description": "Where you live."},

    // Time
    "soon": {
      "category": "Time",
      "description": "Happening not long after now."
    },
    "suddenly": {
      "category": "Time",
      "description": "Happening very quickly without warning."
    },
    "day": {
      "category": "Time",
      "description": "The time from sunrise to sunset."
    },
    "night": {
      "category": "Time",
      "description": "The time between evening and morning."
    },

    // Descriptive Words
    "gray": {
      "category": "Descriptive Words",
      "description": "A color between black and white."
    },
    "bright": {
      "category": "Descriptive Words",
      "description": "Full of light or vivid color."
    },
    "yellow": {
      "category": "Descriptive Words",
      "description": "A bright color like the sun."
    },
    "wet": {
      "category": "Descriptive Words",
      "description": "Covered in water or liquid."
    },
    "gently": {
      "category": "Descriptive Words",
      "description": "In a soft or light way."
    },
    "cool": {
      "category": "Descriptive Words",
      "description": "A little bit cold."
    },
    "small": {
      "category": "Descriptive Words",
      "description": "Little in size."
    },
    "whole": {
      "category": "Descriptive Words",
      "description": "All of something."
    },

    // Action Verbs
    "looked": {
      "category": "Action Verbs",
      "description": "Used her eyes to see something."
    },
    "saw": {
      "category": "Action Verbs",
      "description": "Used eyes to notice something."
    },
    "gathering": {
      "category": "Action Verbs",
      "description": "Coming together in one place."
    },
    "knew": {
      "category": "Action Verbs",
      "description": "Understood or remembered something."
    },
    "reached": {
      "category": "Action Verbs",
      "description": "Stretched out her hand to get something."
    },
    "hurried": {"category": "Action Verbs", "description": "Moved very fast."},
    "stepped": {
      "category": "Action Verbs",
      "description": "Put her foot down to walk."
    },
    "began": {
      "category": "Action Verbs",
      "description": "Started to happen or do something."
    },
    "fall": {
      "category": "Action Verbs",
      "description": "Move downward quickly."
    },
    "smiled": {"category": "Action Verbs", "description": "Made a happy face."},
    "jumped": {
      "category": "Action Verbs",
      "description": "Pushed off the ground to move up."
    },
    "echoed": {
      "category": "Action Verbs",
      "description": "Made a sound that bounced back."
    },
    "noticed": {
      "category": "Action Verbs",
      "description": "Saw something and paid attention."
    },
    "shivering": {
      "category": "Action Verbs",
      "description": "Shaking because of cold or fear."
    },
    "bent": {
      "category": "Action Verbs",
      "description": "Moved your body forward or down."
    },
    "shared": {
      "category": "Action Verbs",
      "description": "Gave part of something to someone else."
    },
    "covering": {
      "category": "Action Verbs",
      "description": "Putting something over to protect."
    },
    "told": {
      "category": "Action Verbs",
      "description": "Said something to someone."
    },
    "decided": {"category": "Action Verbs", "description": "Chose what to do."},
    "keep": {
      "category": "Action Verbs",
      "description": "Allowed to stay or be owned."
    },
    "naming": {
      "category": "Action Verbs",
      "description": "Giving a name to someone or something."
    },
    "bringing": {
      "category": "Action Verbs",
      "description": "Carrying something along."
    },
    "reach": {
      "category": "Action Verbs",
      "description": "Get to something you want."
    },

    // Action Nouns
    "splashes": {
      "category": "Action Nouns",
      "description": "Sounds or movements of water hitting something."
    },
    "feeling": {
      "category": "Action Nouns",
      "description": "Experiencing a sensation or emotion."
    },

    // Nouns / Concepts
    "hesitation": {
      "category": "Nouns",
      "description": "A pause before doing something."
    },
    "story": {
      "category": "Concepts",
      "description": "A tale with characters and events."
    },
    "where": {
      "category": "Concepts",
      "description": "Used to ask about a place."
    },

    // Connectors / Other
    "and": {
      "category": "Connectors/Other",
      "description": "A helper word used often."
    },
    "as": {
      "category": "Connectors/Other",
      "description": "A helper word used often."
    },
    "at": {
      "category": "Connectors/Other",
      "description": "A helper word used often."
    },
    "a": {
      "category": "Connectors/Other",
      "description": "A helper word used often."
    },
    "about": {
      "category": "Connectors/Other",
      "description": "A helper word used often."
    },
    "in": {
      "category": "Connectors/Other",
      "description": "A helper word used often."
    },
    "into": {
      "category": "Connectors/Other",
      "description": "A helper word used often."
    },
    "onto": {
      "category": "Connectors/Other",
      "description": "A helper word used often."
    },
    "over": {
      "category": "Connectors/Other",
      "description": "A helper word used often."
    },
    "under": {
      "category": "Connectors/Other",
      "description": "A helper word used often."
    },
    "out": {
      "category": "Connectors/Other",
      "description": "A helper word used often."
    },
    "without": {
      "category": "Connectors/Other",
      "description": "Not having something."
    },
    "from": {
      "category": "Connectors/Other",
      "description": "A helper word used often."
    },
    "them": {
      "category": "Connectors/Other",
      "description": "A word that talks about more than one person."
    },
    "both": {
      "category": "Connectors/Other",
      "description": "Meaning two together."
    },
    "so": {
      "category": "Connectors/Other",
      "description": "A helper word used often."
    },
    "that": {
      "category": "Connectors/Other",
      "description": "A helper word used often."
    },
    "would": {
      "category": "Connectors/Other",
      "description": "Shows something likely to happen."
    },
    "he": {
      "category": "Connectors/Other",
      "description": "A word that talks about a boy or man."
    },
  };

  final List<Map<String, String>> sentences = [
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
      onStatus: (val) => setState(() => isListening = val != 'done'),
      onError: (val) => print('Error: $val'),
    );
    if (!available) return;

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
      onResult: (val) async {
        recognizedText = val.recognizedWords;
        updateMatchedWords();
        matchedWordCount = recognizedText
            .split(RegExp(r'\s+'))
            .where((w) => w.trim().isNotEmpty)
            .length;

        if (val.finalResult) {
          await evaluateResult();
          if (!mounted) return;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EvaluationEnglishScreen(
                recognizedText: recognizedText,
                score: score,
                stars: stars,
                wordMatchResults: wordMatchResults,
                onNext: () {
                  Navigator.pop(context);
                  nextSentence();
                },
                wordCategories: wordCategoriesLevel2,
                level: 'level2',
              ),
            ),
          );
        }
      },
    );
  }

  void updateMatchedWords() {
    final expected = currentSentence["text"] ?? "";
    final expectedWords = expected
        .split(RegExp(r'\s+'))
        .map((w) => w.replaceAll(RegExp(r'[^\w]'), '').toLowerCase())
        .toList();
    final spokenWords = recognizedText
        .split(RegExp(r'\s+'))
        .map((w) => w.replaceAll(RegExp(r'[^\w]'), '').toLowerCase())
        .toList();

    final newResults = <String, bool>{};
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
    final correct = wordMatchResults.values.where((v) => v).length;
    final total = wordMatchResults.length;
    score = total > 0 ? (correct / total) * 100 : 0.0;
    stars = score >= 90 ? 3 : (score >= 60 ? 2 : (score > 0 ? 1 : 0));

    // store this sentence’s score %
    _sessionScores.add(score);

    // … your existing saveEvaluation() …
  }

  Future<void> saveEvaluation({
    required String sentence,
    required String recognizedText,
    required List<String> correctWords,
    required List<String> wrongWords,
    required double score,
    required int stars,
  }) async {
    // … unchanged …
  }

  void nextSentence() {
    setState(() {
      if (currentSentenceIndex < sentences.length - 1) {
        currentSentenceIndex++;
      } else {
        // compute the average percent (0–100) across the session
        final avgPct = _sessionScores.isEmpty
            ? 0.0
            : _sessionScores.reduce((a, b) => a + b) / _sessionScores.length;
        final avgStars =
            avgPct >= 90 ? 3 : (avgPct >= 60 ? 2 : (avgPct > 0 ? 1 : 0));

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => FinalFeedbackScreen(
              averageScore: avgPct, // ← pass percent directly
              totalStars: avgStars,
              level: 'level1',
            ),
          ),
        );
      }
      // reset for next
      recognizedText = '';
      score = 0.0;
      stars = 0;
      wordMatchResults.clear();
      spokenWordSequence.clear();
      matchedWordCount = 0;
    });
  }

  List<InlineSpan> buildHighlightedSentence() {
    final sentence = currentSentence["text"]!;
    final words = sentence.split(RegExp(r'\s+'));

    return words.asMap().entries.map((entry) {
      final idx = entry.key;
      final w = entry.value;
      final clean = w.replaceAll(RegExp(r'[^\w]'), '').toLowerCase();
      Color color = Colors.black;

      if (isListening && idx < matchedWordCount)
        color = Colors.blue;
      else if (!isListening && recognizedText.isNotEmpty)
        color = (wordMatchResults[clean] ?? false) ? Colors.green : Colors.red;

      return TextSpan(
        text: '$w ',
        style:
            TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(title: const Text('🎤 Karaoke Reading – Level 2')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Expanded(
              child: Container(
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
            ),
            LinearProgressIndicator(
              value: (currentSentenceIndex + 1) / sentences.length,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation(
                  Color.fromARGB(255, 109, 175, 252)),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: Icon(isPlaying ? Icons.stop : Icons.volume_up),
              label: Text(isPlaying ? 'Stop Reading' : 'Read Sentence'),
              onPressed: speakSentence,
              style: ElevatedButton.styleFrom(
                backgroundColor: isPlaying
                    ? Color.fromARGB(255, 255, 170, 170)
                    : Color.fromARGB(255, 255, 231, 176),
                foregroundColor: Colors.black,
                minimumSize: Size(w * 0.8, 44),
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
                    ? Color.fromARGB(255, 255, 204, 204)
                    : Color.fromARGB(255, 204, 255, 204),
                foregroundColor: Colors.black,
                minimumSize: Size(w * 0.8, 44),
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
  final dp = List.generate(s1.length + 1, (_) => List.filled(s2.length + 1, 0));
  for (var i = 0; i <= s1.length; i++) dp[i][0] = i;
  for (var j = 0; j <= s2.length; j++) dp[0][j] = j;
  for (var i = 1; i <= s1.length; i++) {
    for (var j = 1; j <= s2.length; j++) {
      final cost = s1[i - 1] == s2[j - 1] ? 0 : 1;
      dp[i][j] = [dp[i - 1][j] + 1, dp[i][j - 1] + 1, dp[i - 1][j - 1] + cost]
          .reduce((a, b) => a < b ? a : b);
    }
  }
  return dp[s1.length][s2.length];
}
