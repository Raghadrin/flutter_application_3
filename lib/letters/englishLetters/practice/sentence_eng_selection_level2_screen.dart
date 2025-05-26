import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:lottie/lottie.dart';
import 'package:easy_localization/easy_localization.dart';
import 'locale_keys.dart';

import 'english_level2_quiz_all_screen.dart';
import 'english_level2_screen.dart';

class EnglishLevel2HomeScreen extends StatelessWidget {
  final FlutterTts tts = FlutterTts();

  EnglishLevel2HomeScreen({super.key});

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
      "title": LocaleKeys.parkTitle,
      "text": LocaleKeys.parkText,
      "animation": "images/park.json",
    },
    {
      "title": LocaleKeys.birthdayTitle,
      "text": LocaleKeys.birthdayText,
      "animation": "images/cake.json",
    },
    {
  "title": LocaleKeys.morningWithDogTitle,
  "text": LocaleKeys.morningWithDogText,
  "animation": "images/Dog.json",
},
{
  "title": LocaleKeys.washingCarTitle,
  "text": LocaleKeys.washingCarText,
  "animation": "images/car.json",
},
{
  "title": LocaleKeys.readingLibraryTitle,
  "text": LocaleKeys.readingLibraryText,
  "animation": "images/read.json",
},

  ];

  @override
  Widget build(BuildContext context) {
    _speak(context, tr(LocaleKeys.tts_level2_welcome));

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      appBar: AppBar(
        backgroundColor: Colors.orange,
        elevation: 0,
        title: Text(
          tr(LocaleKeys.english_level2_title),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
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
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.75,
        children: [
          _buildTile(
            context,
            title: tr(LocaleKeys.level2_quiz_title),
            jsonPath: "images/new_images/Quiz.json",
            onTap: () {
              _speak(context, tr(LocaleKeys.tts_start_quiz));
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const EnglishLevel2WordQuizScreen(),
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
                    builder: (_) => EnglishLevel2Screen(
                      sentence: tr(s["text"]!),
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
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.deepOrange,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
