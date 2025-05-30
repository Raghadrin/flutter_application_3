import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'evaluation_screen.dart'; // تأكد أن هذا الملف موجود

class KaraokeSentenceScreen extends StatefulWidget {
  const KaraokeSentenceScreen({super.key});

  @override
  State<KaraokeSentenceScreen> createState() => _KaraokeSentenceScreenState();
}

class _KaraokeSentenceScreenState extends State<KaraokeSentenceScreen> {
  late AudioPlayer audioPlayer;
  late stt.SpeechToText speech;
  bool isListening = false;
  String recognizedText = "";
  double score = 0.0;
  int stars = 0;
  int currentSentenceIndex = 0;
  Map<String, bool> wordMatchResults = {};

  List<Map<String, String>> sentences = [
    {
      "text":
          "في كل صباح تشرق الشمس من الأفق البعيد، وتنثر أشعتها الذهبية على السماء فتملأ الكون نورًا ودفئًا وتوقظ الطبيعة من نومها لتبدأ يوماً جديداً مفعماً بالحياة.",
      "audio": "audio/shams.mp3",
    },
    {
      "text":
          "يحلق الطائر عالياً في السماء الزرقاء، ناشرًا جناحيه في رحاب الفضاء، ويسافر بخفة عبر الرياح، كأنّه يعانق الغيوم ويغني للحرية في كل نسمة تمر من حوله.",
      "audio": "audio/taer.mp3",
    },
    {
      "text":
          "في كل زاوية صدى مرتفع، وزحام لا ينتهي، أصوات مركبات تتقاطع، وناس تمشي بين المباني والطرقات، كل شيء يتحرك بسرعة دون توقف أو سكون",
      "audio": "audio/madina.mp3",
    },
  ];

  Map<String, String> get currentSentence => sentences[currentSentenceIndex];

  @override
  void initState() {
    super.initState();
    audioPlayer = AudioPlayer();
    speech = stt.SpeechToText();
  }

  Future<void> playAudio(String path) async {
    await audioPlayer.stop();
    await audioPlayer.play(AssetSource(path));
  }

  Future<void> saveKaraokeEvaluation({
    required String sentence,
    required String recognizedText,
    required List<String> correctWords,
    required List<String> wrongWords,
    required double score,
    required int stars,
  }) async {
    try {
      String? parentId = "";
      String? childId = "";

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print("User not logged in");
        return;
      }
      parentId = user.uid;

      final childrenSnapshot = await FirebaseFirestore.instance
          .collection('parents')
          .doc(parentId)
          .collection('children')
          .get();

      if (childrenSnapshot.docs.isNotEmpty) {
        childId = childrenSnapshot.docs.first.id;
      } else {
        print("No children found for this parent.");
        return;
      }

      if (parentId.isEmpty || childId == null) {
        print("Cannot save evaluation: parentId or childId missing");
        return;
      }

      await FirebaseFirestore.instance
          .collection('parents')
          .doc(parentId)
          .collection('children')
          .doc(childId)
          .collection('karaoke_evaluations')
          .add({
        'sentence': sentence,
        'recognizedText': recognizedText,
        'correctWords': correctWords,
        'wrongWords': wrongWords,
        'score': score,
        'stars': stars,
        'timestamp': FieldValue.serverTimestamp(),
      });

      print("Karaoke evaluation saved successfully");
    } catch (e) {
      print("Error saving karaoke evaluation: $e");
    }
  }

  Future<void> startListening() async {
    bool available = await speech.initialize(
      onStatus: (val) {
        if (val == 'done') {
          setState(() => isListening = false);
        }
      },
      onError: (val) {
        print('Error: $val');
      },
    );
    if (available) {
      setState(() {
        isListening = true;
        recognizedText = "";
        wordMatchResults.clear();
      });
      speech.listen(
        localeId: 'ar_SA',
        listenMode: stt.ListenMode.dictation,
        partialResults: true,
        pauseFor: Duration(seconds: 5),
        listenFor: Duration(minutes: 1),
        onResult: (val) {
          setState(() {
            recognizedText = val.recognizedWords;
            updateMatchedWords();
          });
        },
      );
    }
  }

  void updateMatchedWords() {
    String expected = currentSentence["text"] ?? "";
    List<String> expectedWords = expected.split(RegExp(r'\s+'));
    List<String> spokenWords = recognizedText.split(RegExp(r'\s+'));

    wordMatchResults.clear();
    for (var word in expectedWords) {
      wordMatchResults[word] = spokenWords.contains(word);
    }
  }

  Future<void> evaluateResult() async {
    int correct = wordMatchResults.values.where((v) => v).length;
    int total = wordMatchResults.length;
    score = total > 0 ? (correct / total) * 100 : 0.0;

    if (score >= 90) {
      stars = 3;
    } else if (score >= 60) {
      stars = 2;
    } else if (score > 0) {
      stars = 1;
    } else {
      stars = 0;
    }
    // Extract correct and wrong words
    List<String> correctWords = wordMatchResults.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    List<String> wrongWords = wordMatchResults.entries
        .where((entry) => !entry.value)
        .map((entry) => entry.key)
        .toList();

    await saveKaraokeEvaluation(
      sentence: currentSentence["text"]!,
      recognizedText: recognizedText,
      correctWords: correctWords,
      wrongWords: wrongWords,
      score: score,
      stars: stars,
    );
    setState(() {});
  }

  void nextSentence() {
    setState(() {
      if (currentSentenceIndex < sentences.length - 1) {
        currentSentenceIndex++;
      } else {
        currentSentenceIndex = 0;
      }
      recognizedText = "";
      score = 0.0;
      stars = 0;
      wordMatchResults.clear();
    });
  }

  List<TextSpan> buildHighlightedSentence() {
    String sentence = currentSentence["text"]!;
    List<String> words = sentence.split(RegExp(r'\s+'));
    return words.map((word) {
      bool? matched = wordMatchResults[word];
      Color color;
      if (matched == true) {
        color = Colors.green;
      } else if (matched == false) {
        color = Colors.red;
      } else {
        color = Colors.black;
      }

      return TextSpan(
        text: '$word ',
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('🎤 كاريوكي الجمل - المستوى ١'),
      ),
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
                    offset: Offset(0, 4),
                  )
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
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.play_arrow),
              label: const Text('استمع للجملة'),
              onPressed: () => playAudio(currentSentence["audio"]!),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                backgroundColor: Colors.blueAccent,
                minimumSize: Size(screenWidth * 0.8, 44),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: Icon(isListening ? Icons.stop : Icons.mic),
              label: Text(isListening ? 'إيقاف' : 'ابدأ التحدث'),
              style: ElevatedButton.styleFrom(
                backgroundColor: isListening ? Colors.red : Colors.green,
                minimumSize: Size(screenWidth * 0.8, 44),
              ),
              onPressed: () {
                if (isListening) {
                  speech.stop();
                  setState(() => isListening = false);
                  Future.delayed(const Duration(seconds: 1), () {
                    evaluateResult();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EvaluationScreen(
                          recognizedText: recognizedText,
                          score: score,
                          stars: stars,
                          wordMatchResults: wordMatchResults,
                          onNext: () {
                            Navigator.pop(context);
                            nextSentence();
                          },
                        ),
                      ),
                    );
                  });
                } else {
                  startListening();
                }
              },
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
