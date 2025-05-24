import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class ArabicLevel2Screen extends StatefulWidget {
  final String sentence;
  const ArabicLevel2Screen({super.key, required this.sentence});

  @override
  State<ArabicLevel2Screen> createState() => _ArabicLevel2ScreenState();
}

class _ArabicLevel2ScreenState extends State<ArabicLevel2Screen> {
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
    flutterTts.setLanguage("ar-SA");
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
      localeId: 'ar_SA',
      partialResults: false,
      onResult: (val) async {
        recognizedText = val.recognizedWords;

        final spoken = normalizeArabic(recognizedText.trim());
        final expected = normalizeArabic(expectedWord.trim());

        final isCorrect = spoken == expected;
        final result = isCorrect ? '100%' : '0%';
        final color = isCorrect ? Colors.green : Colors.red;

        setState(() {
          feedbackColor = color;
          feedbackPerWord[wordIndex] = result;
        });

        await Future.delayed(const Duration(milliseconds: 500));
        await speak(isCorrect ? "أحسنت!" : "حاول مرة تانية");
      },
    );
  }

  String normalizeArabic(String input) {
    return input
        .replaceAll('ة', 'ه')
        .replaceAll(RegExp(r'[ًٌٍ]'), '')
        .replaceAll('ئ', 'ي')
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا');
  }

  List<String> splitArabicWord(String word) {
    List<String> letters = [];
    for (int i = 0; i < word.length; i++) {
      if (i < word.length - 1 && _isDiacritic(word[i + 1])) {
        letters.add(word.substring(i, i + 2));
        i++;
      } else {
        letters.add(word[i]);
      }
    }
    return letters;
  }

  bool _isDiacritic(String char) {
    final diacritics = ['َ', 'ُ', 'ِ', 'ّ', 'ْ', 'ً', 'ٌ', 'ٍ'];
    return diacritics.contains(char);
  }

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
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: feedbackColor),
              textAlign: TextAlign.center,
            ),
          )
        : const SizedBox.shrink();
  }


 void evaluateSightChoice(bool isCorrect, [int index = 100]) async {
  final result = isCorrect ? '✅' : '❌';
  final color = isCorrect ? Colors.green : Colors.red;

  setState(() {
    feedbackColor = color;
    feedbackPerWord[index] = result;
  });

  await speak(isCorrect ? "أحسنت!" : "حاول مرة أخرى");
}

Widget buildSightWordExerciseList() {
  final List<Map<String, String>> exercises = [
    {"correct": "شجرة", "wrong": "شجرا"},
    {"correct": "بيت", "wrong": "ببت"},
    {"correct": "كتاب", "wrong": "كتتاب"},
    {"correct": "مدرسة", "wrong": "مدرصة"},
  ];

  final PageController pageController = PageController();

  return LayoutBuilder(
    builder: (context, constraints) {
      final screenWidth = constraints.maxWidth;
      final isSmallScreen = screenWidth < 400;

      return PageView.builder(
        controller: pageController,
        itemCount: exercises.length,
        itemBuilder: (context, index) {
          final correctWord = exercises[index]["correct"]!;
          final wrongWord = exercises[index]["wrong"]!;
          final options = [correctWord, wrongWord]..shuffle();

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.orange.shade200, width: 1.5),
                  ),
                  child: const Text(
                    "📢 اختر الكلمة الصحيحة!",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepOrange),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  icon: const Icon(Icons.volume_up, size: 24),
                  label: const Text("استمع للكلمة", style: TextStyle(fontSize: 20)),
                  onPressed: () => speak(correctWord),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
                const SizedBox(height: 24),
                ...options.map(
                  (word) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: ElevatedButton(
                      onPressed: () => evaluateSightChoice(word == correctWord, 100 + index),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade100,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        minimumSize: Size(screenWidth * 0.8, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: const BorderSide(color: Colors.orange),
                        ),
                        shadowColor: Colors.orangeAccent,
                        elevation: 4,
                      ),
                      child: Text(
                        word,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 24 : 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                buildFeedback(feedbackPerWord[100 + index]),
                const SizedBox(height: 20),
                Text(
                  "السؤال ${index + 1} من ${exercises.length}",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.grey),
                ),
                const SizedBox(height: 24),
                if (index < exercises.length - 1)
                  ElevatedButton.icon(
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text("التالي", style: TextStyle(fontSize: 20)),
                    onPressed: () {
                      pageController.nextPage(
                          duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    ),
                  )
                else
                  const Text("🎉 أحسنت! لقد أكملت التمرين", style: TextStyle(fontSize: 20, color: Colors.green)),
              ],
            ),
          );
        },
      );
    },
  );
}

