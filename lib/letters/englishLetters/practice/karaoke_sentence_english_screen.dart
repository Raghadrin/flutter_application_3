import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_3/letters/englishLetters/practice/evaluation_english_screen.dart';
import 'package:flutter_application_3/letters/englishLetters/practice/final_feedback_screen.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class KaraokeSentenceEnglishScreen extends StatefulWidget {
  const KaraokeSentenceEnglishScreen({super.key});

  @override
  State<KaraokeSentenceEnglishScreen> createState() =>
      _KaraokeSentenceEnglishScreenState();
}

class _KaraokeSentenceEnglishScreenState
    extends State<KaraokeSentenceEnglishScreen>
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

  Map<String, Map<String, String>> wordCategoriesLevel1 = {
    "after": {
      "category": "Time",
      "description": "Means something happens later.",
    },
    "all": {
      "category": "Connectors/Other",
      "description": "A helper word used often.",
    },
    "and": {
      "category": "Connectors/Other",
      "description": "A helper word used often.",
    },
    "asked": {
      "category": "Action Verbs",
      "description": "Means someone said a question.",
    },
    "at": {
      "category": "Connectors/Other",
      "description": "A helper word used often.",
    },
    "bag": {
      "category": "Objects",
      "description": "Something you carry your things in.",
    },
    "before": {
      "category": "Time",
      "description": "Means something happens earlier.",
    },
    "best": {
      "category": "Descriptive Words",
      "description": "Better than all the others.",
    },
    "big": {
      "category": "Descriptive Words",
      "description": "Means large in size.",
    },
    "breakfast": {
      "category": "Daily Life",
      "description": "The meal you eat in the morning.",
    },
    "buzzing": {
      "category": "Connectors/Other",
      "description": "A helper word used often.",
    },
    "unique": {
      "category": "Descriptive Words",
      "description": "Very special or one-of-a-kind.",
    },
    "up": {
      "category": "Connectors/Other",
      "description": "A helper word used often.",
    },
    "was": {
      "category": "Connectors/Other",
      "description": "A helper word used often.",
    },
    "were": {
      "category": "Connectors/Other",
      "description": "A helper word used often.",
    },
    "when": {
      "category": "Connectors/Other",
      "description": "A helper word used often.",
    },
    "with": {
      "category": "Connectors/Other",
      "description": "A helper word used often.",
    },
    "woke": {
      "category": "Action Verbs",
      "description": "Means you stopped sleeping.",
    },
    "work": {
      "category": "Connectors/Other",
      "description": "A helper word used often.",
    },
    "him": {
      "category": "Connectors/Other",
      "description": "A word that talks about a boy or man.",
    },
    "liam": {
      "category": "People",
      "description": "The main character in the story.",
    },
    "listened": {
      "category": "Action Verbs",
      "description": "Means you paid attention to sounds or someone talking.",
    },
    "materials": {
      "category": "School Vocabulary",
      "description": "Things you need to do a school project.",
    },
    "packed": {
      "category": "Action Verbs",
      "description": "Put things into a bag or box for taking somewhere.",
    },
    "paid": {
      "category": "Action Verbs",
      "description": "Means you gave something in return, like time or effort.",
    },
    "posters": {
      "category": "Objects",
      "description": "Large papers with pictures or writing used to show ideas.",
    },
    "present": {
      "category": "Action Verbs",
      "description": "To show or talk about something to others.",
    },
    "presentation": {
      "category": "School Vocabulary",
      "description": "When you explain your project to others.",
    },
    "project": {
      "category": "School Vocabulary",
      "description": "Work you do to show something you’ve learned.",
    },
    "proud": {
      "category": "Descriptive Words",
      "description": "A good feeling when you’ve done something well.",
    },
    "questions": {
      "category": "School Vocabulary",
      "description": "Things people ask to learn more.",
    },
    "result": {
      "category": "School Vocabulary",
      "description": "What happens at the end of something you do.",
    },
    "robot": {
      "category": "Objects",
      "description": "A machine that can do tasks, like a helper.",
    },
    "school": {
      "category": "School Vocabulary",
      "description": "A place where you go to learn.",
    },
    "science": {
      "category": "School Vocabulary",
      "description": "A subject where you learn about nature and how things work.",
    },
    "students": {
      "category": "People",
      "description": "Kids who go to school to learn.",
    },
    "teacher": {
      "category": "People",
      "description": "A person who helps you learn at school.",
    },
    "team": {
      "category": "People",
      "description": "A group of people working together.",
    },
    "thoughtful": {
      "category": "Descriptive Words",
      "description": "Kind and careful in thinking about others.",
    },
    "time": {
      "category": "Time",
      "description": "When something happens, like day or night.",
    }
  };

  List<Map<String, String>> sentences = [
    {
      "text":
          "Liam woke up early and packed his bag for the big science fair. He checked that he had all the materials he needed and hurried downstairs to eat breakfast before heading out."
    },
    {
      "text":
          "At school, the halls were buzzing with excitement. Students carried colorful posters and unique inventions. Liam greeted his teacher and joined his team near their project display."
    },
    {
      "text":
          "When it was time to present, Liam confidently explained how their robot could help with household chores. The judges listened carefully and asked thoughtful questions."
    },
    {
      "text":
          "After the presentation, Liam felt proud. His hard work had paid off. He knew that no matter the result, he had given his best and learned so much during the journey."
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

  Map<String, List<String>> getCategoryAnalysis() {
    Map<String, List<String>> categoryIssues = {};

    wordMatchResults.forEach((word, isCorrect) {
      if (!isCorrect) {
        String? category =
            wordCategoriesLevel1[word.toLowerCase()]?["category"];
        if (category != null) {
          categoryIssues.putIfAbsent(category, () => []).add(word);
        }
      }
    });

    return categoryIssues;
  }

  Future<void> startListening() async {
    bool available = await speech.initialize(
      onStatus: (val) {
        if (val == 'done') {
          setState(() => isListening = false);
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
        listenFor: const Duration(seconds: 60),
        pauseFor: const Duration(seconds: 3),
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
                  wordCategories: wordCategoriesLevel1,  // ← new required parameter
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
          .collection('level1')
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
              level: 'level1',
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
      appBar: AppBar(title: const Text('🎤 Karaoke Reading - Level 1')),
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

// 🔁 Levenshtein Distance Helper
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
