import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_3/letters/englishLetters/practice/evaluation_english_screen.dart';
import 'package:flutter_application_3/letters/englishLetters/practice/final_feedback_screen.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class KaraokeSentenceEnglishLevel3Screen extends StatefulWidget {
  const KaraokeSentenceEnglishLevel3Screen({super.key});

  @override
  State<KaraokeSentenceEnglishLevel3Screen> createState() =>
      _KaraokeSentenceEnglishLevel3ScreenState();
}

class _KaraokeSentenceEnglishLevel3ScreenState
    extends State<KaraokeSentenceEnglishLevel3Screen>
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

final Map<String, Map<String, String>> wordCategoriesLevel3 = {
 // People
  "sami": {
    "category": "People",
    "description": "The boy reading about space."
  },
  "astronauts": {
    "category": "People",
    "description": "People trained to travel and work in space."
  },
  "friends": {
    "category": "People",
    "description": "Sami’s classmates he shared his learning with."
  },

  // Subjects / Events
  "space exploration": {
    "category": "Subjects",
    "description": "The investigation of outer space."
  },
  "night": {
    "category": "Time",
    "description": "The time between sunset and sunrise."
  },

  // Places
  "space station": {
    "category": "Places",
    "description": "A facility in orbit where astronauts live and work."
  },
  "class": {
    "category": "Places",
    "description": "The classroom where Sami and his classmates learn."
  },

  // Objects
  "book": {
    "category": "Objects",
    "description": "A set of written pages bound together."
  },
  "rockets": {
    "category": "Objects",
    "description": "Vehicles propelled to travel into space."
  },
  "planets": {
    "category": "Objects",
    "description": "Large celestial bodies orbiting a star."
  },
  "picture": {
    "category": "Objects",
    "description": "An illustration or photograph showing something."
  },
  "moon": {
    "category": "Objects",
    "description": "Earth’s natural satellite."
  },
  "earth": {
    "category": "Objects",
    "description": "The planet we live on."
  },
  "suits": {
    "category": "Objects",
    "description": "Protective clothing worn by astronauts."
  },
  "stars": {
    "category": "Objects",
    "description": "Celestial bodies that shine in the night sky."
  },

  // Concepts
  "gravity": {
    "category": "Concepts",
    "description": "The force that pulls objects toward each other."
  },
  "surface": {
    "category": "Concepts",
    "description": "The outside layer or top of something."
  },

  // Action Verbs
  "opened": {
    "category": "Action Verbs",
    "description": "Used hands to fold back a cover and view contents."
  },
  "saw": {
    "category": "Action Verbs",
    "description": "Used eyes to notice something."
  },
  "flying": {
    "category": "Action Verbs",
    "description": "Moving through the air."
  },
  "floating": {
    "category": "Action Verbs",
    "description": "Drifting without falling in zero gravity."
  },
  "showed": {
    "category": "Action Verbs",
    "description": "Displayed something for others to see."
  },
  "shared": {
    "category": "Action Verbs",
    "description": "Told or gave part of something to others."
  },
  "explained": {
    "category": "Action Verbs",
    "description": "Made an idea clear by describing it."
  },
  "trained": {
    "category": "Action Verbs",
    "description": "Prepared for a specific task by practice."
  },
  "protected": {
    "category": "Action Verbs",
    "description": "Kept safe from harm."
  },
  "dreamed": {
    "category": "Action Verbs",
    "description": "Thought about things while sleeping."
  },
  "twinkled": {
    "category": "Action Verbs",
    "description": "Shone with flickering light."
  },
  "wanted": {
    "category": "Action Verbs",
    "description": "Desired to have or learn something."
  },
  "learn": {
    "category": "Action Verbs",
    "description": "To gain knowledge or skill."
  },
  "reach": {
    "category": "Action Verbs",
    "description": "To arrive at or touch something."
  },
  "cheering": {
    "category": "Action Verbs",
    "description": "Shouting support to encourage someone."
  },

  // Descriptive Words
  "big": {
    "category": "Descriptive Words",
    "description": "Large in size."
  },
  "zero": {
    "category": "Descriptive Words",
    "description": "Having no quantity or magnitude."
  },
  "distant": {
    "category": "Descriptive Words",
    "description": "Far away in space or time."
  },
  "rocky": {
    "category": "Descriptive Words",
    "description": "Covered with or full of rocks."
  },
  "small": {
    "category": "Descriptive Words",
    "description": "Little in size."
  },
  "blue": {
    "category": "Descriptive Words",
    "description": "The color like the sky on a clear day."
  },
  "amazed": {
    "category": "Descriptive Words",
    "description": "Filled with wonder or surprise."
  },

  // Connectors / Other
  "and": {
    "category": "Connectors/Other",
    "description": "A helper word used to join words or phrases."
  },
  "the": {
    "category": "Connectors/Other",
    "description": "Refers to a specific item or person."
  },
  "to": {
    "category": "Connectors/Other",
    "description": "Indicates direction or purpose."
  },
  "in": {
    "category": "Connectors/Other",
    "description": "Indicates location or inclusion."
  },
  "of": {
    "category": "Connectors/Other",
    "description": "Indicates belonging or connection."
  },
  "with": {
    "category": "Connectors/Other",
    "description": "Indicates accompaniment or use."
  },
  "as": {
    "category": "Connectors/Other",
    "description": "Used to compare or describe."
  }
};

  List<Map<String, String>> sentences = [
    {
      "text":
          "Sami opened a big book about space exploration. He saw rockets flying to distant planets and astronauts floating in zero gravity inside the space station."
    },
    {
      "text":
          "One picture showed the rocky surface of the moon. Another showed Earth looking small and blue from far away. Sami was amazed and wanted to learn more."
    },
    {
      "text":
          "Back in class, Sami shared what he learned with his friends. He explained how astronauts trained for space and how their suits protected them."
    },
    {
      "text":
          "That night, Sami dreamed of becoming an astronaut. The stars twinkled above as if they were cheering him on. He knew one day, he would reach them."
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
                  wordCategories:wordCategoriesLevel3, // ← new required parameter
                ),
              ),
            );
          }
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
          .collection('level3')
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
        Map<String, String>? wordInfo = wordCategoriesLevel3[word.toLowerCase()];
        String? category = wordInfo?['category'];
        if (category != null) {
          categoryIssues.putIfAbsent(category, () => []).add(word);
        }
      }
    });

    return categoryIssues;
  }

  void nextSentence() {
    setState(() {
      if (currentSentenceIndex < sentences.length - 1) {
        currentSentenceIndex++;
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => FinalFeedbackScreen(
              averageScore: score / sentences.length,
              totalStars: (stars / sentences.length).round(),
              level: 'level3',
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
      appBar: AppBar(title: const Text('🎤 Karaoke Reading - Level 3')),
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
