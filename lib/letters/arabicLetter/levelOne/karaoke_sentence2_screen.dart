import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'evaluation_screen.dart'; // تأكد من مسار الاستيراد

class KaraokeSentenceLevel2Screen extends StatefulWidget {
  const KaraokeSentenceLevel2Screen({super.key});

  @override
  _KaraokeSentenceLevel2ScreenState createState() => _KaraokeSentenceLevel2ScreenState();
}

class _KaraokeSentenceLevel2ScreenState extends State<KaraokeSentenceLevel2Screen> {
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
      "text": "ذهبت العائلة الى البحر وقضت وقتا ممتعا في السباحة وبناء القلاع الرملية",
      "audio": "audio/family.mp3",
    },
    {
      "text": "استيقظ سامي مبكرا وحمل حقيبته الجديده وذهب الى المدرسه بحماس كبير",
      "audio": "audio/school.mp3",
    },
    {
      "text": "اشتريت كتابا جديدا عن الفضاء وقرات عن الكواكب والنجوم والمجرات البعيده",
      "audio": "audio/book.mp3",
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

  Future<void> startListening() async {
    bool available = await speech.initialize(
      onStatus: (val) {
        if (val == 'done') {
          setState(() => isListening = false);
          // لا نقيم تلقائياً هنا
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
      bool matched = spokenWords.contains(word);
      wordMatchResults[word] = matched;
    }
  }

  void evaluateResult() {
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


  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text('🎤 كاريوكي الجمل - المستوى ٢'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(children: buildHighlightedSentence()),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              icon: Icon(Icons.play_arrow),
              label: Text('استمع للجملة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                minimumSize: Size(screenWidth * 0.8, 44),
              ),
              onPressed: () => playAudio(currentSentence["audio"]!),
            ),
            SizedBox(height: 12),
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
  Future.delayed(Duration(seconds: 1), () {
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
}
else {
                  startListening();
                }
              },
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
