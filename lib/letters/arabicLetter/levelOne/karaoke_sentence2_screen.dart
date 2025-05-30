import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'evaluation2_screen.dart';

class KaraokeSentenceLevel2Screen extends StatefulWidget {
  const KaraokeSentenceLevel2Screen({super.key});

  @override
  State<KaraokeSentenceLevel2Screen> createState() =>
      _KaraokeSentenceLevel2ScreenState();
}

class _KaraokeSentenceLevel2ScreenState extends State<KaraokeSentenceLevel2Screen>
    with TickerProviderStateMixin {
  late AudioPlayer audioPlayer;
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

  final List<Map<String, String>> sentences = [
    {
      "text":
          "انتقل عمر مع عائلته إلى مدينة جديدة. في أول يوم في المدرسة، شعر بالخجل. جلس في المقعد الأخير يراقب زملاءه وهم يتحدثون. ضحك البعض على رسمة قام برسمها، فشعر بالحزن وتساءل: \"هل سأبقى وحيدًا؟\"",
      "audio": "audio/omar1.mp3"
    },
    {
      "text":
          'في اليوم التالي، رأى عمر طفلًا يجلس وحده تحت شجرة. اقترب منه وقال: "مرحبًا، هل أستطيع الجلوس؟" رد الطفل مبتسمًا: "بالطبع، اسمي إياد وأنت؟" ورد عمر، "أنا عمر"، وشعر عمر بالراحة لأول مرة.',
      "audio": "audio/omar2.mp3"
    },
    {
      "text":
          'مع الوقت، أصبح عمر وإياد صديقين. شاركا في مسابقة لتصميم السيارات وفازا. قال عمر: "أنا سعيدٌ بصداقتنا"، ابتسم إياد وقال: "وأنا سعيد كذلك بها."',
      "audio": "audio/omar3.mp3"
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
        recognizedText = '';
        wordMatchResults.clear();
        spokenWordSequence.clear();
        currentSpokenWordIndex = -1;
      });
      speech.listen(
        localeId: 'ar_SA',
        listenMode: stt.ListenMode.dictation,
        partialResults: true,
        pauseFor: const Duration(seconds: 10),
        listenFor: const Duration(minutes: 2),
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

    await saveKaraokeEvaluation(
      sentence: currentSentence["text"]!,
      recognizedText: recognizedText,
      correctWords: correctWords,
      wrongWords: wrongWords,
      score: score,
      stars: stars,
    );
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
          .collection('level2')
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
      currentSpokenWordIndex = -1;
    });
  }

  List<InlineSpan> buildHighlightedSentence() {
    String sentence = currentSentence["text"]!;
    List<String> words = sentence.split(RegExp(r'\s+'));

    return List.generate(words.length, (i) {
      String word = words[i];

      if (!isListening && recognizedText.isNotEmpty) {
        if (wordMatchResults[word] == true) {
          return TextSpan(
            text: '$word ',
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.green),
          );
        } else {
          return TextSpan(
            text: '$word ',
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.red),
          );
        }
      } else if (i == currentSpokenWordIndex) {
        return WidgetSpan(
          child: TweenAnimationBuilder(
            tween: Tween<double>(begin: 1.0, end: 1.1),
            duration: const Duration(milliseconds: 1200),
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
                    '$word ',
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                ),
              );
            },
          ),
        );
      } else {
        return TextSpan(
          text: '$word ',
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black54),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(title: const Text('🎤 كاريوكي - المستوى ٢')),
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
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))],
                ),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(children: buildHighlightedSentence()),
                ),
              ),
              LinearProgressIndicator(
                value: (currentSentenceIndex + 1) / sentences.length,
                backgroundColor: Colors.grey[300],
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.blueAccent),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: Icon(isPlaying ? Icons.stop : Icons.play_arrow),
                label: Text(isPlaying ? 'إيقاف الصوت' : 'استمع للجملة'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isPlaying
                      ? const Color.fromARGB(255, 255, 220, 220)
                      : const Color.fromARGB(255, 255, 238, 180),
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
                  backgroundColor: isListening
                      ? const Color.fromARGB(255, 246, 110, 101)
                      : const Color.fromARGB(255, 136, 252, 140),
                  foregroundColor: Colors.black,
                  minimumSize: Size(screenWidth * 0.8, 44),
                ),
                onPressed: () {
                  if (isListening) {
                    speech.stop();
                    setState(() => isListening = false);
                    Future.delayed(Duration(seconds: 2), () {
                      evaluateResult();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => Evaluation2Screen(
                            recognizedText: recognizedText,
                            score: score,
                            stars: stars,
                            level: 'level2',
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
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
