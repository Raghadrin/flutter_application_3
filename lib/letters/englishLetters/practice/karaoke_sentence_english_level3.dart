
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'evaluation_english_screen.dart';

class KaraokeSentenceEnglishLevel3Screen extends StatefulWidget {
  const KaraokeSentenceEnglishLevel3Screen({super.key});

  @override
  State<KaraokeSentenceEnglishLevel3Screen> createState() =>
      _KaraokeSentenceEnglishLevel3ScreenState();
}

class _KaraokeSentenceEnglishLevel3ScreenState
    extends State<KaraokeSentenceEnglishLevel3Screen> with TickerProviderStateMixin {
  final FlutterTts flutterTts = FlutterTts();
  late stt.SpeechToText speech;
  bool isListening = false;
  bool isPlaying = false;

  String recognizedText = '';
  double score = 0.0;
  int stars = 0;
  int currentSentenceIndex = 0;
  int currentSpokenWordIndex = -1;

  Map<String, bool> wordMatchResults = {};
  List<String> spokenWordSequence = [];

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
  }

  Future<void> speakSentence() async {
    if (isPlaying) {
      await flutterTts.stop();
      setState(() => isPlaying = false);
    } else {
      await flutterTts.setLanguage("en-US");
      await flutterTts.setSpeechRate(0.45);
      setState(() => isPlaying = true);
      await flutterTts.speak(currentSentence["text"]!);
      flutterTts.setCompletionHandler(() {
        setState(() => isPlaying = false);
      });
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
        spokenWordSequence.clear();
        currentSpokenWordIndex = -1;
      });
      speech.listen(
        localeId: 'en_US',
        listenMode: stt.ListenMode.dictation,
        partialResults: true,
        listenFor: const Duration(seconds: 60),
        pauseFor: const Duration(seconds: 60),
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
    List<String> expectedWords = expected
        .split(RegExp(r'\s+'))
        .map((w) => w.replaceAll(RegExp(r'[^\w]'), '').toLowerCase())
        .toList();

    List<String> spokenWords = recognizedText
        .split(RegExp(r'\s+'))
        .map((w) => w.replaceAll(RegExp(r'[^\w]'), '').toLowerCase())
        .toList();

    wordMatchResults.clear();
    spokenWordSequence = spokenWords;

    for (var word in expectedWords) {
      wordMatchResults[word] = spokenWords.contains(word);
    }

    if (spokenWords.isNotEmpty) {
      String lastSpoken = spokenWords.last;
      int index = expectedWords.indexOf(lastSpoken);
      if (index != -1) currentSpokenWordIndex = index;
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

    List<String> correctWords =
        wordMatchResults.entries.where((e) => e.value).map((e) => e.key).toList();
    List<String> wrongWords =
        wordMatchResults.entries.where((e) => !e.value).map((e) => e.key).toList();

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
        currentSentenceIndex = 0;
      }
      recognizedText = '';
      score = 0.0;
      stars = 0;
      wordMatchResults.clear();
      spokenWordSequence.clear();
      currentSpokenWordIndex = -1;
    });
  }

  List<InlineSpan> buildHighlightedSentence() {
    String sentence = currentSentence["text"]!;
    List<String> words = sentence.split(RegExp(r'\s+'));

    return List.generate(words.length, (i) {
      String originalWord = words[i];
      String cleanWord = originalWord.replaceAll(RegExp(r'[^\w]'), '').toLowerCase();

      if (!isListening && recognizedText.isNotEmpty) {
        if (wordMatchResults[cleanWord] == true) {
          return TextSpan(
            text: '$originalWord ',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
          );
        } else {
          return TextSpan(
            text: '$originalWord ',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red),
          );
        }
      } else if (i == currentSpokenWordIndex) {
        return WidgetSpan(
          child: TweenAnimationBuilder(
            tween: Tween<double>(begin: 1.0, end: 1.1),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
            builder: (context, scale, child) {
              return Transform.scale(
                scale: scale,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(color: Colors.blueAccent.withOpacity(0.6), blurRadius: 10, spreadRadius: 1),
                    ],
                  ),
                  child: Text(
                    '$originalWord ',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                ),
              );
            },
          ),
        );
      } else {
        return TextSpan(
          text: '$originalWord ',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black54),
        );
      }
    });
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
              valueColor: const AlwaysStoppedAnimation<Color>(Color.fromARGB(255, 116, 170, 252)),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: Icon(isPlaying ? Icons.stop : Icons.volume_up),
              label: Text(isPlaying ? 'Stop Reading' : 'Read Sentence'),
              onPressed: speakSentence,
              style: ElevatedButton.styleFrom(
                backgroundColor: isPlaying ? const Color.fromARGB(255, 255, 212, 212) : const Color.fromARGB(255, 255, 238, 190),
                foregroundColor: Colors.black,
                minimumSize: Size(screenWidth * 0.8, 44),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: Icon(isListening ? Icons.stop : Icons.mic),
              label: Text(isListening ? 'Stop' : 'Start Speaking'),
              style: ElevatedButton.styleFrom(
                backgroundColor: isListening ? const Color.fromARGB(255, 255, 204, 204) : const Color.fromARGB(255, 204, 255, 204),
                foregroundColor: Colors.black,
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
                        builder: (_) => EvaluationEnglishScreen(
                          recognizedText: recognizedText,
                          score: score,
                          stars: stars,
                          level: 'level3',
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
            const SizedBox(height: 16),
            if (!isListening && recognizedText.isNotEmpty)
              ElevatedButton.icon(
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Finish and Check'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  foregroundColor: Colors.black,
                  minimumSize: Size(screenWidth * 0.8, 44),
                ),
                onPressed: () {
                  evaluateResult();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EvaluationEnglishScreen(
                        recognizedText: recognizedText,
                        score: score,
                        stars: stars,
                        level: 'level3',
                        wordMatchResults: wordMatchResults,
                        onNext: () {
                          Navigator.pop(context);
                          nextSentence();
                        },
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
