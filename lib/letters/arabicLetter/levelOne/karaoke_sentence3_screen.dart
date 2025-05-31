import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'evaluation2_screen.dart';

class KaraokeSentenceLevel3Screen extends StatefulWidget {
  const KaraokeSentenceLevel3Screen({super.key});

  @override
  _KaraokeSentenceLevel3ScreenState createState() => _KaraokeSentenceLevel3ScreenState();
}

class _KaraokeSentenceLevel3ScreenState extends State<KaraokeSentenceLevel3Screen> with TickerProviderStateMixin {
  late AudioPlayer audioPlayer;
  late stt.SpeechToText speech;
  bool isListening = false;
  bool isPlaying = false;
  String recognizedText = "";
  double score = 0.0;
  int stars = 0;
  int currentSentenceIndex = 0;
  int currentSpokenWordIndex = -1;
  Map<String, bool> wordMatchResults = {};
  List<String> spokenWordSequence = [];

  List<Map<String, String>> sentences = [
    {
      "text": "كان سامر فتى ذكيًا يحب القراءة والعلوم. في يوم امتحان الرياضيات، رأى زميلًا يغش من ورقة طالب آخر. شعر بالارتباك، ولم يعرف كيف يتصرف. حاول التركيز، ولم يستطع.",
      "audio": "audio/samer1.mp3",
    },
    {
      "text": "عاد سامر إلى المنزل وهو قلق. فكر كثيرًا: هل يخبر المعلمة أم يصمت؟ خاف أن يظن زملاؤه أنه واشٍ. بقي صامتًا أثناء العشاء، ولم يكن مستعدًا للكلام.",
      "audio": "audio/samer2.mp3",
    },
    {
      "text": "في اليوم التالي، أخبر سامر المعلمة بما رأى. شكرته وقالت إنها ستتصرف بالشكل المناسب. تحدثت مع الطالب وشرحَت له أهمية الأمانة. ثم أخبرت سامرًا أن تصرفه كان شجاعًا، وأثنت عليه أمام زملائه. شعر سامر بالفخر، لأنه اختار الصدق ونال احترام الجميع.",
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
      await audioPlayer.setPlaybackRate(0.75);
      await audioPlayer.play(AssetSource(path));
    }
  }

  Future<void> startListening() async {
    bool available = await speech.initialize(
      onStatus: (val) {
        if (val == 'done') setState(() => isListening = false);
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
        localeId: 'ar_SA',
        listenMode: stt.ListenMode.dictation,
        partialResults: true,
        listenFor: const Duration(minutes: 3),
        pauseFor: const Duration(seconds: 10),
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
        .replaceAll(RegExp(r'[^ء-ي\s]'), '')
        .split(RegExp(r'\s+'));

    Set<String> spokenWordsSet = recognizedText
        .replaceAll(RegExp(r'[^ء-ي\s]'), '')
        .split(RegExp(r'\s+'))
        .toSet();

    wordMatchResults.clear();
    spokenWordSequence = spokenWordsSet.toList();

    for (String word in expectedWords) {
      bool matchFound = spokenWordsSet.any((spokenWord) {
        return levenshtein(word, spokenWord) <= 1;
      });
      wordMatchResults[word] = matchFound;
    }

    if (spokenWordSequence.isNotEmpty) {
      String lastSpoken = spokenWordSequence.last;
      int index = expectedWords.indexWhere((word) => levenshtein(word, lastSpoken) <= 1);
      if (index != -1) currentSpokenWordIndex = index;
    }
  }

  Future<void> evaluateResult() async {
    int correct = wordMatchResults.values.where((v) => v).length;
    int total = wordMatchResults.length;
    score = total > 0 ? (correct / total) * 100 : 0.0;
    stars = (score >= 90) ? 3 : (score >= 60) ? 2 : (score > 0) ? 1 : 0;

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
      'sentence': currentSentence["text"]!,
      'recognizedText': recognizedText,
      'correctWords': wordMatchResults.entries.where((e) => e.value).map((e) => e.key).toList(),
      'wrongWords': wordMatchResults.entries.where((e) => !e.value).map((e) => e.key).toList(),
      'score': score,
      'stars': stars,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  void showEvaluation() async {
    await evaluateResult();
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

  void nextSentence() {
    setState(() {
      currentSentenceIndex = (currentSentenceIndex + 1) % sentences.length;
      recognizedText = "";
      score = 0.0;
      stars = 0;
      wordMatchResults.clear();
      currentSpokenWordIndex = -1;
      isPlaying = false;
    });
  }

  List<InlineSpan> buildHighlightedSentence() {
    String sentence = currentSentence["text"]!;
    List<String> words = sentence.split(RegExp(r'\s+'));

    return List.generate(words.length, (i) {
      String word = words[i];
      String normalized = word.replaceAll(RegExp(r'[^ء-ي]'), '');
      bool matched = wordMatchResults[normalized] ?? false;

      if (!isListening && recognizedText.isNotEmpty) {
        return TextSpan(
          text: '$word ',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: matched ? Colors.green : Colors.red,
          ),
        );
      } else if (i == currentSpokenWordIndex) {
        return WidgetSpan(
          child: TweenAnimationBuilder(
            tween: Tween<double>(begin: 1.0, end: 1.1),
            duration: Duration(milliseconds: 700),
            builder: (context, scale, child) {
              return Transform.scale(
                scale: scale,
                child: Text(
                  '$word ',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              );
            },
          ),
        );
      } else {
        return TextSpan(
          text: '$word ',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(title: Text('🎤 كاريوكي الجمل - المستوى ٣')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              margin: EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
              ),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(children: buildHighlightedSentence()),
              ),
            ),
            LinearProgressIndicator(
              value: (currentSentenceIndex + 1) / sentences.length,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: Icon(isPlaying ? Icons.stop : Icons.play_arrow),
              label: Text(isPlaying ? 'إيقاف الصوت' : 'استمع للجملة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: isPlaying ? Color(0xFFFFDCDC) : Color(0xFFFFEEB4),
                foregroundColor: Colors.black,
                minimumSize: Size(screenWidth * 0.8, 44),
              ),
              onPressed: () => toggleAudio(currentSentence["audio"]!),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: Icon(isListening ? Icons.stop : Icons.mic),
              label: Text(isListening ? 'إيقاف' : 'ابدأ التحدث'),
              style: ElevatedButton.styleFrom(
                backgroundColor: isListening ? Color(0xFFF66E65) : Color.fromARGB(255, 141, 252, 144),
                foregroundColor: Colors.black,
                minimumSize: Size(screenWidth * 0.8, 44),
              ),
              onPressed: () {
                if (isListening) {
                  speech.stop();
                  setState(() => isListening = false);
                  Future.delayed(Duration(milliseconds: 300), () => showEvaluation());
                } else {
                  startListening();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Levenshtein distance function
int levenshtein(String s1, String s2) {
  List<List<int>> dp = List.generate(s1.length + 1, (_) => List.filled(s2.length + 1, 0));
  for (int i = 0; i <= s1.length; i++) dp[i][0] = i;
  for (int j = 0; j <= s2.length; j++) dp[0][j] = j;
  for (int i = 1; i <= s1.length; i++) {
    for (int j = 1; j <= s2.length; j++) {
      int cost = s1[i - 1] == s2[j - 1] ? 0 : 1;
      dp[i][j] = [dp[i - 1][j] + 1, dp[i][j - 1] + 1, dp[i - 1][j - 1] + cost].reduce((a, b) => a < b ? a : b);
    }
  }
  return dp[s1.length][s2.length];
}
