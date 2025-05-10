import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:audioplayers/audioplayers.dart';
import 'package:easy_localization/easy_localization.dart';

class QuizAScreen extends StatefulWidget {
  const QuizAScreen({super.key});

  @override
  _QuizAScreenState createState() => _QuizAScreenState();
}

class _QuizAScreenState extends State<QuizAScreen> {
  final AudioPlayer audioPlayer = AudioPlayer();
  final flutterTts = FlutterTts();
  final stt.SpeechToText speech = stt.SpeechToText();
  final List<String> messages = [
    "ممتاز",
    "رائع",
    "عمل جيد",
    "أنت رائع",
    "جهد رائع"
  ];

  final List<Map<String, String>> quizData = [
    {
      "paragraph":
          "اليوم ذهبنا إلى الحديقة، كانت الشمس مشرقة، لعبنا على الأرجوحة واستمتعنا",
      "target":
          "اليوم ذهبنا إلى الحديقة، كانت الشمس مشرقة، لعبنا على الأرجوحة واستمتعنا",
      "audioPath": "audio/alyaoum.mp3",
    },
    {
      "paragraph":
          "كان عيد ميلادي الأسبوع الماضي. حصلت على كعكة كبيرة وبالونات. جاء أصدقائي للعب معي",
      "target":
          "كان عيد ميلادي الأسبوع الماضي. حصلت على كعكة كبيرة وبالونات. جاء أصدقائي للعب معي",
      "audioPath": "audio/eid.mp3",
    },
    {
      "paragraph":
          "في الصيف الماضي، سافرنا إلى الغابة في رحلة تخييم. رأينا أشجارًا طويلة وطيورًا.",
      "target":
          "في الصيف الماضي، سافرنا إلى الغابة في رحلة تخييم. رأينا أشجارًا طويلة وطيورًا.",
      "audioPath": "audio/saif.mp3",
    },
  ];

  int currentIndex = 0;
  double score = 0;
  bool isListening = false;
  bool isPreparing = false;
  String spokenText = '';
  double sentenceScore = 0;
  bool showNext = false;
  String? motivationalMessage;
  int recordingTimeLeft = 0;
  String? childId;
  final Duration maxTime = Duration(minutes: 3);
  Duration timeLeft = Duration(minutes: 3);
  Timer? timer;
  Timer? recordingTimer;

  @override
  void initState() {
    super.initState();
    fetchChildId();
    startTimer();
  }

