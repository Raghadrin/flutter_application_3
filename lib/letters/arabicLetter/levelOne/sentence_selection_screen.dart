import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:lottie/lottie.dart';
import 'package:easy_localization/easy_localization.dart';

import 'arabic_level1_screen.dart';
import 'arabic_level1_quiz_all.dart';
import 'karaoke_sentence_screen.dart';
import 'locale_keys.dart';

class ArabicLevel1HomeScreen extends StatefulWidget {
  const ArabicLevel1HomeScreen({super.key});

  @override
  State<ArabicLevel1HomeScreen> createState() =>
      _ArabicLevel1HomeScreenState();
}

class _ArabicLevel1HomeScreenState extends State<ArabicLevel1HomeScreen> {
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
      "title": LocaleKeys.sunriseTitle,
      "text": LocaleKeys.sunriseText,
      "animation": "images/sun.json"
    },
    {
      "title": LocaleKeys.writeTitle,
      "text": LocaleKeys.writeText,
      "animation": "images/write.json"
    },
    {
      "title": LocaleKeys.cookTitle,
      "text": LocaleKeys.cookText,
      "animation": "images/cook.json"
    },
    {
      "title": LocaleKeys.carTitle,
      "text": LocaleKeys.carText,
      "animation": "images/car.json"
    },
    {
      "title": LocaleKeys.readTitle,
      "text": LocaleKeys.readText,
      "animation": "images/read.json"
    },
  ];

  @override
  Widget build(BuildContext context) {
    _speak(context, tr(LocaleKeys.welcomeMessage));

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFFFF8E1),
        appBar: AppBar(
          backgroundColor: Colors.orange,
          elevation: 0,
          title: Text(
            tr(LocaleKeys.arabicLevel1Title),
            style: const TextStyle(
              color: Colors.black,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.language, color: Colors.black),
              tooltip: 'Change Language',
              onPressed: () {
                final newLocale = context.locale.languageCode == 'ar'
                    ? const Locale('en')
                    : const Locale('ar');
                context.setLocale(newLocale);
              },
            )
          ],
          bottom: const TabBar(
            labelStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            indicatorWeight: 3,
            tabs: [
              Tab(text: 'التمارين'),
              Tab(text: 'كاريوكي'),
            ],
          ),
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
                  title: tr(LocaleKeys.quizButton),
                  jsonPath: "images/new_images/Quiz.json",
                  onTap: () {
                    _speak(context, tr(LocaleKeys.startQuiz));
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
                    title: tr(s["title"]!),
                    jsonPath: s["animation"]!,
                    onTap: () {
                      _speak(
                        context,
                        "${tr(LocaleKeys.selectedPrefix)} ${tr(s["title"]!)}",
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ArabicLevel1Screen(
                            sentence: tr(s["text"]!),
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
              ],
            ),
            const KaraokeSentenceArabicScreen(),
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
