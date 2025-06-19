// Updated Evaluation2Screen with old visual style and overflow fix for Arabic

import 'package:flutter/material.dart';
import 'practice_mispronounced_ar.dart';
import 'dyslexia_summary_ar.dart';

const Map<String, String> categoryDescriptionsAr = {
  'حيوانات': '🐾 كلمات تصف الحيوانات مثل "سلحفاة" أو "أرنب".',
  'أشخاص': '🧑‍🤝‍🧑 كلمات تشير إلى أشخاص في القصة مثل "سامي" أو "المعلم".',
  'أشياء': '📦 كلمات لأشياء يمكن لمسها مثل "شجرة" أو "حقيبة".',
  'أماكن': '📍 كلمات تصف مواقع مثل "البيت" أو "الغابة".',
  'صفات': '🎨 صفات تصف الشكل أو الشعور مثل "سعيد" أو "ذكي".',
  'أفعال': '🏃 أفعال تصف ما يفعله الشخص مثل "يركض" أو "يفكر".',
  'مفاهيم': '💡 أفكار أو معاني غير مادية مثل "العدل" أو "المساعدة".',
  'مشاعر': '❤️ كلمات تصف المشاعر مثل "الحزن" أو "الفرح".',
};

class Evaluation2Screen extends StatelessWidget {
  final String recognizedText;
  final double score;
  final int stars;
  final dynamic level;
  final Map<String, bool> wordMatchResults;
  final VoidCallback onNext;
  final Map<String, Map<String, String>> wordCategories;

  const Evaluation2Screen({
    super.key,
    required this.recognizedText,
    required this.score,
    required this.stars,
    required this.level,
    required this.wordMatchResults,
    required this.onNext,
    required this.wordCategories,
  });

  @override
  Widget build(BuildContext context) {
    final wrongWords = wordMatchResults.entries.where((e) => !e.value).map((e) => e.key).toList();
    final correctWords = wordMatchResults.entries.where((e) => e.value).map((e) => e.key).toList();
    final mistakeCategories = wrongWords.map((w) => wordCategories[w]?['category']).whereType<String>().toSet().toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange.shade700,
        title: const Text('📊 التقييم'),
      ),
      backgroundColor: const Color(0xFFFFF8F1),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(child: Text('النص المُتعرف عليه:', style: Theme.of(context).textTheme.titleSmall, textDirection: TextDirection.rtl)),
            const SizedBox(height: 4),
            Center(child: Text(recognizedText, textAlign: TextAlign.center, textDirection: TextDirection.rtl)),
            const Divider(height: 32),
            Center(
              child: Column(
                children: [
                  Text('النسبة: ${score.toStringAsFixed(1)}%', style: const TextStyle(fontSize: 20)),
                  Text('الصحيحة: ${correctWords.length} / ${wordMatchResults.length}'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (i) => Icon(i < stars ? Icons.star : Icons.star_border, color: Colors.amber)),
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.green.shade200),
                borderRadius: BorderRadius.circular(12),
                color: Colors.green.shade50,
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('✔️ الكلمات الصحيحة:', style: TextStyle(fontWeight: FontWeight.bold), textDirection: TextDirection.rtl),
                  const SizedBox(height: 6),
                  Wrap(spacing: 8, runSpacing: 6, children: correctWords.map((w) => Chip(label: Text(w, textDirection: TextDirection.rtl))).toList()),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.red.shade200),
                borderRadius: BorderRadius.circular(12),
                color: Colors.red.shade50,
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('❌ الكلمات الخاطئة:', style: TextStyle(fontWeight: FontWeight.bold), textDirection: TextDirection.rtl),
                  const SizedBox(height: 6),
                  Wrap(spacing: 8, runSpacing: 6, children: wrongWords.map((w) => Chip(label: Text(w, textDirection: TextDirection.rtl))).toList()),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (mistakeCategories.isNotEmpty)
              Container(
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('📚 مجالات التعلم', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), textDirection: TextDirection.rtl),
                    const SizedBox(height: 16),
                    for (final cat in mistakeCategories)
                      if (categoryDescriptionsAr[cat]?.isNotEmpty == true)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('📁 $cat', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), textDirection: TextDirection.rtl),
                              const SizedBox(height: 4),
                              Text(categoryDescriptionsAr[cat]!, style: const TextStyle(fontSize: 13), textDirection: TextDirection.rtl),
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 8,
                                runSpacing: 6,
                                children: wrongWords
                                    .where((w) => wordCategories[w]?['category'] == cat)
                                    .map((w) => Chip(label: Text(w, textDirection: TextDirection.rtl)))
                                    .toList(),
                              )
                            ],
                          ),
                        ),
                  ],
                ),
              ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              onPressed: () => Navigator.pop(context),
              label: const Text('أعد المحاولة'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange.shade300),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.record_voice_over),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent),
              onPressed: wrongWords.isEmpty
                  ? null
                  : () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => PracticeMispronouncedArScreen(
                            words: wrongWords,
                            wordCategories: wordCategories,
                            maxAttempts: 3,
                            onFinished: () => Navigator.of(context).pop(),
                          ),
                        ),
                      );
                    },
              label: const Text('تدرب على الكلمات الخاطئة'),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.navigate_next),
              onPressed: onNext,
              label: const Text('التالي'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent),
            ),
          ],
        ),
      ),
    );
  }
}
