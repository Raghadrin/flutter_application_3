import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:lottie/lottie.dart';
import 'package:easy_localization/easy_localization.dart';
import 'locale_keys.dart';

import 'english_level3_screen.dart';
import 'english_level3_quiz_all_screen.dart';
import 'karaoke_sentence_english_level3.dart';

class EnglishLevel3HomeScreen extends StatelessWidget {
  final FlutterTts tts = FlutterTts();

  EnglishLevel3HomeScreen({super.key});

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
      'title': LocaleKeys.story1Title,
      'paragraph': "Leen loved stars. One day, her school announced a science fair. She built a rocket model and talked about a mission to Saturn's moon, Titan. Everyone was impressed.",
      'questions': [
        "Who is the story about?",
        "What did the school announce?",
        "What planet's moon did she choose?",
        "How did people react?"
      ],
      'answers': ["Leen", "A science fair", "Titan", "They were impressed"],
      'answerChoices': [
        ["Leen", "Noor", "Adam", "Hana"],
        ["A picnic", "A science fair", "A sports day", "A painting contest"],
        ["Earth", "Jupiter", "Titan", "Venus"],
        ["They were bored", "They were impressed", "They were confused", "They laughed"]
      ],
      'animation': 'images/space.json',
    },
    {
      'title': LocaleKeys.story2Title,
      'paragraph': "Noor built a color-sorting robot. On the fair day, it didn’t work! She found a loose wire and fixed it. Her robot worked and she was proud.",
      'questions': [
        "What did Noor build?",
        "What went wrong?",
        "How did she fix it?",
        "How did she feel?"
      ],
      'answers': ["A color-sorting robot", "It didn’t work", "She fixed the wire", "She was proud"],
      'answerChoices': [
        ["A painting", "A volcano", "A color-sorting robot", "A telescope"],
        ["It was too slow", "It didn’t work", "It exploded", "It was too big"],
        ["She rebuilt it", "She fixed the wire", "She changed the code", "She painted it"],
        ["She was sad", "She was proud", "She was tired", "She was nervous"]
      ],
      'animation': 'images/robot.json',
    },
    {
      'title': LocaleKeys.story3Title,
      'paragraph': "Adam rushed his painting. It looked messy. He tried again slowly, using leaves and sand. The result was beautiful. He learned to be patient.",
      'questions': [
        "What was Adam doing?",
        "Why was the first painting messy?",
        "What materials did he use?",
        "What did he learn?"
      ],
      'answers': ["Painting", "He rushed", "Leaves and sand", "To be patient"],
      'answerChoices': [
        ["Writing", "Drawing", "Painting", "Running"],
        ["He used too much paint", "He rushed", "He was sleepy", "He was confused"],
        ["Paper and pencils", "Stones", "Leaves and sand", "Watercolors only"],
        ["To be fast", "To copy others", "To be patient", "To win"]
      ],
      'animation': 'images/art.json',
    },
    {
      'title': LocaleKeys.story4Title,
      'paragraph': "Hana lived near a volcano. She wrote a story about it using facts and legends. People loved it, and she became a storyteller in her village.",
      'questions': [
        "Where did Hana live?",
        "What did she write about?",
        "What did people think?",
        "What did she become?"
      ],
      'answers': ["Near a volcano", "A volcano story", "They loved it", "A storyteller"],
      'answerChoices': [
        ["Near a beach", "Near a school", "Near a volcano", "In a city"],
        ["A science report", "A poem", "A volcano story", "A journal"],
        ["They ignored it", "They loved it", "They laughed", "They were unsure"],
        ["A teacher", "A writer", "A storyteller", "A singer"]
      ],
      'animation': 'images/volcano.json',
    },
  ];

  @override
  Widget build(BuildContext context) {
    _speak(context, tr(LocaleKeys.tts_level3_welcome));

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFFFF8E1),
        appBar: AppBar(
          backgroundColor: Colors.orange,
          elevation: 0,
          centerTitle: true,
          title: Text(
            tr(LocaleKeys.english_level3_title),
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
            Center(
              child: KaraokeSentenceEnglishLevel3Screen(),
            ),

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
                  title: tr(LocaleKeys.level3_quiz_title),
                  jsonPath: "images/new_images/Quiz.json",
                  onTap: () {
                    _speak(context, tr(LocaleKeys.tts_start_final_quiz));
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EnglishLevel3QuizAllScreen(),
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
                          builder: (_) => EnglishLevel3Screen(
                            title: tr(story['title']),
                            storyText: story['paragraph'],
                            questions: List<String>.from(story['questions']),
                            correctAnswers: List<String>.from(story['answers']),
                            answerChoices: List<List<String>>.from(story['answerChoices']),
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
