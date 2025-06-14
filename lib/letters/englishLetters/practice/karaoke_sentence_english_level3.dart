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
  // Space & Astronomy Vocabulary
  "space": {
    "category": "Space Vocabulary",
    "description": "The area beyond Earth’s atmosphere.",
  },
  "exploration": {
    "category": "Space Vocabulary",
    "description": "The act of traveling to discover new places.",
  },
  "rockets": {
    "category": "Space Vocabulary",
    "description": "Vehicles that launch into space.",
  },
  "planets": {
    "category": "Space Vocabulary",
    "description": "Large objects that orbit a star.",
  },
  "astronauts": {
    "category": "Space Vocabulary",
    "description": "People trained to travel in space.",
  },
  "gravity": {
    "category": "Space Vocabulary",
    "description": "The force that pulls objects toward each other.",
  },
  "station": {
    "category": "Space Vocabulary",
    "description": "A place in space where people live and work.",
  },
  "moon": {
    "category": "Space Vocabulary",
    "description": "A natural object that orbits Earth.",
  },
  "earth": {
    "category": "Space Vocabulary",
    "description": "The planet we live on.",
  },
  "astronaut": {
    "category": "Space Vocabulary",
    "description": "A person who travels in space.",
  },
  "stars": {
    "category": "Space Vocabulary",
    "description": "Huge balls of burning gas in the sky.",
  },

  // Descriptive Adjectives
  "big": {
    "category": "Descriptive Words",
    "description": "Very large in size.",
  },
  "rocky": {
    "category": "Descriptive Words",
    "description": "Covered with rocks or made of rock.",
  },
  "small": {
    "category": "Descriptive Words",
    "description": "Little in size.",
  },
  "blue": {
    "category": "Descriptive Words",
    "description": "A color like the sky on a clear day.",
  },
  "amazed": {
    "category": "Descriptive Words",
    "description": "Feeling surprised and happy.",
  },
  "twinkled": {
    "category": "Descriptive Words",
    "description": "Shined with a soft, sparkling light.",
  },
  "distant": {
    "category": "Descriptive Words",
    "description": "Far away.",
  },

  // Actions (Verbs)
  "opened": {
    "category": "Action Verbs",
    "description": "Made something accessible by moving a part.",
  },
  "saw": {
    "category": "Action Verbs",
    "description": "Used eyes to notice something.",
  },
  "flying": {
    "category": "Action Verbs",
    "description": "Moving through the air.",
  },
  "floating": {
    "category": "Action Verbs",
    "description": "Staying on or near the surface of a liquid or air.",
  },
  "showed": {
    "category": "Action Verbs",
    "description": "Made something visible to others.",
  },
  "shared": {
    "category": "Action Verbs",
    "description": "Gave part of something to others.",
  },
  "explained": {
    "category": "Action Verbs",
    "description": "Told how something works.",
  },
  "trained": {
    "category": "Action Verbs",
    "description": "Practiced to get better at something.",
  },
  "protected": {
    "category": "Action Verbs",
    "description": "Kept safe from harm.",
  },
  "dreamed": {
    "category": "Action Verbs",
    "description": "Thought about something while sleeping.",
  },
  "reach": {
    "category": "Action Verbs",
    "description": "Get to something you want.",
  },

  // School / Learning Vocabulary
  "book": {
    "category": "School Vocabulary",
    "description": "A set of written pages bound together.",
  },
  "class": {
    "category": "School Vocabulary",
    "description": "A lesson or group gathering to learn.",
  },
  "friends": {
    "category": "School Vocabulary",
    "description": "People you like to spend time with.",
  },
  "learned": {
    "category": "School Vocabulary",
    "description": "Understood and remembered new information.",
  },
  "learn": {
    "category": "School Vocabulary",
    "description": "To get new knowledge or skills.",
  },

  // Clothing Vocabulary
  "suits": {
    "category": "Clothing",
    "description": "Special outfits worn for protection or formal events.",
  },

  // Time Vocabulary
  "night": {
    "category": "Time",
    "description": "The time between evening and morning.",
  },

  // Emotion / Support Vocabulary
  "cheering": {
    "category": "Emotion/Support",
    "description": "Showing happiness and encouragement.",
  },

  // Connectors & Others
  "a": {
    "category": "Connectors/Other",
    "description": "A helper word used often.",
  },
  "about": {
    "category": "Connectors/Other",
    "description": "A helper word used often.",
  },
  "he": {
    "category": "Connectors/Other",
    "description": "A word that talks about a boy or man.",
  },
  "to": {
    "category": "Connectors/Other",
    "description": "A helper word used often.",
  },
  "inside": {
    "category": "Connectors/Other",
    "description": "A helper word used often.",
  },
  "of": {
    "category": "Connectors/Other",
    "description": "A helper word used often.",
  },
  "in": {
    "category": "Connectors/Other",
    "description": "A helper word used often.",
  },
  "zero": {
    "category": "Descriptive Words",
    "description": "The number 0.",
  },
  "one": {
    "category": "Connectors/Other",
    "description": "The number 1 or a single item.",
  },
  "picture": {
    "category": "Concepts",
    "description": "An image or drawing.",
  },
  "surface": {
    "category": "Descriptive Words",
    "description": "The outer layer of something.",
  },
  "another": {
    "category": "Connectors/Other",
    "description": "One more or different.",
  },
  "looking": {
    "category": "Action Verbs",
    "description": "Used eyes to see attentively.",
  },
  "far": {
    "category": "Descriptive Words",
    "description": "At a great distance.",
  },
  "away": {
    "category": "Connectors/Other",
    "description": "A helper word used often.",
  },
  "sami": {
    "category": "People",
    "description": "The main character in the story.",
  },
  "was": {
    "category": "Connectors/Other",
    "description": "A helper word used often.",
  },
  "wanted": {
    "category": "Action Verbs",
    "description": "Desired to have or do something.",
  },
  "more": {
    "category": "Connectors/Other",
    "description": "An additional amount.",
  },
  "back": {
    "category": "Connectors/Other",
    "description": "A helper word used often.",
  },
  "what": {
    "category": "Concepts",
    "description": "Used to ask about something.",
  },
  "with": {
    "category": "Connectors/Other",
    "description": "A helper word used often.",
  },
  "his": {
    "category": "Connectors/Other",
    "description": "A word showing something belongs to a boy or man.",
  },
  "how": {
    "category": "Concepts",
    "description": "Used to ask the way or method of something.",
  },
  "their": {
    "category": "Connectors/Other",
    "description": "A word showing something belongs to them.",
  },
  "becoming": {
    "category": "Action Verbs",
    "description": "Turning into or starting to be something.",
  },
  "an": {
    "category": "Connectors/Other",
    "description": "A helper word used often.",
  },
  "above": {
    "category": "Concepts",
    "description": "At a higher position.",
  },
  "as": {
    "category": "Connectors/Other",
    "description": "A helper word used often.",
  },
  "if": {
    "category": "Connectors/Other",
    "description": "A helper word used often.",
  },
  "they": {
    "category": "Connectors/Other",
    "description": "A word that talks about a group of people.",
  },
  "him": {
    "category": "Connectors/Other",
    "description": "A word that talks about a boy or man.",
  },
  "on": {
    "category": "Connectors/Other",
    "description": "A helper word used often.",
  },
  "knew": {
    "category": "Action Verbs",
    "description": "Understood or remembered something.",
  },
  "day": {
    "category": "Time",
    "description": "The time from sunrise to sunset.",
  },
  "would": {
    "category": "Connectors/Other",
    "description": "Shows something likely to happen.",
  },
  "them": {
    "category": "Connectors/Other",
    "description": "A word that talks about more than one person.",
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