Widget buildDoubleDeficitGameList() {
  final List<String> wordList = ["تفاحة", "مدرسة", "سيارة", "مطار"];
  final PageController controller = PageController();

  return PageView.builder(
    controller: controller,
    itemCount: wordList.length,
    itemBuilder: (context, index) {
      final word = wordList[index];
      List<String> shuffledLetters = splitArabicWord(word)..shuffle();
      List<String> selected = [];

      return StatefulBuilder(
        builder: (context, setLocalState) {
          void checkAnswer() {
            final isCorrect = selected.join() == word;
            final result = isCorrect ? '✅' : '❌';
            final color = isCorrect ? Colors.green : Colors.red;

            setState(() {
              feedbackColor = color;
              feedbackPerWord[300 + index] = result;
            });

            speak(isCorrect ? "أحسنت!" : "حاول مرة أخرى");
          }

          void resetLetters() {
            setLocalState(() {
              shuffledLetters = splitArabicWord(word)..shuffle();
              selected.clear();
              feedbackPerWord.remove(300 + index);
            });
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text(
                  "🎧 اسمع الكلمة ثم ركبها!",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => speak(word),
                  icon: const Icon(Icons.volume_up),
                  label: const Text("استمع للكلمة", style: TextStyle(fontSize: 20)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 10,
                  runSpacing: 12,
                  children: shuffledLetters.map((letter) {
                    return GestureDetector(
                      onTap: () {
                        setLocalState(() {
                          selected.add(letter);
                          shuffledLetters.remove(letter);
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade100,
                          border: Border.all(color: Colors.orange),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Text(
                          letter,
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                if (selected.isNotEmpty)
                  Wrap(
                    spacing: 8,
                    children: selected
                        .map((l) => Chip(
                              label: Text(l, style: const TextStyle(fontSize: 24)),
                              backgroundColor: Colors.green.shade100,
                            ))
                        .toList(),
                  ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: checkAnswer,
                  child: const Text("تحقق", style: TextStyle(fontSize: 20)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
                const SizedBox(height: 16),
                buildFeedback(feedbackPerWord[300 + index]),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text("إعادة", style: TextStyle(fontSize: 18)),
                  onPressed: resetLetters,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey.shade100,
                  ),
                ),
                const SizedBox(height: 20),
                if (index < wordList.length - 1)
                  ElevatedButton.icon(
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text("التالي", style: TextStyle(fontSize: 18)),
                    onPressed: () {
                      controller.nextPage(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  )
                else
                  const Text("🎉 انتهيت من التمارين!", style: TextStyle(fontSize: 20, color: Colors.green)),
              ],
            ),
          );
        },
      );
    },
  );
}


  @override
  Widget build(BuildContext context) {
    final words = widget.sentence.split(' ');

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 253, 249, 228),
        appBar: AppBar(
         backgroundColor: Colors.orange,
  toolbarHeight: 56, // تصغير ارتفاع الشريط العلوي
 title: const Text("🌟 تعلم من الجملة", style: TextStyle(fontSize: 26)),
 
         bottom: const TabBar(
    labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    indicatorWeight: 3,
      tabs: [
              Tab(text: 'الحروف'),
              Tab(text: 'الجملة'),
              Tab(text: 'التركيب'),
              Tab(text: 'تمييز '),
            ],
          


),
        ),
        body: TabBarView(
          children: [
            // تبويب الحروف
            PageView.builder(
                itemCount: words.length,
                controller: pageController,
                itemBuilder: (context, index) {
                  final word = words[index];
                  final letters = splitArabicWord(word);

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          word,
                          style: const TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
                          textDirection: TextDirection.rtl,
                        ),
                        const SizedBox(height: 20),
                        Wrap(
                          textDirection: TextDirection.rtl,
                          spacing: 10,
                          runSpacing: 14,
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
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: isTapped ? Colors.green.shade200 : color,
                                      border: Border.all(color: Colors.orange, width: 1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      letter,
                                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                      textDirection: TextDirection.rtl,
                                    ),
                                  ),
                                );
                              },
                            );
                          }).toList(),
                        ),
                      const SizedBox(height: 28),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              icon: const Icon(Icons.volume_up, size: 28),
                              label: const Text("نطق الكلمة", style: TextStyle(fontSize: 20)),
                              onPressed: () => speak(word),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                              ),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.mic, size: 28),
                              label: const Text("تقييم", style: TextStyle(fontSize: 20)),
                              onPressed: () => evaluateWord(word, index),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
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
                              label: const Text("السابق", style: TextStyle(fontSize: 18)),
                              onPressed: () {
                                if (index > 0) {
                                  pageController.animateToPage(index - 1,
                                      duration: const Duration(milliseconds: 400), curve: Curves.ease);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              ),
                            ),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.arrow_forward, size: 24),
                              label: const Text("التالي", style: TextStyle(fontSize: 18)),
                              onPressed: () {
                                if (index < words.length - 1) {
                                  pageController.animateToPage(index + 1,
                                      duration: const Duration(milliseconds: 400), curve: Curves.ease);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        buildFeedback(feedbackPerWord[index]),
                        const SizedBox(height: 24),
                        Text(
                          "❓ ما هو أول حرف في الكلمة؟",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          textDirection: TextDirection.rtl,
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          textDirection: TextDirection.rtl,
                          spacing: 12,
                          children: List.generate(3, (i) {
                            final options = [letters.first, 'أ', 'خ'];
                            final correct = letters.first;
                            final choice = options[i];
                            return ElevatedButton(
                              onPressed: () {
                                final isCorrect = choice == correct;
                                final msg = isCorrect ? 'إجابة صحيحة!' : 'إجابة خاطئة';
                                final color = isCorrect ? Colors.green : Colors.red;
                                showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: Text(msg, style: TextStyle(color: color, fontSize: 22)),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text("متابعة"),
                                      )
                                    ],
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange.shade100,
                                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                              ),
                              child: Text(
                                choice,
                                style: const TextStyle(fontSize: 24),
                                textDirection: TextDirection.rtl,
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  );
                },
              ),
            // تبويب الجملة
           SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "📖 لنقرأ الجملة معًا!",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.orange),
                      textDirection: TextDirection.rtl,
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                        textDirection: TextDirection.rtl,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.volume_up, size: 28),
                      label: const Text("استمع للجملة", style: TextStyle(fontSize: 20)),
                      onPressed: () => speak(widget.sentence),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.record_voice_over_rounded, size: 28),
                      label: const Text("سجل الجملة", style: TextStyle(fontSize: 20)),
                      onPressed: () => evaluateWord(widget.sentence, -1),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrangeAccent,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    buildFeedback(feedbackPerWord[-1]),
                  ],
                ),
              ),

            // تبويب السمع والتركيب (قيد التطوير)
            buildDoubleDeficitGameList(),

            // ✅ تبويب تمييز الكلمة (Surface Dyslexia)
           // تبويب تمييز الكلمة
buildSightWordExerciseList(),

          ],
        ),
      ),
    );
  }
}
