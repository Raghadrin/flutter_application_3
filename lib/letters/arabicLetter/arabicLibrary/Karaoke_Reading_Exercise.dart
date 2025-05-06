import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class KaraokeReadingScreen extends StatefulWidget {
  const KaraokeReadingScreen({super.key});

  @override
  _KaraokeReadingScreenState createState() => _KaraokeReadingScreenState();
}

class _KaraokeReadingScreenState extends State<KaraokeReadingScreen> {
  late AudioPlayer audioPlayer;
  late stt.SpeechToText speech;
  bool isListening = false;
  String recognizedText = "";
  double score = 0.0;
  int stars = 0;
  int currentWordIndex = 0;
  int currentSentenceIndex = 0;
  List<String> spokenWords = [];

  List<List<Map<String, String>>> exercises = [
    [
      {"word": "انا", "audio": "audio/ana.mp3"},
      {"word": "العب", "audio": "audio/uheb.mp3"},
      {"word": "كره", "audio": "audio/qiraah.mp3"},
      {"word": "القدم", "audio": "audio/alkutub.mp3"},
    ],
    [
      {"word": "السماء", "audio": "audio/sama.mp3"},
      {"word": "زرقاء", "audio": "audio/zar.mp3"},
      {"word": "جميله", "audio": "audio/gam.mp3"},
    ],
  ];

  List<Map<String, String>> get currentWords => exercises[currentSentenceIndex];

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

  Future<void> playSentence() async {
    for (int i = 0; i < currentWords.length; i++) {
      setState(() {
        currentWordIndex = i;
      });
      await playAudio(currentWords[i]['audio']!);
      await Future.delayed(Duration(milliseconds: 1500));
    }
    setState(() {
      currentWordIndex = -1;
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
      onError: (val) {
        print('Error: $val');
      },
    );
    if (available) {
      setState(() {
        isListening = true;
        recognizedText = "";
        spokenWords = [];
        currentWordIndex = 0;
      });
      speech.listen(
        localeId: 'ar_SA',
        partialResults: true,
        onResult: (val) {
          setState(() {
            recognizedText = val.recognizedWords;
            checkCurrentWordProgress();
          });
        },
      );
    }
  }

  void checkCurrentWordProgress() {
    if (currentWordIndex >= currentWords.length) return;
    String currentExpectedWord = currentWords[currentWordIndex]['word'] ?? "";
    if (recognizedText.contains(currentExpectedWord)) {
      spokenWords.add(currentExpectedWord);
      currentWordIndex++;
      recognizedText = "";
      if (currentWordIndex >= currentWords.length) {
        speech.stop();
        setState(() {
          isListening = false;
        });
        evaluateResult();
      }
    }
  }

  void evaluateResult() {
    int matched = spokenWords.length;
    score = (matched / currentWords.length) * 100;
    if (score >= 90) {
      stars = 3;
    } else if (score >= 60) {
      stars = 2;
    } else if (score > 0) {
      stars = 1;
    } else {
      stars = 0;
    }
    setState(() {});
  }

  List<Widget> buildStars() {
    return List.generate(3, (i) {
      return Icon(
        i < stars ? Icons.star : Icons.star_border,
        color: Colors.amber,
        size: 40,
      );
    });
  }

  void resetExercise() {
    setState(() {
      recognizedText = "";
      score = 0.0;
      stars = 0;
      currentWordIndex = 0;
      spokenWords = [];
    });
  }

  void nextSentence() {
    setState(() {
      if (currentSentenceIndex < exercises.length - 1) {
        currentSentenceIndex++;
      } else {
        currentSentenceIndex = 0;
      }
      resetExercise();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text('🎤 كاريوكي القراءة', style: TextStyle(fontSize: 26)),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 12,
                    runSpacing: 12,
                    children: List.generate(currentWords.length, (index) {
                      return Container(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: index == currentWordIndex ? Colors.orange[300] : Colors.grey[300],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          currentWords[index]['word']!,
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                SizedBox(height: 30),
                ElevatedButton.icon(
                  icon: Icon(Icons.play_arrow),
                  label: Text('🔊 استمع إلى الجملة', style: TextStyle(fontSize: 20)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  onPressed: playSentence,
                ),
                SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: Icon(isListening ? Icons.stop : Icons.mic),
                  label: Text(isListening ? '🛑 إيقاف' : '🎙️ ابدأ التحدث', style: TextStyle(fontSize: 20)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isListening ? Colors.red : Colors.green,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  onPressed: () {
                    if (isListening) {
                      speech.stop();
                      setState(() => isListening = false);
                      evaluateResult();
                    } else {
                      startListening();
                    }
                  },
                ),
                SizedBox(height: 30),
                Text(
                  '✅ ما قلته:',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  spokenWords.join(' '),
                  style: TextStyle(fontSize: 22),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 30),
                if (!isListening && spokenWords.isNotEmpty) ...[
                  Text(
                    '📊 التقييم: ${score.toStringAsFixed(1)}%',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: buildStars(),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: nextSentence,
                    icon: Icon(Icons.arrow_forward),
                    label: Text('جملة جديدة', style: TextStyle(fontSize: 20)),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
