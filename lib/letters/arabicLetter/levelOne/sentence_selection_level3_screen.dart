import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:lottie/lottie.dart';
import 'package:easy_localization/easy_localization.dart';

import 'arabic_level3_screen.dart';
import 'arabic_level3_quiz_all.dart';
import 'karaoke_sentence3_screen.dart';
import 'locale_keys.dart';

class ArabicLevel3HomeScreen extends StatefulWidget {
  const ArabicLevel3HomeScreen({super.key});

  @override
  State<ArabicLevel3HomeScreen> createState() => _ArabicLevel3HomeScreenState();
}

class _ArabicLevel3HomeScreenState extends State<ArabicLevel3HomeScreen> {
  final FlutterTts tts = FlutterTts();

  Future<void> configureTts(BuildContext context) async {
    final langCode = context.locale.languageCode;

    if (langCode == 'ar') {
      await tts.setLanguage("ar-SA");
      await tts.setVoice({'name': 'ar-xa-x-arm-local', 'locale': 'ar-SA'});
    } else {
      await tts.setLanguage("en-US");
      await tts.setVoice({'name': 'en-gb-x-rjs-local', 'locale': 'en-US'});
    }

    await tts.setSpeechRate(0.45);
    await tts.setPitch(1.0);
  }

  Future<void> _speak(BuildContext context, String text) async {
    await configureTts(context);
    await tts.speak(text);
  }

  final List<Map<String, dynamic>> stories = [
    {
      'emoji': '🌳',
      'title': LocaleKeys.story1Title,
      'paragraph':
          'في صباحٍ مشمس، ذهب سامي مع والده إلى الحديقة...',
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
      'title': LocaleKeys.story2Title,
      'paragraph': 'في فصل الشتاء، تهطل الأمطار...',
      'questions': ["في أي فصل؟", "ماذا يحدث للأرض؟", "بماذا يلعبون؟", "ماذا يرتدون؟"],
      'answers': ["فصل الشتاء", "تصبح مبللة", "القوارب", "المعاطف والأحذية"],
      'animation': 'images/rain.json',
    },
    {
      'emoji': '📖',
      'title': LocaleKeys.story3Title,
      'paragraph': 'تحب سارة قراءة القصص قبل النوم...',
      'questions': ["من تحب القراءة؟", "متى؟", "من معها؟", "بماذا تحلم؟"],
      'answers': ["سارة", "قبل النوم", "والدتها", "أماكن جميلة"],
      'animation': 'images/read.json',
    },
    {
      'emoji': '🏫',
      'title': LocaleKeys.story4Title,
      'paragraph': 'في المدرسة، يتعلم التلاميذ القراءة والكتابة...',
      'questions': ["أين؟", "ماذا يتعلمون؟", "من يحبون؟", "لماذا؟"],
      'answers': ["في المدرسة", "القراءة والكتابة", "المعلم", "يشجعهم"],
      'animation': 'images/school.json',
    },
    {
      'emoji': '🏖️',
      'title': LocaleKeys.story5Title,
      'paragraph': 'ذهبت العائلة إلى البحر في العطلة...',
      'questions': ["أين ذهبوا؟", "ماذا بنوا؟", "أين سبحوا؟", "ماذا أكلوا؟"],
      'answers': ["إلى البحر", "قلاع", "في الماء", "طعامًا لذيذًا"],
      'animation': 'images/sun.json',
    },
  ];

  @override
  Widget build(BuildContext context) {
    _speak(context, tr(LocaleKeys.level3WelcomeMessage));

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFFFF8E1),
        appBar: AppBar(
          backgroundColor: Colors.orange,
          elevation: 0,
          title: Text(
            tr(LocaleKeys.arabicLevel3Title),
            style: const TextStyle(
              color: Colors.black,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          bottom: const TabBar(
            labelStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            indicatorWeight: 3,
            tabs: [
              Tab(text: 'التمارين'),
              Tab(text: 'كاريوكي'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.language, color: Colors.black),
              onPressed: () {
                final newLocale = context.locale.languageCode == 'ar'
                    ? const Locale('en')
                    : const Locale('ar');
                context.setLocale(newLocale);
              },
            )
          ],
        ),
        body: TabBarView(
          children: [
            // 🧠 التمارين
            GridView.count(
              crossAxisCount: 2,
              padding: const EdgeInsets.all(16),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.75,
              children: [
                _buildTile(
                  context,
                  title: tr(LocaleKeys.quizButton3),
                  jsonPath: "images/new_images/Quiz.json",
                  onTap: () {
                    _speak(context, tr(LocaleKeys.startQuiz3));
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ArabicLevel3QuizAllScreen(),
                      ),
                    );
                  },
                ),
                ...stories.map((story) {
                  return _buildTile(
                    context,
                    title: tr(story['title']),
                    jsonPath: story['animation'],
                    onTap: () {
                      _speak(context, "${tr(LocaleKeys.selectedPrefix)} ${tr(story['title'])}");
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ArabicLevel3Screen(
                            title: tr(story['title']),
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

            // 🎤 كاريوكي المستوى 3
            const KaraokeSentenceLevel3Screen(),
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
