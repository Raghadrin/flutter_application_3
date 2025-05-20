import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class EnglishLevel2Screen extends StatefulWidget {
  final String sentence;
  const EnglishLevel2Screen({super.key, required this.sentence});

  @override
  State<EnglishLevel2Screen> createState() => _EnglishLevel2ScreenState();
}

class _EnglishLevel2ScreenState extends State<EnglishLevel2Screen> {
  late FlutterTts flutterTts;
  late stt.SpeechToText speech;
  late PageController pageController;
  String recognizedText = '';
  Map<int, String> feedbackPerWord = {};
  Color feedbackColor = Colors.transparent;

  @override
  void initState() {
    super.initState();
    flutterTts = FlutterTts();
    flutterTts.setLanguage("en-US");
    flutterTts.setSpeechRate(0.4);
    speech = stt.SpeechToText();
    pageController = PageController(viewportFraction: 0.95);
  }

  Future<void> speak(String text) async {
    await flutterTts.stop();
    await flutterTts.speak(text);
  }

  Future<void> evaluateWord(String expectedWord, int wordIndex) async {
  bool available = await speech.initialize();
  if (!available) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Microphone not available', style: TextStyle(fontSize: 20)),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  setState(() {
    recognizedText = '';
    feedbackColor = Colors.transparent;
    feedbackPerWord[wordIndex] = '🎤 Listening...';
  });

  // Speak encouragement before starting
  await speak("Let me hear you say it!");

  speech.listen(
    localeId: 'en_US',
    partialResults: false,
    onResult: (val) async {
      recognizedText = val.recognizedWords.trim().toLowerCase();
      final expected = expectedWord.toLowerCase();
      final similarity = _calculateSimilarity(recognizedText, expected);

      String result;
      Color color;
      String speechFeedback;

      if (recognizedText == expected) {
        result = '🌟 Awesome!\nPerfect!';
        color = Colors.green;
        speechFeedback = "Wow! You said it perfectly! Great job!";
      } else if (similarity >= 0.7) {
        result = '👍 Very Close!\nAlmost there!';
        color = Colors.orange;
        speechFeedback = "Good try! You're almost there! Say it with me: $expectedWord";
      } else {
        result = '💪 Keep Trying!\nYou can do it!';
        color = Colors.blue;
        speechFeedback = "Nice try! Let's try again. Say: $expectedWord";
      }

      setState(() {
        feedbackColor = color;
        feedbackPerWord[wordIndex] = result;
      });

      // Add celebratory confetti if perfect
      if (recognizedText == expected) {
        _showConfetti();
      }

      await speak(speechFeedback);
    },
    onSoundLevelChange: (level) {
      // Visual feedback for microphone input
      setState(() {
        feedbackPerWord[wordIndex] = '🎤 ${'🔊' * (level * 10).toInt()}';
      });
    },
  );
}

double _calculateSimilarity(String a, String b) {
  if (a.isEmpty || b.isEmpty) return 0.0;
  if (a == b) return 1.0;

  final distance = _levenshteinDistance(a, b);
  final maxLength = a.length > b.length ? a.length : b.length;
  return 1.0 - (distance / maxLength);
}

int _levenshteinDistance(String a, String b) {
  final matrix = List.generate(a.length + 1, (i) => List.filled(b.length + 1, 0));
  
  for (var i = 0; i <= a.length; i++) matrix[i][0] = i;
  for (var j = 0; j <= b.length; j++) matrix[0][j] = j;

  for (var i = 1; i <= a.length; i++) {
    for (var j = 1; j <= b.length; j++) {
      final cost = a[i - 1] == b[j - 1] ? 0 : 1;
      matrix[i][j] = [
        matrix[i - 1][j] + 1,
        matrix[i][j - 1] + 1,
        matrix[i - 1][j - 1] + cost
      ].reduce((value, element) => value < element ? value : element);
    }
  }
  
  return matrix[a.length][b.length];
}

