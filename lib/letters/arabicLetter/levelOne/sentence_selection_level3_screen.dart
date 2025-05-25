import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:lottie/lottie.dart';

import 'arabic_level3_screen.dart';
import 'arabic_level3_quiz_all.dart';

class ArabicLevel3HomeScreen extends StatelessWidget {
  final FlutterTts tts = FlutterTts();

  ArabicLevel3HomeScreen({super.key});

  void _speak(String text) async {
    await tts.setLanguage("ar-SA");
    await tts.setSpeechRate(0.4);
    await tts.speak(text);
  }

  final List<Map<String, dynamic>> stories = [
    {
      'emoji': '🌳',
      'title': 'يوم في الحديقة',
      'paragraph':
          'في صباحٍ مشمس، ذهب سامي مع والده إلى الحديقة. كانت الأشجار خضراء، والعصافير تغني. لعب سامي كثيرًا بالأرجوحة والزحليقة، ثم جلس مع والده ليتناولا العصير ويشاهدوا الطيور وهي تطير في السماء',
      'questions': [
        "ما عنوان القصة؟",
        "من ذهب إلى الحديقة؟",
        "ماذا فعل سامي؟",
        "ماذا شاهدوا؟"
      ],
      'answers': ["يوم في الحديقة", "سامي مع والده", "لعب كثيرًا", "الطيور"],
      'animation': 'images/t.json',
    },
    {
      'emoji': '🌧️',
      'title': 'ألعاب المطر',
      'paragraph':
          'في فصل الشتاء، تهطل الأمطار وتصبح الأرض مبللة. يخرج الأطفال بفرح ليلعبوا في البرك الصغيرة، ويصنعوا قوارب ورقية يتركونها تبحر في الماء. يرتدون المعاطف والأحذية الطويلة ليبقوا جافين أثناء اللعب',
      'questions': [
        "في أي فصل؟",
        "ماذا يحدث للأرض؟",
        "بماذا يلعبون؟",
        "ماذا يرتدون؟"
      ],
      'answers': ["فصل الشتاء", "تصبح مبللة", "القوارب", "المعاطف والأحذية"],
      'animation': 'images/rain.json',
    },
    {
      'emoji': '📖',
      'title': 'قصة قبل النوم',
      'paragraph':
          'تحب سارة قراءة القصص قبل النوم. تجلس بجانب والدتها وتفتح كتابها المفضل. كل ليلة، تسافر بخيالها إلى أماكن جميلة من خلال القصص، وتحلم بأنها بطلة في عالم من المغامرات',
      'questions': ["من تحب القراءة؟", "متى؟", "من معها؟", "بماذا تحلم؟"],
      'answers': ["سارة", "قبل النوم", "والدتها", "أماكن جميلة"],
      'animation': 'images/read.json',
    },
    {
      'emoji': '🏫',
      'title': 'في المدرسة',
      'paragraph':
          'في المدرسة، يتعلم التلاميذ القراءة والكتابة والحساب. يحب الأطفال معلميهم لأنهم يشجعونهم دائمًا على التعلم والاجتهاد. في الفصل، يتشاركون في الأنشطة ويعملون معًا كفريق',
      'questions': ["أين؟", "ماذا يتعلمون؟", "من يحبون؟", "لماذا؟"],
      'answers': ["في المدرسة", "القراءة والكتابة", "المعلم", "يشجعهم"],
      'animation': 'images/school.json',
    },
    {
      'emoji': '🏖️',
      'title': 'عطلة على الشاطئ',
      'paragraph':
          'ذهبت العائلة إلى البحر في العطلة. لعب الأطفال بالرمل وبنوا قلاعًا كبيرة. سبحوا في الماء وركضوا على الشاطئ. بعد اللعب، جلسوا معًا وتناولوا طعامًا لذيذًا وهم يشاهدون الأمواج',
      'questions': ["أين ذهبوا؟", "ماذا بنوا؟", "أين سبحوا؟", "ماذا أكلوا؟"],
      'answers': ["إلى البحر", "قلاع", "في الماء", "طعامًا لذيذًا"],
      'animation': 'images/sun.json',
    },
  ];

  @override
  Widget build(BuildContext context) {
    _speak("مرحباً في المستوى الثالث. اختر قصة لتبدأ.");

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      appBar: AppBar(
        backgroundColor: Colors.orange,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "📖 اللغة العربية - المستوى 3",
          style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 0, 0, 0)),
        ),
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
        children: [
          // زر الكويز الشامل
          _buildTile(
            context,
            title: "اختبار المرحلة الثالثة",
            jsonPath: "images/new_images/Quiz.json",
            onTap: () {
              _speak("لنبدأ الكويز الشامل.");
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ArabicLevel3QuizAllScreen(),
                ),
              );
            },
          ),
          // بقية القصص
          ...stories.map((story) {
            return _buildTile(
              context,
              title: story['title'],
              jsonPath: story['animation'],
              onTap: () {
                _speak("اخترت: ${story["title"]}");
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ArabicLevel3Screen(
                      title: story['title'],
                      storyText: story['paragraph'],
                      questions: List<String>.from(story['questions']),
                      correctAnswers: List<String>.from(story['answers']),
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