  Future<void> fetchChildId() async {
    // Fetch child ID from Firebase (Assume FirebaseAuth is already set up and authenticated)
    var user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      var snapshot = await FirebaseFirestore.instance
          .collection('parents')
          .doc(user.uid) // Assuming user is the parent
          .collection('children')
          .limit(1) // Assuming one child for now
          .get();

      if (snapshot.docs.isNotEmpty) {
        setState(() {
          childId = snapshot.docs.first.id; // Get child ID
        });
      }
    }
  }

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (timeLeft.inSeconds == 0) {
        timer.cancel();
        _showFinalScore();
      } else {
        setState(() {
          timeLeft -= Duration(seconds: 1);
        });
      }
    });
  }

  String formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(duration.inMinutes)}:${twoDigits(duration.inSeconds.remainder(60))}";
  }

  Future<void> playStartSound() async {
    await flutterTts.setSpeechRate(1.0);
    await flutterTts.speak("ابدأ الآن");
  }

  Future<void> evaluate(String sentence) async {
    bool available = await speech.initialize();
    if (!available) return;

    setState(() {
      spokenText = '';
      sentenceScore = 0;
      motivationalMessage = null;
      isPreparing = true;
      isListening = false;
      showNext = false;
      recordingTimeLeft = 0;
    });

    await playStartSound();
    await Future.delayed(Duration(milliseconds: 500));

    Duration listenDuration = Duration(seconds: 50);

    setState(() {
      isPreparing = false;
      isListening = true;
      recordingTimeLeft = listenDuration.inSeconds;
    });

    speech.listen(
      onResult: (result) {
        spokenText = result.recognizedWords;
        if (sentence.isNotEmpty) {
          sentenceScore = calculateScore(sentence, spokenText);
        }

        if (sentenceScore >= 80) {
          score += 1;
          motivationalMessage = messages[Random().nextInt(messages.length)];
          showNext = true;
        } else {
          motivationalMessage = "حاول مرة أخرى";
        }

        setState(() => isListening = false);
        speech.stop();
        recordingTimer?.cancel();
      },
      localeId: "ar_SA",
      listenMode: stt.ListenMode.dictation,
      listenFor: listenDuration,
      pauseFor: Duration(seconds: 5),
      partialResults: false,
    );

    recordingTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (recordingTimeLeft <= 1) {
        timer.cancel();
        setState(() => isListening = false);
        speech.stop();
      } else {
        setState(() {
          recordingTimeLeft--;
        });
      }
    });
  }

  double calculateScore(String original, String spoken) {
    original = original.toLowerCase().trim().replaceAll(RegExp(r'[^\w\s]'), '');
    spoken = spoken.toLowerCase().trim().replaceAll(RegExp(r'[^\w\s]'), '');
    int distance = levenshtein(original, spoken);
    int maxLength = max(original.length, spoken.length);
    return ((1 - distance / maxLength) * 100).clamp(0, 100);
  }

  int levenshtein(String s, String t) {
    if (s == t) return 0;
    if (s.isEmpty) return t.length;
    if (t.isEmpty) return s.length;

    List<List<int>> matrix =
        List.generate(s.length + 1, (_) => List<int>.filled(t.length + 1, 0));
    for (int i = 0; i <= s.length; i++) matrix[i][0] = i;
    for (int j = 0; j <= t.length; j++) matrix[0][j] = j;

    for (int i = 1; i <= s.length; i++) {
      for (int j = 1; j <= t.length; j++) {
        int cost = s[i - 1] == t[j - 1] ? 0 : 1;
        matrix[i][j] = [
          matrix[i - 1][j] + 1,
          matrix[i][j - 1] + 1,
          matrix[i - 1][j - 1] + cost
        ].reduce(min);
      }
    }
    return matrix[s.length][t.length];
  }

  void _showFinalScore() {
    double percent = (score / quizData.length) * 100;
    String emoji = percent >= 100
        ? "💯"
        : percent >= 80
            ? "🌟"
            : percent >= 60
                ? "👍"
                : "🙂";

    // Save score to Firebase
    saveScoreToFirebase(percent);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("$emoji ${'final_score'.tr()}",
            textAlign: TextAlign.center, style: TextStyle(fontSize: 22)),
        content: Text(
            "${'your_score'.tr(args: [
                  score.toInt().toString(),
                  quizData.length.toString()
                ])}",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20)),
        actions: [
          TextButton(
            child: Text("عودة", style: TextStyle(fontSize: 18)),
            onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
          ),
        ],
      ),
    );
  }

  Future<void> saveScoreToFirebase(double score) async {
    if (childId != null) {
      // Assuming the child collection has a `quizScores` sub-collection
      await FirebaseFirestore.instance
          .collection('parents')
          .doc(FirebaseAuth.instance.currentUser?.uid) // Parent UID
          .collection('children')
          .doc(childId)
          .collection('quizScores')
          .add({
        'score': score,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    recordingTimer?.cancel();
    speech.stop();
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = quizData[currentIndex];
    final paragraph = data["paragraph"]!;
    final audioPath = data["audioPath"]!;

    return Scaffold(
      backgroundColor: Colors.orange.shade50,
      appBar: AppBar(
        title: const Text("📝 الاختبار",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.orange.shade300,
        centerTitle: true,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text("⏱ ${formatTime(timeLeft)}",
                  style: const TextStyle(fontSize: 22)),
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "⭐ نتيجتك: ${score.toInt()} / ${quizData.length}",
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
                ),
                child: Text(
                  paragraph,
                  style: const TextStyle(
                      fontSize: 22, height: 1.8, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.right,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () async =>
                    await audioPlayer.play(AssetSource(audioPath)),
                icon: const Icon(Icons.volume_up, size: 30),
                label: const Text("استمع", style: TextStyle(fontSize: 20)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade200,
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                ),
              ),
              const SizedBox(height: 24),
              if (isPreparing)
                const Text("🎯 استعد للتسجيل...",
                    style: TextStyle(fontSize: 20, color: Colors.deepOrange),
                    textAlign: TextAlign.right),
              if (isListening)
                Text("🎙️ تسجيل... $recordingTimeLeft ثانية",
                    style: const TextStyle(fontSize: 20, color: Colors.blue),
                    textAlign: TextAlign.right),
              ElevatedButton.icon(
                onPressed: () => evaluate(paragraph),
                icon: const Icon(Icons.mic, size: 30),
                label: const Text("تسجيل", style: TextStyle(fontSize: 20)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlueAccent.shade100,
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                ),
              ),
              const SizedBox(height: 24),
              if (spokenText.isNotEmpty)
                Text(
                  "🗣️ قلت: \"$spokenText\"",
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w500),
                  textAlign: TextAlign.right,
                ),
              if (sentenceScore > 0)
                Text(
                  "النتيجة: ${sentenceScore.toStringAsFixed(1)} %",
                  style: TextStyle(
                    color: sentenceScore >= 80 ? Colors.green : Colors.red,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.right,
                ),
              if (motivationalMessage != null)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    motivationalMessage!,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: motivationalMessage == "حاول مرة أخرى"
                          ? Colors.red
                          : Colors.green,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              if (showNext)
                ElevatedButton.icon(
                  onPressed: () {
                    if (currentIndex == quizData.length - 1) {
                      _showFinalScore();
                    } else {
                      setState(() {
                        currentIndex++;
                        spokenText = '';
                        sentenceScore = 0;
                        motivationalMessage = null;
                        showNext = false;
                      });
                    }
                  },
                  icon: const Icon(Icons.navigate_next),
                  label: Text(
                      currentIndex == quizData.length - 1
                          ? "🏁 إنهاء"
                          : "التالي",
                      style: const TextStyle(fontSize: 22)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pinkAccent.shade100,
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 24),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}