void _showConfetti() {
  // Implement confetti animation here
  // You can use the confetti package: https://pub.dev/packages/confetti
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('🎉 Yay! Perfect!', style: TextStyle(fontSize: 24)),
      backgroundColor: Colors.green,
      duration: Duration(seconds: 2),
    ),
  );
}

  List<String> splitLetters(String word) => word.split('');

  Widget buildFeedback(String? feedback) {
    return feedback != null && feedback.isNotEmpty
        ? AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.only(top: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: feedbackColor.withOpacity(0.1),
              border: Border.all(color: feedbackColor, width: 3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              feedback,
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: feedbackColor),
              textAlign: TextAlign.center,
            ),
          )
        : const SizedBox.shrink();
  }

  Widget buildLetterTab() {
    final words = widget.sentence.split(' ');

    return PageView.builder(
      itemCount: words.length,
      controller: pageController,
      itemBuilder: (context, index) {
        final word = words[index];
        final letters = splitLetters(word);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(word, style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),
              Wrap(
                spacing: 12,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: letters.asMap().entries.map((entry) {
                  final i = entry.key;
                  final letter = entry.value;
                  final color = Colors.primaries[i % Colors.primaries.length].shade200;
                  bool isTapped = false;

                  return StatefulBuilder(
                    builder: (context, setState) {
                      return InkWell(
                        onTap: () async {
                          setState(() => isTapped = true);
                          await speak(letter);
                          await Future.delayed(const Duration(milliseconds: 500));
                          setState(() => isTapped = false);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: isTapped ? Colors.green.shade200 : color,
                            border: Border.all(color: Colors.orange, width: 2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(letter, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.volume_up, size: 20),
                    label: const Text("Speak Word", style: TextStyle(fontSize: 18)),
                    onPressed: () => speak(word),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(width: 15),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.mic, size: 20),
                    label: const Text("Evaluate", style: TextStyle(fontSize: 18)),
                    onPressed: () => evaluateWord(word, index),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.arrow_back, size: 20),
                    label: const Text("Previous", style: TextStyle(fontSize: 18)),
                    onPressed: () {
                      if (index > 0) {
                        pageController.animateToPage(index - 1,
                            duration: const Duration(milliseconds: 400), curve: Curves.ease);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.arrow_forward, size: 20),
                    label: const Text("Next", style: TextStyle(fontSize: 18)),
                    onPressed: () {
                      if (index < words.length - 1) {
                        pageController.animateToPage(index + 1,
                            duration: const Duration(milliseconds: 400), curve: Curves.ease);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              buildFeedback(feedbackPerWord[index]),
              const SizedBox(height: 20),
              Text("❓ What is the first letter?", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: List.generate(3, (i) {
                  final options = [letters.first, 'B', 'C'];
                  final choice = options[i];
                  return ElevatedButton(
                    onPressed: () {
                      final isCorrect = choice == letters.first;
                      final msg = isCorrect ? '✅ Correct!' : '❌ Wrong!';
                      final color = isCorrect ? Colors.green : Colors.red;
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: Text(msg, style: TextStyle(color: color, fontSize: 26)),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context), 
                              child: const Text("OK", style: TextStyle(fontSize: 20)),
                        ),
                          ],
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade100,
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text(choice, style: const TextStyle(fontSize: 20)),
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildSentenceTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          const Text("📖 Let's read the sentence!", 
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.orange)),
          const SizedBox(height: 25),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.brown.shade50,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.brown.shade200, width: 2),
            ),
            child: Text(widget.sentence, 
                textAlign: TextAlign.center, 
                style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.brown)),
          ),
          const SizedBox(height: 25),
          ElevatedButton.icon(
            icon: const Icon(Icons.volume_up, size: 20),
            label: const Text("Listen", style: TextStyle(fontSize: 25)),
            onPressed: () => speak(widget.sentence),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            icon: const Icon(Icons.mic, size: 20),
            label: const Text("Speak it", style: TextStyle(fontSize: 25)),
            onPressed: () => evaluateWord(widget.sentence, -1),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepOrange,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 24),
          buildFeedback(feedbackPerWord[-1]),
        ],
      ),
    );
  }

  Widget buildSpellingGame() {
    final List<String> wordList = ["apple", "school", "car", "airport"];
    final PageController controller = PageController();

    return PageView.builder(
      controller: controller,
      itemCount: wordList.length,
      itemBuilder: (context, index) {
        final word = wordList[index];
        List<String> shuffled = splitLetters(word)..shuffle();
        List<String> selected = [];

        return StatefulBuilder(
          builder: (context, setState) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text("🎧 Listen and build the word", 
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () => speak(word),
                    icon: const Icon(Icons.volume_up, size: 20),
                    label: const Text("Play", style: TextStyle(fontSize: 20)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 25),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: shuffled.map((char) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selected.add(char);
                            shuffled.remove(char);
                          });
                        },
                        child: Chip(
                          label: Text(char, style: const TextStyle(fontSize: 28)),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          backgroundColor: Colors.orange.shade100,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  if (selected.isNotEmpty)
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: selected.map((c) => Chip(
                        label: Text(c, style: const TextStyle(fontSize: 28)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        backgroundColor: Colors.green.shade100,
                      )).toList(),
                    ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      final correct = selected.join() == word;
                      setState(() {
                        feedbackColor = correct ? Colors.green : Colors.red;
                        feedbackPerWord[index + 100] = correct ? '✅ Well done!' : '❌ Try again';
                      });
                      speak(correct ? "Well done!" : "Try again");
                    },
                    child: const Text("Check", style: TextStyle(fontSize: 24)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  buildFeedback(feedbackPerWord[index + 100]),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget buildWordRecognitionGame() {
    final List<Map<String, String>> exercises = [
      {"correct": "tree", "wrong": "trea"},
      {"correct": "house", "wrong": "houze"},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(18),
      itemCount: exercises.length,
      itemBuilder: (context, index) {
        final correct = exercises[index]["correct"]!;
        final wrong = exercises[index]["wrong"]!;
        final options = [correct, wrong]..shuffle();

        return Column(
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.volume_up, size: 20),
              label: const Text("Play Word", style: TextStyle(fontSize: 20)),
              onPressed: () => speak(correct),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 20),
            ...options.map((option) => ElevatedButton(
                  onPressed: () {
                    final isCorrect = option == correct;
                    setState(() {
                      feedbackColor = isCorrect ? Colors.green : Colors.red;
                      feedbackPerWord[200 + index] = isCorrect ? "✅ Correct" : "❌ Wrong";
                    });
                    speak(isCorrect ? "Correct" : "Wrong");
                  },
                  child: Text(option, style: const TextStyle(fontSize: 20)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade100,
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    minimumSize: const Size(200, 60),
                  ),
                )),
            const SizedBox(height: 16),
            buildFeedback(feedbackPerWord[200 + index]),
            const Divider(height: 40, thickness: 2),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 253, 249, 228),
        appBar: AppBar(
          backgroundColor: Colors.orange,
          title: const Text(
            "📘 Sentence Learning",
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            indicatorWeight: 4,
            labelStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            tabs: [
              Tab(text: 'Letters'),
              Tab(text: 'Sentence'),
              Tab(text: 'Spelling'),
              Tab(text: 'Word Recognition'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            buildLetterTab(),
            buildSentenceTab(),
            buildSpellingGame(),
            buildWordRecognitionGame(),
          ],
        ),
      ),
    );
  }
}