import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

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
  Map<String, bool> wordMatchResults = {};

  List<Map<String, String>> sentences = [
    {
      "text": "الشمس تشرق كل صباح وتنير السماء بالضوء الذهبي",
      "audio": "audio/shams.mp3",
    },
    {
      "text": "الطائر يحلق في السماء ويسافر عبر الرياح",
      "audio": "audio/taer.mp3",
    },
    {
      "text": "المدينه مليئه بالصوت والحركه والشوارع مكتظه بالناس",
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
      onError: (val) {
        print('Error: $val');
      },
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

    wordMatchResults.clear();
    for (var word in expectedWords) {
      bool matched = spokenWords.contains(word);
      wordMatchResults[word] = matched;
    }
  }

  void evaluateResult() {
    int correctCount = wordMatchResults.values.where((v) => v == true).length;
    int totalWords = wordMatchResults.length;
    score = totalWords > 0 ? (correctCount / totalWords) * 100 : 0.0;

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
      matchedWords = [];
      currentWordIndex = 0;
    });
  }

  List<Widget> buildStars() {
    return List.generate(
      3,
      (i) => Icon(
        i < stars ? Icons.star : Icons.star_border,
        color: Colors.amber,
        size: 20,
      ),
    );
  }

  List<TextSpan> buildHighlightedSentence() {
    String fullSentence = currentSentence["text"]!;
    List<String> words = fullSentence.split(RegExp(r'\s+'));
    List<TextSpan> spans = [];

    for (var word in words) {
      bool? isCorrect = wordMatchResults[word];
      Color color = isCorrect == true
          ? Colors.green
          : isCorrect == false
              ? Colors.red
              : Colors.black;

      spans.add(
        TextSpan(
          text: '$word ',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      );
    }

    return spans;
  }

  Widget buildWordBox(String title, Color color) {
    return Container(
      padding: EdgeInsets.all(6),
      decoration: BoxDecoration(
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(8),
        color: color.withOpacity(0.1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
          SizedBox(height: 4),
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: wordMatchResults.entries
                .where((entry) =>
                    (color == Colors.green && entry.value) ||
                    (color == Colors.red && !entry.value))
                .map((entry) => Chip(
                      backgroundColor: color.withOpacity(0.2),
                      label: Text(entry.key,
                          style: TextStyle(color: color, fontSize: 12)),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(title: Text('🎤 كاريوكي الجمل', style: TextStyle(fontSize: 16))),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: buildHighlightedSentence(),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 8),
              ElevatedButton.icon(
                icon: Icon(Icons.play_arrow, size: 16),
                label: Text('استمع للجملة', style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(screenWidth * 0.8, 36),
                  backgroundColor: Colors.blueAccent,
                ),
                onPressed: () => playAudio(currentSentence["audio"]!),
              ),
              SizedBox(height: 6),
              ElevatedButton.icon(
                icon: Icon(isListening ? Icons.stop : Icons.mic, size: 16),
                label: Text(isListening ? 'إيقاف' : 'ابدأ التحدث',
                    style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(screenWidth * 0.8, 36),
                  backgroundColor: isListening ? Colors.red : Colors.green,
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
              SizedBox(height: 8),
              Text('النص الذي قلته:',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text(
                recognizedText,
                style: TextStyle(fontSize: 12),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              if (!isListening && recognizedText.isNotEmpty) ...[
                Text('التقييم: ${score.toStringAsFixed(1)}%',
                    style: TextStyle(fontSize: 14)),
                Text(
                  'عدد الكلمات الصحيحة: ${wordMatchResults.values.where((v) => v).length} من ${wordMatchResults.length}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                        child: buildWordBox('✅ الكلمات الصحيحة:', Colors.green)),
                    SizedBox(width: 6),
                    Expanded(
                        child: buildWordBox('❌ الكلمات الخاطئة:', Colors.red)),
                  ],
                ),
                SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: buildStars(),
                ),
                SizedBox(height: 6),
                ElevatedButton.icon(
                  onPressed: nextSentence,
                  icon: Icon(Icons.navigate_next, size: 16),
                  label: Text('جملة جديدة', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(screenWidth * 0.6, 34),
                    backgroundColor: Colors.purple,
                  ),
                ),
              ],
              SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
