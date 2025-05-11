import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';

class KaraokeSentenceScreen extends StatefulWidget {
  const KaraokeSentenceScreen({super.key});

  @override
  _KaraokeSentenceScreenState createState() => _KaraokeSentenceScreenState();
}

class _KaraokeSentenceScreenState extends State<KaraokeSentenceScreen> {
  late AudioPlayer audioPlayer;
  late stt.SpeechToText speech;
  bool isListening = false;
  String recognizedText = "";
  double score = 0.0;
  int stars = 0;
  int currentSentenceIndex = 0;
  int currentWordIndex = 0;
  List<String> matchedWords = [];
  String parentId = "";

  List<Map<String, String>> sentences = [
    {
      "text": "الشمس تشرق كل صباح وتنير السماء بالضوء الذهبي",
      "audio": "audio/shams.mp3",
      "image": "images/sun.png",
    },
    {
      "text": "الطائر يحلق في السماء ويسافر عبر الرياح",
      "audio": "audio/taer.mp3",
      "image": "images/bird.png",
    },
    {
      "text": "المدينه مليئه بالصوت والحركه والشوارع مكتظه بالناس",
      "audio": "audio/madina.mp3",
      "image": "images/city.png",
    },
  ];

  Map<String, String> get currentSentence => sentences[currentSentenceIndex];

  @override
  void initState() {
    super.initState();
    audioPlayer = AudioPlayer();
    speech = stt.SpeechToText();
    fetchParentId();
  }

  Future<void> fetchParentId() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      parentId = user.uid;

      final parentRef =
          FirebaseFirestore.instance.collection('parents').doc(parentId);
      final parentDoc = await parentRef.get();

      if (!parentDoc.exists) {
        await parentRef.set({
          'createdAt': FieldValue.serverTimestamp(),
          'email': user.email,
        });
        print("Parent ID created successfully!");
      }
    } catch (e) {
      print("Error creating parent ID: $e");
    }
  }

  Future<String?> fetchChildId() async {
    try {
      if (parentId.isEmpty) return null;

      final childrenSnapshot = await FirebaseFirestore.instance
          .collection('parents')
          .doc(parentId)
          .collection('children')
          .get();

      if (childrenSnapshot.docs.isNotEmpty) {
        return childrenSnapshot.docs.first.id;
      } else {
        print("No children found for this parent.");
        return null;
      }
    } catch (e) {
      print("Error fetching child ID: $e");
      return null;
    }
  }

  Future<void> saveScore(
      String childId, int sentenceIndex, double score) async {
    try {
      if (parentId.isEmpty) {
        print("Parent ID not set yet.");
        return;
      }

      await FirebaseFirestore.instance
          .collection('parents')
          .doc(parentId)
          .collection('children')
          .doc(childId)
          .collection('scores')
          .doc('Arabic')
          .set({
        'level1': {
          'sentence_$sentenceIndex': score,
        },
      }, SetOptions(merge: true));

      print("Score saved successfully!");
    } catch (e) {
      print("Error saving score: $e");
    }
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

  void evaluateResult() async {
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

    // Fetch the child ID before saving the score
    String? childId = await fetchChildId();
    if (childId != null) {
      saveScore(childId, currentSentenceIndex, score);
    }

    setState(() {});
  }

  void nextSentence() {
    setState(() {
      if (currentSentenceIndex < sentences.length - 1) {
        currentSentenceIndex++;
        recognizedText = "";
        matchedWords = [];
        score = 0.0;
        stars = 0;
        currentWordIndex = 0;
      } else {
        print("All sentences completed.");
      }
    });

    playAudio(currentSentence["audio"]!);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('karaoke_title'.tr()),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.48,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Image.asset(
                      currentSentence["image"]!,
                      width: 180,
                      height: 180,
                      fit: BoxFit.fill,
                    ),
                    const SizedBox(height: 40),
                    Text(
                      currentSentence["text"]!,
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.play_arrow),
                label: Text('play_sentence'.tr()),
                onPressed: () => playAudio(currentSentence["audio"]!),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                icon: Icon(isListening ? Icons.stop : Icons.mic),
                label: Text(isListening ? 'stop'.tr() : 'start_speaking'.tr()),
                onPressed: isListening
                    ? () {
                        speech.stop();
                        setState(() {
                          isListening = false;
                          evaluateResult();
                        });
                      }
                    : startListening,
              ),
              const SizedBox(height: 24),
              Text('spoken_text'.tr(),
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text(
                recognizedText,
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              if (!isListening && recognizedText.isNotEmpty) ...[
                Text(
                  '${'evaluation'.tr()}: ${score.toStringAsFixed(1)}%',
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 8),
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: buildStars()),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: nextSentence,
                  icon: const Icon(Icons.navigate_next),
                  label: Text('new_sentence'.tr()),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
