import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:speech_to_text/speech_to_text.dart' as stt;

class KaraokeSentenceLevel2Screen extends StatefulWidget {
  const KaraokeSentenceLevel2Screen({super.key});

  @override
  _KaraokeSentenceLevel2ScreenState createState() =>
      _KaraokeSentenceLevel2ScreenState();
}

class _KaraokeSentenceLevel2ScreenState
    extends State<KaraokeSentenceLevel2Screen> {
  late AudioPlayer audioPlayer;
  late stt.SpeechToText speech;
  bool isListening = false;
  String recognizedText = "";
  double score = 0.0;
  int stars = 0;
  int currentSentenceIndex = 0;
  int currentWordIndex = 0;
  List<String> matchedWords = [];

  List<Map<String, String>> sentences = [
    {
      "text":
          "ذهبت العائله الى البحر وقضت وقتا ممتعا في السباحه وبناء القلاع الرمليه",
      "audio": "audio/family.mp3",
      "image": "images/family.png",
    },
    {
      "text":
          "استيقظ سامي مبكرا وحمل حقيبته الجديده وذهب الى المدرسه بحماس كبير",
      "audio": "audio/school.mp3",
      "image": "images/school.png",
    },
    {
      "text":
          "اشتريت كتابا جديدا عن الفضاء وقرات عن الكواكب والنجوم والمجرات البعيده",
      "audio": "audio/book.mp3",
      "image": "images/book.png",
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
    setState(() {
      currentWordIndex = 0;
    });
  }

  Future<void> startListening() async {
    bool available = await speech.initialize(
      onStatus: (val) {
        if (val == 'done') {
          setState(() => isListening = false);
          evaluateResult();
        }
      },
      onError: (val) => print('Error: $val'),
    );

    if (available) {
      setState(() {
        isListening = true;
        recognizedText = "";
        matchedWords = [];
        currentWordIndex = 0;
      });

      speech.listen(
        localeId: 'ar_SA',
        partialResults: true,
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

    if (currentWordIndex < expectedWords.length) {
      if (spokenWords.contains(expectedWords[currentWordIndex])) {
        matchedWords.add(expectedWords[currentWordIndex]);
        currentWordIndex++;
      }
    }
  }

  Future<String?> fetchChildId() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;

      final querySnapshot = await FirebaseFirestore.instance
          .collection('parents')
          .doc(user.uid)
          .collection('children')
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.id;
      }
    } catch (e) {
      print("Error fetching child ID: $e");
    }
    return null;
  }

  Future<void> saveScoreToFirestore(double score, int stars) async {
    try {
      final childId = await fetchChildId();
      if (childId == null) return;

      final docRef = FirebaseFirestore.instance
          .collection('parents')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('children')
          .doc(childId)
          .collection('scores')
          .doc('Arabic')
          .collection('level2')
          .doc('sentence_$currentSentenceIndex');

      await docRef.set({
        'score': score,
        'stars': stars,
        'timestamp': FieldValue.serverTimestamp(),
      });

      print("Score saved successfully!");
    } catch (e) {
      print("Error saving score: $e");
    }
  }

  void evaluateResult() {
    String expected = currentSentence["text"] ?? "";
    List<String> expectedWords = expected.split(RegExp(r'\s+'));

    score = (matchedWords.length / expectedWords.length) * 100;

    if (score >= 90) {
      stars = 5;
    } else if (score >= 75) {
      stars = 4;
    } else if (score >= 60) {
      stars = 3;
    } else if (score >= 40) {
      stars = 2;
    } else if (score > 0) {
      stars = 1;
    } else {
      stars = 0;
    }

    saveScoreToFirestore(score, stars); // Save the score to Firestore

    setState(() {});
  }

  void nextSentence() {
    setState(() {
      currentSentenceIndex = (currentSentenceIndex + 1) % sentences.length;
      recognizedText = "";
      score = 0.0;
      stars = 0;
      matchedWords = [];
      currentWordIndex = 0;
    });
  }

  List<Widget> buildStars() {
    return List.generate(
      5,
      (index) => Icon(
        index < stars ? Icons.star : Icons.star_border,
        color: Colors.amber,
        size: 30,
      ),
    );
  }

  List<TextSpan> buildHighlightedSentence() {
    List<String> words = currentSentence["text"]!.split(RegExp(r'\s+'));
    return words.asMap().entries.map((entry) {
      int index = entry.key;
      String word = entry.value;
      return TextSpan(
        text: '$word ',
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          fontFamily: 'Arial',
          color: index == currentWordIndex ? Colors.red : Colors.black,
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🎤 كاريوكي الجمل'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.28,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  textDirection: TextDirection.rtl,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        currentSentence["image"]!,
                        width: 150,
                        height: 300,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Center(
                        child: RichText(
                          textAlign: TextAlign.center,
                          textDirection: TextDirection.rtl,
                          text: TextSpan(children: buildHighlightedSentence()),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.play_arrow, size: 22),
                label: const Text('استمع للجملة',
                    style: TextStyle(fontSize: 18, fontFamily: 'Arial')),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => playAudio(currentSentence["audio"]!),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                icon: Icon(isListening ? Icons.stop : Icons.mic, size: 22),
                label: Text(isListening ? 'إيقاف' : 'ابدأ التحدث',
                    style: const TextStyle(fontSize: 18, fontFamily: 'Arial')),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  backgroundColor: isListening ? Colors.red : Colors.green,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  if (isListening) {
                    speech.stop();
                    setState(() => isListening = false);
                    evaluateResult(); // ✅ Only evaluate, don't move to next sentence
                  } else {
                    startListening();
                  }
                },
              ),
              const SizedBox(height: 24),
              const Text('النص الذي قلته',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Arial')),
              const SizedBox(height: 10),
              Text(
                recognizedText,
                style: const TextStyle(fontSize: 18, fontFamily: 'Arial'),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              if (!isListening && recognizedText.isNotEmpty) ...[
                Text(' % التقييم: ${score.toStringAsFixed(1)}',
                    style: const TextStyle(fontSize: 20, fontFamily: 'Arial')),
                const SizedBox(height: 8),
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: buildStars()),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: nextSentence,
                  icon: const Icon(Icons.navigate_next, size: 22),
                  label: const Text('جملة جديدة',
                      style: TextStyle(fontSize: 18, fontFamily: 'Arial')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 24),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
