import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class EnglishLevel1Screen extends StatefulWidget {
  final String sentence;
  const EnglishLevel1Screen({super.key, required this.sentence});

  @override
  State<EnglishLevel1Screen> createState() => _EnglishLevel1ScreenState();
}

class _EnglishLevel1ScreenState extends State<EnglishLevel1Screen> {
  late FlutterTts flutterTts;
  late stt.SpeechToText speech;
  late PageController pageController;
  String recognizedText = '';
  Map<int, String> feedbackPerWord = {};
  Color feedbackColor = Colors.transparent;

  
  final List<PhonologicalExercise> exercises = [
    PhonologicalExercise(
      title: "Identify the correct sound",
      target: 'B',
      options: ['D', 'B', 'P'],
      instructions: "Listen to the sound and choose the correct letter",
    ),
    PhonologicalExercise(
      title: "Similar sounds",
      target: 'T',
      options: ['T', 'D', 'K'],
      instructions: "Pay attention to the small differences",
    ),
    PhonologicalExercise(
      title: "Short vowel sound",
      target: 'A',
      options: ['A', 'E', 'O'],
      instructions: "Listen carefully and choose the correct vowel",
    ),
  ];

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

  List<String> splitEnglishWord(String word) => word.split('');

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

  Widget buildPhonologicalExercise() {
    int currentExerciseIndex = 0;
    PhonologicalExercise currentExercise = exercises[currentExerciseIndex];

    return StatefulBuilder(
      builder: (context, setState) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Text(
                  currentExercise.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                currentExercise.instructions,
                style: const TextStyle(fontSize: 20, color: Colors.brown),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => speak(currentExercise.target),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.volume_up, size: 30),
                    SizedBox(width: 10),
                    Text(
                      "Play Sound",
                      style: TextStyle(fontSize: 22),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                mainAxisSpacing: 15,
                crossAxisSpacing: 15,
                childAspectRatio: 1.2,
                children: currentExercise.options.map((letter) {
                  return ElevatedButton(
                    onPressed: () {
                      final isCorrect = letter == currentExercise.target;
                      setState(() {
                        feedbackColor = isCorrect ? Colors.green : Colors.red;
                      });
                      speak(isCorrect
                          ? "Correct! It's $letter" : "Try again");
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: Text(
                            isCorrect ?  "Great job! 🎉" : "Try again",
                            style: TextStyle(
                              color: isCorrect ? Colors.green : Colors.red,
                              fontSize: 24,
                            ),
                          ),
                          content: Text(
                            isCorrect
                                ? "You identified the correct sound." : "The correct sound was: ${currentExercise.target}",
                            style: const TextStyle(fontSize: 18),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("okay"),
                            ),
                          ],
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade100,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                    ),
                    child: Text(
                      letter,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: currentExerciseIndex > 0
                        ? () {
                            setState(() => currentExerciseIndex--);
                            currentExercise = exercises[currentExerciseIndex];
                          }
                        : null,
                    color: Colors.orange,
                    iconSize: 30,
                  ),
                  Text(
                    '${currentExerciseIndex + 1}/${exercises.length}',
                    style: const TextStyle(fontSize: 18),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward),
                    onPressed: currentExerciseIndex < exercises.length - 1
                        ? () {
                            setState(() => currentExerciseIndex++);
                            currentExercise = exercises[currentExerciseIndex];
                          }
                        : null,
                    color: Colors.orange,
                    iconSize: 30,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              CircularProgressIndicator(
                value: (currentExerciseIndex + 1) / exercises.length,
                backgroundColor: Colors.orange.shade100,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                strokeWidth: 8,
              ),
              const SizedBox(height: 12),
              Text("Exersice ${currentExerciseIndex + 1} from ${exercises.length}",
                  style: const TextStyle(fontSize: 16)),
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
        length: 3,
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
                Tab(text: 'Sound Exercise'),
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
                         final letters = splitEnglishWord(word);
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
              buildPhonologicalExercise(),
            ],
          ),
        ),
      ),
    );
  }
}

class PhonologicalExercise {
  final String title;
  final String target;
  final List<String> options;
  final String instructions;

  PhonologicalExercise({
    required this.title,
    required this.target,
    required this.options,
    required this.instructions,
  });
}
