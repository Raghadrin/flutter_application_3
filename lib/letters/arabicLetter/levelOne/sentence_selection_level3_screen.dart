import 'package:flutter/material.dart';
import 'arabic_level3_screen.dart';
import 'arabic_level3_quiz_all.dart';

class SentenceSelectionLevel3Screen extends StatelessWidget {
  final List<Map<String, dynamic>> stories = [
    {
      'emoji': '🌳',
      'title': 'يوم في الحديقة',
      'paragraph': 'في صباح مشمس، ذهب سامي مع والده إلى الحديقة...',
      'questions': ["ما عنوان القصة؟", "من ذهب إلى الحديقة؟", "ماذا فعل سامي؟", "ماذا شاهدوا؟"],
      'answers': ["يوم في الحديقة", "سامي مع والده", "لعب كثيرًا", "الطيور"]
    },
    {
      'emoji': '🌧️',
      'title': 'ألعاب المطر',
      'paragraph': 'في فصل الشتاء، تهطل الأمطار وتصبح الأرض مبللة...',
      'questions': ["في أي فصل؟", "ماذا يحدث للأرض؟", "بماذا يلعبون؟", "ماذا يرتدون؟"],
      'answers': ["فصل الشتاء", "تصبح مبللة", "القوارب", "المعاطف والأحذية"]
    },
    {
      'emoji': '📖',
      'title': 'قصة قبل النوم',
      'paragraph': 'تحب سارة قراءة القصص قبل النوم...',
      'questions': ["من تحب القراءة؟", "متى؟", "من معها؟", "بماذا تحلم؟"],
      'answers': ["سارة", "قبل النوم", "والدتها", "أماكن جميلة"]
    },
    {
      'emoji': '🏫',
      'title': 'في المدرسة',
      'paragraph': 'في المدرسة، يتعلم التلاميذ القراءة والكتابة...',
      'questions': ["أين؟", "ماذا يتعلمون؟", "من يحبون؟", "لماذا؟"],
      'answers': ["في المدرسة", "القراءة والكتابة", "المعلم", "يشجعهم"]
    },
    {
      'emoji': '🏖️',
      'title': 'عطلة على الشاطئ',
      'paragraph': 'ذهبت العائلة إلى البحر في العطلة...',
      'questions': ["أين ذهبوا؟", "ماذا بنوا؟", "أين سبحوا؟", "ماذا أكلوا؟"],
      'answers': ["إلى البحر", "قلاع", "في الماء", "طعامًا لذيذًا"]
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF7E4),
      appBar: AppBar(
        backgroundColor: Colors.orange,
        centerTitle: true,
        title: const Text(
          "📚 اختر قصة",
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: GridView.builder(
                itemCount: stories.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 24,
                  crossAxisSpacing: 24,
                  childAspectRatio: 1,
                ),
                itemBuilder: (context, index) {
                  final story = stories[index];
                  return GestureDetector(
                    onTap: () {
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
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.orange.shade300),
                        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FittedBox(
                            child: Text(
                              story['emoji'],
                              style: const TextStyle(fontSize: 38),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            story['title'],
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4E342E),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.quiz),
              label: const Text("ابدأ الكويز الشامل 📝", style: TextStyle(fontSize: 20)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ArabicLevel3QuizAllScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
