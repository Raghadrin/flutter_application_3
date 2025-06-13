import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_application_3/letters/arabicLetter/levelOne/FinalFeedbackScreenAr.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'evaluation2_screen.dart';

class KaraokeSentenceArabicScreen extends StatefulWidget {
  const KaraokeSentenceArabicScreen({super.key});

  @override
  State<KaraokeSentenceArabicScreen> createState() =>
      _KaraokeSentenceArabicScreenState();
}

class _KaraokeSentenceArabicScreenState
    extends State<KaraokeSentenceArabicScreen> with TickerProviderStateMixin {
  late stt.SpeechToText speech;
  late AudioPlayer audioPlayer;
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
  final Map<String, String> wordCategoriesAr = {
    'غابة': 'أماكن',
    'سلحفاة': 'حيوانات',
    'أرنب': 'حيوانات',
    'شجرة': 'أشياء',
    'بيت': 'أماكن',
    'الحيوانات': 'حيوانات',
    'الكل': 'أشخاص',
    'الشكل': 'مفاهيم',
    'كلام': 'مفاهيم',
    'مساعدة': 'مفاهيم',
    'خائف': 'صفات',
    'يبكي': 'أفعال',
    'ابتسمت': 'أفعال',
    'سارت': 'أفعال',
    'ركض': 'أفعال',
    'ضاعت': 'أفعال',
    'طيبة': 'صفات',
    'حكيمة': 'صفات',
    'بطيئة': 'صفات',
    'ذكية': 'صفات',
  };

  List<Map<String, String>> sentences = [
    {
      "text":
          "في غابة جميلة، كانت تعيش سلحفاة. كانت تمشي ببطء، لكنها تفكر بهدوء. كلما اختلفت الحيوانات، نادت السلحفاة. الكل يسمع كلامها لأنها حكيمة وطيبة.",
      "audio": "assets/audio/turtle1.mp3"
    },
    {
      "text":
          "في يوم من الأيام، ضاع أرنب صغير. ركض كثيرًا ولم يعرف طريق البيت. كان خائفًا ويبكي تحت الشجرة. جاءت السلحفاة وسألته: \"هل تحتاج مساعدة؟\"",
      "audio": "assets/audio/turtle2.mp3"
    },
    {
      "text":
          "سارت معه حتى وصل إلى بيته. قال الأرنب: \"كنت أظن السلاحف فقط بطيئة!\" ولكنك ذكية وتعرفين ما تفعلين. ابتسمت السلحفاة وقالت: \"لا تحكم من الشكل!\" ومن يومها، أصبح الأرنب صديقها.",
      "audio": "assets/audio/turtle3.mp3"
    }
  ];

  Map<String, String> get currentSentence => sentences[currentSentenceIndex];

  @override
  void initState() {
    super.initState();
    speech = stt.SpeechToText();
    audioPlayer = AudioPlayer();
  }

  Future<void> playAudio(String path) async {
    await audioPlayer.stop();
    await audioPlayer.play(AssetSource(path.replaceFirst("assets/", "")));
    setState(() => isPlaying = true);
    audioPlayer.onPlayerComplete.listen((event) {
      setState(() => isPlaying = false);
    });
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
        localeId: 'ar_SA',
        listenMode: stt.ListenMode.dictation,
        partialResults: true,
        listenFor: const Duration(seconds: 60),
        pauseFor: const Duration(
            seconds: 6), // <-- Increased pause duration from 3 to 6 seconds
        onResult: (val) async {
          recognizedText = val.recognizedWords;

          matchedWordCount = recognizedText
              .replaceAll(RegExp(r'[^\u0621-\u064A\s]'), '')
              .split(RegExp(r'\s+'))
              .where((w) => w.trim().isNotEmpty)
              .length;

          updateMatchedWords();

          if (val.finalResult) {
            await evaluateResult();
            if (!mounted) return;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => Evaluation2Screen(
                  recognizedText: recognizedText,
                  score: score,
                  stars: stars,
                  level: 'level1',
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
      );
    }
  }

  Map<String, List<String>> getCategoryAnalysis() {
    Map<String, List<String>> categoryIssues = {};

    wordMatchResults.forEach((word, isCorrect) {
      if (!isCorrect) {
        String? category = wordCategoriesAr[word.toLowerCase()];
        if (category != null) {
          categoryIssues.putIfAbsent(category, () => []).add(word);
        }
      }
    });

    return categoryIssues;
  }

  void updateMatchedWords() {
    String expected = currentSentence["text"] ?? "";

    List<String> expectedWords = expected
        .replaceAll(RegExp(r'[^\u0621-\u064A\s]'), '')
        .split(RegExp(r'\s+'));

    List<String> spokenWords = recognizedText
        .replaceAll(RegExp(r'[^\u0621-\u064A\s]'), '')
        .split(RegExp(r'\s+'));

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
    stars = (score >= 90)
        ? 3
        : (score >= 60)
            ? 2
            : (score > 0)
                ? 1
                : 0;

    categoryIssues = getCategoryAnalysis();
    await saveKaraokeEvaluation(
      sentence: currentSentence["text"]!,
      recognizedText: recognizedText,
      correctWords: wordMatchResults.entries
          .where((e) => e.value)
          .map((e) => e.key)
          .toList(),
      wrongWords: wordMatchResults.entries
          .where((e) => !e.value)
          .map((e) => e.key)
          .toList(),
      score: score,
      stars: stars,
    );
  }

  Future<void> saveKaraokeEvaluation({
    required String sentence,
    required String recognizedText,
    required List<String> correctWords,
    required List<String> wrongWords,
    required double score,
    required int stars,
  }) async {
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
        .doc('arKaraoke')
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
            builder: (_) => FinalFeedbackScreenAr(
              averageScore: totalScore / sentences.length,
              totalStars: (totalStars / sentences.length).round(),
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

    return List.generate(words.length, (i) {
      String word = words[i];
      String normalized = word.replaceAll(RegExp(r'[^\u0621-\u064A]'), '');
      Color color = Colors.black;

      if (isListening && i < matchedWordCount) {
        color = Colors.blue;
      } else if (!isListening && recognizedText.isNotEmpty) {
        if (wordMatchResults.containsKey(normalized)) {
          color = wordMatchResults[normalized]! ? Colors.green : Colors.red;
        }
      }

      return TextSpan(
        text: '$word ',
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
          title: const Text('🎤 كاريوكي - المستوى ١',
              style: TextStyle(fontSize: 18))),
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
            const SizedBox(height: 10),
            ElevatedButton.icon(
              icon: Icon(isPlaying ? Icons.stop : Icons.play_arrow),
              label: Text(isPlaying ? 'إيقاف الصوت' : 'استمع للجملة'),
              onPressed: () {
                if (isPlaying) {
                  audioPlayer.stop();
                  setState(() => isPlaying = false);
                } else {
                  playAudio(currentSentence["audio"]!);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isPlaying
                    ? const Color.fromARGB(255, 255, 220, 220)
                    : const Color.fromARGB(255, 255, 238, 180),
                foregroundColor: Colors.black,
                minimumSize: Size(screenWidth * 0.8, 44),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: Icon(isListening ? Icons.stop : Icons.mic),
              label: Text(isListening ? 'إيقاف' : 'ابدأ التحدث'),
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
                    ? const Color.fromARGB(255, 246, 110, 101)
                    : const Color.fromARGB(255, 125, 255, 129),
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
