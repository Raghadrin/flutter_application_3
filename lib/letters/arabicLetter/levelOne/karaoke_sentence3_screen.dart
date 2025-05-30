import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_application_3/letters/arabicLetter/levelOne/evaluation2_screen.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class KaraokeSentenceLevel3Screen extends StatefulWidget {
  const KaraokeSentenceLevel3Screen({super.key});

  @override
  _KaraokeSentenceLevel3ScreenState createState() =>
      _KaraokeSentenceLevel3ScreenState();
}

class _KaraokeSentenceLevel3ScreenState
    extends State<KaraokeSentenceLevel3Screen> {
  late AudioPlayer audioPlayer;
  late stt.SpeechToText speech;
  bool isListening = false;
  bool isPlaying = false;
  String recognizedText = "";
  double score = 0.0;
  int stars = 0;
  int currentSentenceIndex = 0;
  Map<String, bool> wordMatchResults = {};

  List<Map<String, String>> sentences = [
    {
      "text":
          "كان سامر فتى ذكيًا يحب القراءة والعلوم. في يوم امتحان الرياضيات، رأى زميلًا يغش من ورقة طالب آخر. شعر بالارتباك، ولم يعرف كيف يتصرف. حاول التركيز، ولم يستطع.",
      "audio": "audio/samer1.mp3",
    },
    {
      "text":
          "عاد سامر إلى المنزل وهو قلق. فكر كثيرًا: هل يخبر المعلمة أم يصمت؟ خاف أن يظن زملاؤه أنه واشٍ. بقي صامتًا أثناء العشاء، ولم يكن مستعدًا للكلام.",
      "audio": "audio/samer2.mp3",
    },
    {
      "text":
          "في اليوم التالي، أخبر سامر المعلمة بما رأى. شكرته وقالت إنها ستتصرف بالشكل المناسب. تحدثت مع الطالب وشرحَت له أهمية الأمانة. ثم أخبرت سامرًا أن تصرفه كان شجاعًا، وأثنت عليه أمام زملائه. شعر سامر بالفخر، لأنه اختار الصدق ونال احترام الجميع.",
      "audio": "audio/samer3.mp3",
    },
  ];

  Map<String, String> get currentSentence => sentences[currentSentenceIndex];

  @override
  void initState() {
    super.initState();
    audioPlayer = AudioPlayer();
    speech = stt.SpeechToText();

    audioPlayer.onPlayerComplete.listen((event) {
      setState(() => isPlaying = false);
    });
  }

  Future<void> toggleAudio(String path) async {
    if (isPlaying) {
      await audioPlayer.stop();
      setState(() => isPlaying = false);
    } else {
      setState(() => isPlaying = true);
      await audioPlayer.play(AssetSource(path));
    }
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
        pauseFor: const Duration(seconds: 5),
        listenFor: const Duration(minutes: 1),
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
    int correct = wordMatchResults.values.where((v) => v == true).length;
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
      isPlaying = false;
    });
  }

  List<TextSpan> buildHighlightedSentence() {
    String fullSentence = currentSentence["text"]!;
    List<String> words = fullSentence.split(RegExp(r'\s+'));
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
          color: color,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
      );
    }).toList();
  }

  void showEvaluation() {
    evaluateResult();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Evaluation2Screen(
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
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('🎤 كاريوكي الجمل - المستوى ٣'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
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
                valueColor:
                    const AlwaysStoppedAnimation<Color>(Colors.blueAccent),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: Icon(isPlaying ? Icons.stop : Icons.play_arrow),
                label: Text(isPlaying ? 'إيقاف الصوت' : 'استمع للجملة'),
                onPressed: () => toggleAudio(currentSentence["audio"]!),
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
                    Future.delayed(const Duration(seconds: 1), () {
                      showEvaluation();
                    });
                  } else {
                    startListening();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isListening
                      ? const Color.fromARGB(255, 255, 123, 114)
                      : const Color.fromARGB(255, 113, 247, 117),
                  foregroundColor: Colors.black,
                  minimumSize: Size(screenWidth * 0.8, 44),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
