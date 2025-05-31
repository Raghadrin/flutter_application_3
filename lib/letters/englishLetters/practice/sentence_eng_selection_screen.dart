import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:lottie/lottie.dart';
import 'package:easy_localization/easy_localization.dart';
import 'locale_keys.dart';

import 'english_level1_quiz_all.dart';
import 'english_level1_screen.dart';
import 'karaoke_sentence_english_screen.dart';

class EnglishLevel1HomeScreen extends StatelessWidget {
  final FlutterTts tts = FlutterTts();

  EnglishLevel1HomeScreen({super.key});

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

  final List<Map<String, String>> sentences = [
    {
      "title": LocaleKeys.appleTitle,
      "text": LocaleKeys.appleText,
      "animation": "images/new_images/apples.json",
    },
    {
      "title": LocaleKeys.schoolTitle,
      "text": LocaleKeys.schoolText,
      "animation": "images/write.json",
    },
    {
      "title": LocaleKeys.dogTitle,
      "text": LocaleKeys.dogText,
      "animation": "images/Dog.json",
    },
    {
      "title": LocaleKeys.carTitle,
      "text": LocaleKeys.carText,
      "animation": "images/car.json",
    },
    {
      "title": LocaleKeys.libraryTitle,
      "text": LocaleKeys.libraryText,
      "animation": "images/read.json",
    },
  ];

  @override
  Widget build(BuildContext context) {
    _speak(context, tr(LocaleKeys.tts_welcome));

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFFFF8E1),
        appBar: AppBar(
          backgroundColor: Colors.orange,
          elevation: 0,
          centerTitle: true,
          title: Text(
            tr(LocaleKeys.english_level1_title),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          bottom: const TabBar(
            indicatorColor: Colors.deepPurple,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.black,
            tabs: [
              Tab(text: 'Karaoke'),
              Tab(text: 'Exercises'),
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
            // Karaoke Tab
            KaraokeSentenceEnglishScreen(),

            // Exercises Tab
            GridView.count(
              crossAxisCount: 2,
              padding: const EdgeInsets.all(16),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.75,
              children: [
                _buildTile(
                  context,
                  title: tr(LocaleKeys.level1_quiz_title),
                  jsonPath: "images/new_images/Quiz.json",
                  onTap: () {
                    _speak(context, tr(LocaleKeys.tts_start_quiz));
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EnglishLetterQuizScreen(),
                      ),
                    );
                  },
                ),
                ...sentences.map((s) {
                  return _buildTile(
                    context,
                    title: tr(s["title"]!),
                    jsonPath: s["animation"]!,
                    onTap: () {
                      _speak(context, "${tr(LocaleKeys.selectedPrefix)} ${tr(s["title"]!)}");
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EnglishLevel1Screen(
                            sentence: tr(s["text"]!),
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
              ],
            ),
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
