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
    if (!available) return;

    setState(() {
      recognizedText = '';
      feedbackColor = Colors.transparent;
    });

    speech.listen(
      localeId: 'en_US',
      partialResults: false,
      onResult: (val) async {
        recognizedText = val.recognizedWords;
        final spoken = recognizedText.trim().toLowerCase();
        final expected = expectedWord.trim().toLowerCase();

        final percentage = calculateSimilarityPercentage(expected, spoken);
        final color = percentage >= 80 ? Colors.green : Colors.red;

        setState(() {
          feedbackColor = color;
          feedbackPerWord[wordIndex] = "$percentage%";
        });

        await Future.delayed(const Duration(milliseconds: 300));
        await speak("You scored $percentage percent");
      },
    );
  }

int calculateSimilarityPercentage(String expected, String spoken) {
    final int distance = levenshtein(expected, spoken);
    final int maxLength = expected.length > 0 ? expected.length : 1;
    return (((1 - (distance / maxLength)) * 100).round()).clamp(0, 100);
  }

  int levenshtein(String s, String t) {
    if (s == t) return 0;
    if (s.isEmpty) return t.length;
    if (t.isEmpty) return s.length;

    List<List<int>> matrix = List.generate(
      s.length + 1,
      (_) => List.filled(t.length + 1, 0),
    );

    for (int i = 0; i <= s.length; i++) {
      matrix[i][0] = i;
    }
    for (int j = 0; j <= t.length; j++) {
      matrix[0][j] = j;
    }

    for (int i = 1; i <= s.length; i++) {
      for (int j = 1; j <= t.length; j++) {
        int cost = s[i - 1] == t[j - 1] ? 0 : 1;
        matrix[i][j] = [
          matrix[i - 1][j] + 1,
          matrix[i][j - 1] + 1,
          matrix[i - 1][j - 1] + cost
        ].reduce((a, b) => a < b ? a : b);
      }
    }

    return matrix[s.length][t.length];
  }

  List<String> splitLetters(String word) => word.split('');

  Widget buildFeedback(String? feedback) {
    return feedback != null && feedback.isNotEmpty
        ? AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.only(top: 10),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: feedbackColor.withOpacity(0.1),
              border: Border.all(color: feedbackColor, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              feedback,
              style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: feedbackColor),
              textAlign: TextAlign.center,
            ),
          )
        : const SizedBox.shrink();
  }




  Widget buildSpellingGame() {
    final List<String> wordList =  [
  "elephant",     // طويلة ومتعددة المقاطع
  "umbrella",     // بها ترتيب أحرف معقد نسبيًا
  "bicycle",      // بها تركيب غير شائع للمبتدئين
  "computer",     // كلمة مألوفة لكن بها تركيبة طويلة
  "mountain",     // صوتيًا وتراكبيًا أصعب من "car"
  "hospital",     // شائعة ولكن بها صعوبة في النطق
  "crocodile",    // طويلة وغير معتادة
  "backpack",     // تتكون من كلمتين مدمجتين
];

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
  {"correct": "language", "wrong": "langwage"},
  {"correct": "chocolate", "wrong": "choclate"},
  {"correct": "umbrella", "wrong": "umbrilla"},
  {"correct": "vegetable", "wrong": "vejetable"},
  {"correct": "elephant", "wrong": "eliphant"},
  {"correct": "beautiful", "wrong": "beautifull"},
  {"correct": "mountain", "wrong": "mounten"},
  {"correct": "crocodile", "wrong": "croccodile"},
  {"correct": "bicycle", "wrong": "bisycle"},
  {"correct": "hospital", "wrong": "hospetal"},
];


  final PageController controller = PageController();

  return PageView.builder(
    controller: controller,
    itemCount: exercises.length,
    itemBuilder: (context, index) {
      final correct = exercises[index]["correct"]!;
      final wrong = exercises[index]["wrong"]!;
      final options = [correct, wrong]..shuffle();

      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Question ${index + 1} of ${exercises.length}",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: const Icon(Icons.volume_up, size: 24),
              label: const Text("Play Word", style: TextStyle(fontSize: 22)),
              onPressed: () => speak(correct),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 30),
            ...options.map((option) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: ElevatedButton(
                onPressed: () {
                  final isCorrect = option == correct;
                  setState(() {
                    feedbackColor = isCorrect ? Colors.green : Colors.red;
                    feedbackPerWord[200 + index] = isCorrect ? "✅ Correct" : "❌ Wrong";
                  });
                  speak(isCorrect ? "Correct" : "Wrong");
                },
                child: Text(option, style: const TextStyle(fontSize: 24)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade100,
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  minimumSize: const Size(200, 60),
                ),
              ),
            )),
            const SizedBox(height: 20),
            buildFeedback(feedbackPerWord[200 + index]),
            const SizedBox(height: 30),
         Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    if (index > 0)
      ElevatedButton.icon(
        icon: const Icon(Icons.arrow_back, size: 32),
        label: const Text(
          "Previous",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        onPressed: () {
          controller.previousPage(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepOrange,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    if (index < exercises.length - 1)
      ElevatedButton.icon(
        icon: const Icon(Icons.arrow_forward, size: 32),
        label: const Text(
          "Next",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        onPressed: () {
          controller.nextPage(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
  ],
),

          ],
        ),
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    final words = widget.sentence.split(' ');

    return Directionality(
      textDirection: TextDirection.ltr,
      child: DefaultTabController(
        length: 4,
        child: Scaffold(
          backgroundColor: const Color.fromARGB(255, 253, 249, 228),
          appBar: AppBar(
            backgroundColor: Colors.orange,
            centerTitle: true,
            toolbarHeight: 56, // تصغير ارتفاع الشريط العلوي
            title:
                  const Text("🌟 Learn From Sentence"),
            bottom: const TabBar(
              labelStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              indicatorWeight: 3,
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
              // الحروف
              PageView.builder(
                itemCount: words.length,
                controller: pageController,
                itemBuilder: (context, index) {
                  final word = words[index];
                         final letters = splitLetters(word);
                 return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          word,
                          style: const TextStyle(
                              fontSize: 35, fontWeight: FontWeight.bold),
                          textDirection: TextDirection.ltr,
                        ),
                        const SizedBox(height: 20),
                      Wrap(
                          textDirection: TextDirection.ltr,
                          spacing: 10,
                          runSpacing: 14,
                          alignment: WrapAlignment.center,
                          children: letters.asMap().entries.map((entry) {
                            final i = entry.key;
                            final letter = entry.value;
                            final color = Colors
                                .primaries[i % Colors.primaries.length]
                                .shade200;
                            bool isTapped = false;

                            return StatefulBuilder(
                              builder: (context, setState) {
                                return InkWell(
                                  onTap: () async {
                                    setState(() => isTapped = true);
                                    await speak(letter);
                                    await Future.delayed(
                                        const Duration(milliseconds: 500));
                                    setState(() => isTapped = false);
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: isTapped
                                          ? Colors.green.shade200
                                          : color,
                                      border: Border.all(
                                          color: Colors.orange, width: 1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      letter,
                                      style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold),
                                      textDirection: TextDirection.ltr,
                                    ),
                                  ),
                                );
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 24),
Row(
                         
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              icon: const Icon(Icons.volume_up, size: 28),
                              label: const Text("Speak Word",
                                  style: TextStyle(fontSize: 20)),
                              onPressed: () => speak(word),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 14),
                              ),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.mic, size: 28),
                              label: const Text("Evaluate",
                                  style: TextStyle(fontSize: 20)),
                              onPressed: () => evaluateWord(word, index),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 14),
                              ),
                            ),
                          ],
                        ),
                         const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton.icon(
                              icon: const Icon(Icons.arrow_back, size: 24),
                              label: const Text("previous",
                                  style: TextStyle(fontSize: 18)),
                              onPressed: () {
                                if (index > 0) {
                                  pageController.animateToPage(index - 1,
                                      duration:
                                          const Duration(milliseconds: 400),
                                      curve: Curves.ease);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 12),
                              ),
                            ),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.arrow_forward, size: 24),
                              label: const Text("next",
                                  style: TextStyle(fontSize: 18)),
                              onPressed: () {
                                if (index < words.length - 1) {
                                  pageController.animateToPage(index + 1,
                                      duration:
                                          const Duration(milliseconds: 400),
                                      curve: Curves.ease);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 12),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        buildFeedback(feedbackPerWord[index]),
                      const SizedBox(height: 24),
                        Text(
                          "❓What is the first letter of the word",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                          textDirection: TextDirection.ltr,
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          textDirection: TextDirection.ltr,
                          spacing: 12,
                          children: List.generate(3, (i) {
                            final options = [letters.first, 'C', 'A'];
                            final correct = letters.first;
                            final choice = options[i];
                            return ElevatedButton(
                              onPressed: () {
                                final isCorrect = choice == correct;
                                final msg =
                                    isCorrect ? 'Correct answer!' : 'Wrong answer';
                                final color =
                                    isCorrect ? Colors.green : Colors.red;
                                showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: Text(msg,
                                        style: TextStyle(
                                            color: color, fontSize: 22)),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text("continue"),
                                      )
                                    ],
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange.shade100,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 18, vertical: 12),
                              ),
                              child: Text(
                                choice,
                                style: const TextStyle(fontSize: 24),
                                textDirection: TextDirection.ltr,
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  );
                },
              ),
              // الجملة
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "📖 Let's read the sentence together!",
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange),
                      textDirection: TextDirection.ltr,
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.brown.shade50,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.brown.shade200),
                      ),
                      child: Text(
                        widget.sentence,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown,
                        ),
                        textDirection: TextDirection.ltr,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.volume_up, size: 28),
                      label: const Text("Listen to the sentence",
                          style: TextStyle(fontSize: 20)),
                      onPressed: () => speak(widget.sentence),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      icon:
                          const Icon(Icons.record_voice_over_rounded, size: 28),
                      label: const Text("sentence record",
                          style: TextStyle(fontSize: 20)),
                      onPressed: () => evaluateWord(widget.sentence, -1),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrangeAccent,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    buildFeedback(feedbackPerWord[-1]),
                  ],
                ),
              ),
              // الصوت والحرف
            
            buildSpellingGame(),
            buildWordRecognitionGame(),
        
            ],
          ),
        ),
      ),
    );
  }
}
