import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:lottie/lottie.dart';

import 'arabic_level2_screen.dart';
import 'arabic_level2_quiz_all_screen.dart';

class ArabicLevel2HomeScreen extends StatelessWidget {
  final FlutterTts tts = FlutterTts();

  ArabicLevel2HomeScreen({super.key});

  void _speak(String text) async {
    await tts.setLanguage("ar-SA");
    await tts.setSpeechRate(0.4);
    await tts.speak(text);
  }

  final List<Map<String, String>> sentences = [
    {
      "emoji": "🏫",
      "title": "نشاط مدرسي",
      "text": "الولد المجتهد يذهب إلى المدرسة كل صباح بنشاط",
      "animation": "images/school.json",
    },
    {
      "emoji": "🩺",
      "title": "علاج المرضى",
      "text": "الطبيبة تعالج المرضى في المستشفى باستخدام أدوات دقيقة",
      "animation": "images/doctor.json",
    },
    {
      "emoji": "🚦",
      "title": "احترام القانون",
      "text": "السيارة الحمراء توقفت عند الإشارة الحمراء احترامًا للقانون",
      "animation": "images/traffic.json",
    },
    {
      "emoji": "📚",
      "title": "القراءة اليومية",
      "text": "أنا أقرأ كتابًا مفيدًا في المكتبة كل يوم بعد المدرسة",
      "animation": "images/read.json",
    },
    {
      "emoji": "👩‍🍳",
      "title": "الطبخ الصحي",
      "text": "الأم تحضر طعامًا لذيذًا بمكونات صحية للحفاظ على العائلة",
      "animation": "images/cook.json",
    },
  ];

  @override
  Widget build(BuildContext context) {
    _speak("مرحباً في المستوى الثاني. اختر جملة لتبدأ التعلم.");

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      appBar: AppBar(
        backgroundColor: Colors.orange,
        elevation: 0,
        title: const Text(
          "اللغة العربية - المستوى 2",
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.75,
        children: [
          // زر الكويز الشامل
          _buildTile(
            context,
            title: "اختبار المرحلة الثانية",
            jsonPath: "images/new_images/Quiz.json",
            onTap: () {
              _speak("لنبدأ الاختبار.");
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ArabicLevel2WordQuizScreen(),
                ),
              );
            },
          ),
          ...sentences.map((sentence) {
            return _buildTile(
              context,
              title: sentence["title"]!,
              jsonPath: sentence["animation"]!,
              onTap: () {
                _speak("اخترت: ${sentence["title"]}");
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ArabicLevel2Screen(
                      sentence: sentence["text"]!,
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ],
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
