import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:lottie/lottie.dart';

import 'arabic_level1_screen.dart';
import 'arabic_level1_quiz_all.dart';
import 'karaoke_sentence_screen.dart';

class ArabicLevel1HomeScreen extends StatefulWidget {
  const ArabicLevel1HomeScreen({super.key});

  @override
  State<ArabicLevel1HomeScreen> createState() => _ArabicLevel1HomeScreenState();
}

class _ArabicLevel1HomeScreenState extends State<ArabicLevel1HomeScreen> {
  final FlutterTts tts = FlutterTts();

  Future<void> configureTts() async {
    await tts.setLanguage("ar-SA");
    await tts.setVoice({'name': 'ar-xa-x-arm-local', 'locale': 'ar-SA'});
    await tts.setSpeechRate(0.45);
    await tts.setPitch(1.0);
  }

  Future<void> _speak(String text) async {
    await configureTts();
    await tts.speak(text);
  }

  final List<Map<String, String>> sentenceKeys = [
    {
      "title": "الشمس تشرق",
      "text": "الشمس تشرق كل صباح وتنير السماء بالضوء الذهبي",
      "animation": "images/sun.json"
    },
    {
      "title": "أكتب في الدفتر",
      "text": "أنا أكتب الواجب في دفتري",
      "animation": "images/write.json"
    },
    {
      "title": "أطهو الطعام",
      "text": "أمي تطهو الطعام اللذيذ",
      "animation": "images/cook.json"
    },
    {
      "title": "السيارة تتحرك",
      "text": "السيارة تسير بسرعة في الشارع",
      "animation": "images/car.json"
    },
    {
      "title": "أقرأ كتابي",
      "text": "أنا أقرأ كتابي المفضل في المساء",
      "animation": "images/read.json"
    },
  ];

  @override
  Widget build(BuildContext context) {
    _speak("مرحباً بك في تمارين المستوى الأول");

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFFFF8E1),
        appBar: AppBar(
          backgroundColor: Colors.orange,
          elevation: 0,
          title: const Text(
            "المستوى الأول - عربي",
            style: TextStyle(
              color: Colors.black,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          bottom: const TabBar(
            labelColor: Colors.black,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'التمارين'),
              Tab(text: 'كاريوكي'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // ✅ التبويب الأول: التمارين
            GridView.count(
              crossAxisCount: 2,
              padding: const EdgeInsets.all(16),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.75,
              children: [
                _buildTile(
                  context,
                  title: "اختبار",
                  jsonPath: "images/new_images/Quiz.json",
                  onTap: () {
                    _speak("هيا نبدأ الاختبار");
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ArabicLetterQuizScreen(),
                      ),
                    );
                  },
                ),
                ...sentenceKeys.map((s) {
                  return _buildTile(
                    context,
                    title: s["title"]!,
                    jsonPath: s["animation"]!,
                    onTap: () {
                      _speak("اخترت: ${s["title"]!}");
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ArabicLevel1Screen(sentence: s["text"]!),
                        ),
                      );
                    },
                  );
                }).toList(),
              ],
            ),

            // ✅ التبويب الثاني: الكاريوكي
            const KaraokeSentenceScreen(),
          ],
        ),
      ),
    );
  }

  Widget _buildTile(
    BuildContext context, {
    required String title,
    required String jsonPath,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.orange, width: 3),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(jsonPath, height: 100),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.deepOrange,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
