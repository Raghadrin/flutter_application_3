import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:lottie/lottie.dart';
import 'package:easy_localization/easy_localization.dart';

import 'arabic_level2_screen.dart';
import 'arabic_level2_quiz_all_screen.dart';
import 'locale_keys.dart';
import 'karaoke_sentence2_screen.dart';

class ArabicLevel2HomeScreen extends StatefulWidget {
  const ArabicLevel2HomeScreen({super.key});

  @override
  State<ArabicLevel2HomeScreen> createState() => _ArabicLevel2HomeScreenState();
}

class _ArabicLevel2HomeScreenState extends State<ArabicLevel2HomeScreen> {
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

  final List<Map<String, String>> sentenceKeys = [
    {
      "title": LocaleKeys.schoolTitle,
      "text": LocaleKeys.schoolText,
      "animation": "images/school.json"
    },
    {
      "title": LocaleKeys.doctorTitle,
      "text": LocaleKeys.doctorText,
      "animation": "images/doctor.json"
    },
    {
      "title": LocaleKeys.trafficTitle,
      "text": LocaleKeys.trafficText,
      "animation": "images/traffic.json"
    },
    {
      "title": LocaleKeys.libraryTitle,
      "text": LocaleKeys.libraryText,
      "animation": "images/read.json"
    },
    {
      "title": LocaleKeys.deliciousFoodTitle,
      "text": LocaleKeys.deliciousFoodText,
      "animation": "images/cook.json"
    },
  ];

  @override
  Widget build(BuildContext context) {
    _speak(context, tr(LocaleKeys.level2WelcomeMessage));

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFFFF8E1),
        appBar: AppBar(
          backgroundColor: Colors.orange,
          elevation: 0,
          title: Text(
            tr(LocaleKeys.arabicLevel2Title),
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
            // IconButton(
            //   icon: const Icon(Icons.language, color: Colors.black),
            //   onPressed: () {
            //     final newLocale = context.locale.languageCode == 'ar'
            //         ? const Locale('en')
            //         : const Locale('ar');
            //     context.setLocale(newLocale);
            //   },
            // )
          ],
        ),
        body: TabBarView(
          children: [
            GridView.count(
              crossAxisCount: 2,
              padding: const EdgeInsets.all(16),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.75,
              children: [
                _buildTile(
                  context,
                  title: tr(LocaleKeys.quizButton2),
                  jsonPath: "images/new_images/Quiz.json",
                  onTap: () {
                    _speak(context, tr(LocaleKeys.startQuiz2));
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ArabicLevel2WordQuizScreen(),
                      ),
                    );
                  },
                ),
                ...sentenceKeys.map((s) {
                  return _buildTile(
                    context,
                    title: tr(s["title"]!),
                    jsonPath: s["animation"]!,
                    onTap: () {
                      _speak(context,
                          "${tr(LocaleKeys.selectedPrefix)} ${tr(s["title"]!)}");
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ArabicLevel2Screen(
                            sentence: tr(s["text"]!),
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
              ],
            ),

            // ✅ التبويب الثاني: كاريوكي الجمل
            const KaraokeSentenceLevel2Screen(),
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
