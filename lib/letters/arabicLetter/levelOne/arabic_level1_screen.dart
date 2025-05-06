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
      "text": "المدن مليئه بالصوت والحركه والشوارع مكتظه بالناس",
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
        size: 50,
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
          fontSize: 32,
          fontWeight: FontWeight.bold,
          fontFamily: 'Arial',
          color: index == currentWordIndex ? Colors.blue : Colors.black,
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
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // الصورة والنص داخل حاوية أنيقة
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                textDirection: TextDirection.rtl,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.asset(
                      currentSentence["image"]!,
                      width: 150,
                      height: 150,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: SingleChildScrollView(
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

            const SizedBox(height: 20),

            ElevatedButton.icon(
              icon: const Icon(Icons.play_arrow, size: 30),
              label: const Text('استمع للجملة',
                  style: TextStyle(fontSize: 24, fontFamily: 'Arial')),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
              ),
              onPressed: () => playAudio(currentSentence["audio"]!),
            ),
            const SizedBox(height: 20),

            ElevatedButton.icon(
              icon: Icon(isListening ? Icons.stop : Icons.mic, size: 30),
              label: Text(isListening ? 'إيقاف' : 'ابدأ التحدث',
                  style: const TextStyle(fontSize: 24, fontFamily: 'Arial')),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                backgroundColor: isListening ? Colors.red : Colors.green,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
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
            const SizedBox(height: 30),

            const Text('النص الذي قلته',
                style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Arial')),
            const SizedBox(height: 10),
            Text(
              recognizedText,
              style: const TextStyle(fontSize: 24, fontFamily: 'Arial'),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            if (!isListening && recognizedText.isNotEmpty) ...[
              Text(' % التقييم: ${score.toStringAsFixed(1)}',
                  style: const TextStyle(fontSize: 28, fontFamily: 'Arial')),
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: buildStars()),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: nextSentence,
                icon: const Icon(Icons.navigate_next, size: 30),
                label: const Text('جملة جديدة',
                    style: TextStyle(fontSize: 24, fontFamily: 'Arial')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
