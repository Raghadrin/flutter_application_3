// lib/letters/englishLetters/practice/karaoke_sentence_english_screen.dart

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

  // accumulate each sentence's score
  final List<double> _sessionScores = [];

 Map<String, Map<String, String>> wordCategoriesLevel1 = {
     // People
  "liam": {
    "category": "People",
    "description": "The boy participating in the science fair."
  },
  "teacher": {
    "category": "People",
    "description": "The person who instructs students at school."
  },
  "students": {
    "category": "People",
    "description": "Learners attending classes at school."
  },
  "judges": {
    "category": "People",
    "description": "Experts evaluating projects at the science fair."
  },
  "team": {
    "category": "People",
    "description": "A group collaborating on the project."
  },

  // Places / Events
  "school": {
    "category": "Places",
    "description": "The building where students learn."
  },
  "halls": {
    "category": "Places",
    "description": "Wide corridors inside a building."
  },
  "downstairs": {
    "category": "Places",
    "description": "The lower level of a building."
  },
  "science": {
    "category": "Subjects",
    "description": "The systematic study of the natural world."
  },
  "fair": {
    "category": "Events",
    "description": "A gathering for showcasing and judging projects."
  },

  // Objects
  "bag": {
    "category": "Objects",
    "description": "A container used to carry items."
  },
  "materials": {
    "category": "Objects",
    "description": "Items needed for the science project."
  },
  "posters": {
    "category": "Objects",
    "description": "Printed boards used for displaying information."
  },
  "robot": {
    "category": "Objects",
    "description": "A machine built to perform tasks."
  },

  // Concepts / Nouns
  "breakfast": {
    "category": "Nouns",
    "description": "The first meal of the day."
  },
  "inventions": {
    "category": "Concepts",
    "description": "New creative devices or ideas."
  },
  "questions": {
    "category": "Nouns",
    "description": "Sentences used to elicit information."
  },
  "presentation": {
    "category": "Nouns",
    "description": "The act of showing and explaining a project to an audience."
  },
  "journey": {
    "category": "Nouns",
    "description": "The process of experience or travel."
  },
  "result": {
    "category": "Concepts",
    "description": "The outcome of an action or event."
  },
  "work": {
    "category": "Nouns",
    "description": "Effort performed to achieve a goal."
  },
  "excitement": {
    "category": "Concepts",
    "description": "A feeling of eager enthusiasm."
  },

  // Time
  "early": {
    "category": "Time",
    "description": "Before the usual time."
  },
  "before": {
    "category": "Time",
    "description": "Earlier than a particular event."
  },
  "time": {
    "category": "Time",
    "description": "A measure of when events occur."
  },

  // Descriptive Words
  "big": {
    "category": "Descriptive Words",
    "description": "Large in size."
  },
  "colorful": {
    "category": "Descriptive Words",
    "description": "Having bright, varied colors."
  },
  "unique": {
    "category": "Descriptive Words",
    "description": "Being the only one of its kind."
  },
  "confidently": {
    "category": "Descriptive Words",
    "description": "In a self-assured manner."
  },
  "thoughtful": {
    "category": "Descriptive Words",
    "description": "Showing careful consideration."
  },
  "proud": {
    "category": "Descriptive Words",
    "description": "Feeling deep satisfaction or pleasure."
  },

  // Action Verbs
  "woke": {
    "category": "Action Verbs",
    "description": "Stopped sleeping and became awake."
  },
  "packed": {
    "category": "Action Verbs",
    "description": "Filled a container with items."
  },
  "checked": {
    "category": "Action Verbs",
    "description": "Examined something to ensure correctness."
  },
  "hurried": {
    "category": "Action Verbs",
    "description": "Moved quickly."
  },
  "buzzing": {
    "category": "Action Verbs",
    "description": "Made a humming sound of excitement."
  },
  "greeted": {
    "category": "Action Verbs",
    "description": "Welcomed someone with a greeting."
  },
  "joined": {
    "category": "Action Verbs",
    "description": "Became part of a group."
  },
  "explained": {
    "category": "Action Verbs",
    "description": "Made an idea clear to others."
  },
  "help": {
    "category": "Action Verbs",
    "description": "Provided assistance."
  },
  "listened": {
    "category": "Action Verbs",
    "description": "Paid attention to sound."
  },
  "asked": {
    "category": "Action Verbs",
    "description": "Requested information by questioning."
  },
  "felt": {
    "category": "Action Verbs",
    "description": "Experienced an emotion."
  },
  "paid": {
    "category": "Action Verbs",
    "description": "Gave attention or effort to something."
  },
  "knew": {
    "category": "Action Verbs",
    "description": "Had knowledge of something."
  },
  "learned": {
    "category": "Action Verbs",
    "description": "Gained information or skill."
  },

  // Connectors / Other
  "and": {
    "category": "Connectors/Other",
    "description": "A helper word used to join words or phrases."
  },
  "the": {
    "category": "Connectors/Other",
    "description": "A word used to refer to a specific item or person."
  },
  "for": {
    "category": "Connectors/Other",
    "description": "Indicates purpose or reason."
  },
  "to": {
    "category": "Connectors/Other",
    "description": "Indicates direction or purpose."
  },
  "all": {
    "category": "Connectors/Other",
    "description": "Refers to the whole quantity."
  },
  "no": {
    "category": "Connectors/Other",
    "description": "A word expressing negation."
  }
  };

  final List<Map<String, String>> sentences = [
    { "text": "Liam woke up early and packed his bag for the big science fair. He checked that he had all the materials he needed and hurried downstairs to eat breakfast before heading out." },
    { "text": "At school, the halls were buzzing with excitement. Students carried colorful posters and unique inventions. Liam greeted his teacher and joined his team near their project display." },
    { "text": "When it was time to present, Liam confidently explained how their robot could help with household chores. The judges listened carefully and asked thoughtful questions." },
    { "text": "After the presentation, Liam felt proud. His hard work had paid off. He knew that no matter the result, he had given his best and learned so much during the journey." },
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
      listenFor: const Duration(seconds: 60),
      pauseFor: const Duration(seconds: 3),
      onResult: (val) async {
        recognizedText = val.recognizedWords;
        _updateMatchedWords();
        matchedWordCount = recognizedText
            .split(RegExp(r'\s+'))
            .where((w) => w.trim().isNotEmpty)
            .length;

        if (val.finalResult) {
          await _evaluateResult();
          if (!mounted) return;

          // 1️⃣ Show FinalFeedbackScreen for this sentence
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => FinalFeedbackScreen(
                averageScore: score,
                totalStars: stars,
                level: 'level1',
              ),
            ),
          );

          if (!mounted) return;
          // 2️⃣ Then show detailed EvaluationEnglishScreen
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EvaluationEnglishScreen(
                recognizedText: recognizedText,
                score: score,
                stars: stars,
                wordMatchResults: wordMatchResults,
                onNext: () {
                  Navigator.pop(context);
                  _nextSentence();
                },
                wordCategories: wordCategoriesLevel1,
                level: 'level1',
              ),
            ),
          );
        }
      },
    );
  }

  void _updateMatchedWords() {
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

  Future<void> _evaluateResult() async {
    final correct = wordMatchResults.values.where((v) => v).length;
    final total = wordMatchResults.length;
    score = total > 0 ? (correct / total) * 100 : 0.0;
    stars = score >= 90 ? 3 : (score >= 60 ? 2 : (score > 0 ? 1 : 0));

    _sessionScores.add(score);
    // … (your Firestore save logic, if any) …
  }

  void _nextSentence() {
    setState(() {
      if (currentSentenceIndex < sentences.length - 1) {
        currentSentenceIndex++;
      } else {
        // end of session → final summary as before
        final avgPct = _sessionScores.isEmpty
            ? 0.0
            : _sessionScores.reduce((a, b) => a + b) / _sessionScores.length;
        final avgStars = avgPct >= 90
            ? 3
            : (avgPct >= 60 ? 2 : (avgPct > 0 ? 1 : 0));

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => FinalFeedbackScreen(
              averageScore: avgPct,
              totalStars: avgStars,
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
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(title: const Text('🎤 Karaoke Reading – Level 1')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
            children: [
            Container(
              constraints: BoxConstraints(
              minHeight: 80,
              maxHeight: MediaQuery.of(context).size.height * 0.35,
              ),
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))],
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
              valueColor: const AlwaysStoppedAnimation(Color(0xFF6DAFFC)),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: Icon(isPlaying ? Icons.stop : Icons.volume_up),
              label: Text(isPlaying ? 'Stop Reading' : 'Read Sentence'),
              onPressed: speakSentence,
              style: ElevatedButton.styleFrom(
                backgroundColor: isPlaying ? Color(0xFFFFAAAA) : Color(0xFFFFE7B0),
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
                backgroundColor: isListening ? Color(0xFFFFCCCC) : Color(0xFFCCFFCC),
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
