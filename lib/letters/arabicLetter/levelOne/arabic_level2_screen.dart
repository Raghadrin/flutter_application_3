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
        final result = isCorrect ? '😃' : '😕';
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

  Widget buildFeedback(String? feedback) {
    return feedback != null && feedback.isNotEmpty
        ? AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.only(top: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: feedbackColor.withOpacity(0.1),
              border: Border.all(color: feedbackColor, width: 2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              feedback,
              style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: feedbackColor),
              textAlign: TextAlign.center,
            ),
          )
        : const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    final words = widget.sentence.split(' ');

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 253, 249, 228),
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 218, 149, 21),
          title: const Text("🌟 تعلم من الجملة", style: TextStyle(fontSize: 26)),
          bottom: const TabBar(
            indicatorWeight: 4,
            labelStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            tabs: [
              Tab(text: 'الحروف'),
              Tab(text: 'الجملة'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            PageView.builder(
              itemCount: words.length,
              controller: pageController,
              itemBuilder: (context, index) {
                final word = words[index];
                final letters = word.split('').reversed.toList();

                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text("✍️ الكلمة ${index + 1} من ${words.length}",
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.orange)),
                      const SizedBox(height: 16),
                      Text(word, style: const TextStyle(fontSize: 46, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 24),
                      Wrap(
                        spacing: 16,
                        runSpacing: 20,
                        alignment: WrapAlignment.center,
                        children: letters.asMap().entries.map((entry) {
                          final i = entry.key;
                          final letter = entry.value;
                          final color = Colors.primaries[i % Colors.primaries.length].shade200;

                          return InkWell(
                            onTap: () => speak(letter),
                            child: Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: color,
                                border: Border.all(color: Colors.orange, width: 2),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Text(letter,
                                  style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 28),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            icon: const Icon(Icons.volume_up, size: 32),
                            label: const Text("نطق الكلمة", style: TextStyle(fontSize: 24)),
                            onPressed: () => speak(word),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 18),
                            ),
                          ),
                          const SizedBox(width: 20),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.mic, size: 32),
                            label: const Text("تقييم", style: TextStyle(fontSize: 24)),
                            onPressed: () => evaluateWord(word, index),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 18),
                            ),
                          ),
                        ],
                      ),
                      buildFeedback(feedbackPerWord[index]),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            icon: const Icon(Icons.arrow_back, size: 28),
                            label: const Text("السابق", style: TextStyle(fontSize: 22)),
                            onPressed: () {
                              if (index > 0) {
                                pageController.animateToPage(index - 1,
                                    duration: const Duration(milliseconds: 400), curve: Curves.ease);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                            ),
                          ),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.arrow_forward, size: 28),
                            label: const Text("التالي", style: TextStyle(fontSize: 22)),
                            onPressed: () {
                              if (index < words.length - 1) {
                                pageController.animateToPage(index + 1,
                                    duration: const Duration(milliseconds: 400), curve: Curves.ease);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),

            /// ✅ تبويب الجملة
            Center(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.orange.shade200, width: 2),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
                ),
                padding: const EdgeInsets.all(24),
                margin: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "📖 لنقرأ الجملة معًا!",
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.orange),
                    ),
                    const SizedBox(height: 24),
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
                          fontSize: 46,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.volume_up, size: 30),
                      label: const Text("استمع للجملة", style: TextStyle(fontSize: 24)),
                      onPressed: () => speak(widget.sentence),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.record_voice_over_rounded, size: 30),
                      label: const Text("سجل الجملة", style: TextStyle(fontSize: 24)),
                      onPressed: () => evaluateWord(widget.sentence, -1),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrangeAccent,
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      ),
                    ),
                    const SizedBox(height: 24),
                    buildFeedback(feedbackPerWord[-1]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
