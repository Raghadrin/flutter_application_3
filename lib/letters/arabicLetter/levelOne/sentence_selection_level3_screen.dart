import 'package:flutter/material.dart';
import 'arabic_level3_screen.dart';

class SentenceSelectionLevel3Screen extends StatelessWidget {
  final List<Map<String, dynamic>> stories = [
    {
      'emoji': '🌳',
      'title': 'يوم في الحديقة',
      'paragraph':
          'في صباح مشمس، ذهب سامي مع والده إلى الحديقة. لعب هناك مع أصدقائه كثيرًا، ثم جلسوا معًا ليتناولوا الطعام ويشاهدوا الطيور تحلق في السماء.',
      'questions': [
        "ما عنوان القصة؟",
        "من ذهب إلى الحديقة؟",
        "ماذا فعل سامي مع أصدقائه؟",
        "ماذا شاهدوا في السماء؟"
      ],
      'answers': ["يوم في الحديقة", "سامي مع والده", "لعب كثيرًا", "الطيور"]
    },
    {
      'emoji': '🌧️',
      'title': 'ألعاب المطر',
      'paragraph':
          'في فصل الشتاء، تهطل الأمطار وتصبح الأرض مبللة. يحب الأطفال ارتداء المعاطف والأحذية الطويلة، واللعب بالماء وتشكيل القوارب الصغيرة.',
      'questions': [
        "في أي فصل وقعت القصة؟",
        "ماذا يحدث للأرض؟",
        "بماذا يلعب الأطفال؟",
        "ماذا يرتدون؟"
      ],
      'answers': [
        "فصل الشتاء",
        "تصبح مبللة",
        "القوارب الصغيرة",
        "المعاطف والأحذية"
      ]
    },
    {
      'emoji': '📖',
      'title': 'قصة قبل النوم',
      'paragraph':
          'تحب سارة قراءة القصص قبل النوم. كل ليلة تختار قصة ممتعة وتقرأها مع والدتها، ثم تغلق عينيها وتحلم بأماكن جميلة.',
      'questions': [
        "من تحب قراءة القصص؟",
        "متى تقرأ القصة؟",
        "من يقرأ معها؟",
        "بماذا تحلم؟"
      ],
      'answers': ["سارة", "قبل النوم", "والدتها", "أماكن جميلة"]
    },
    {
      'emoji': '🏫',
      'title': 'في المدرسة',
      'paragraph':
          'في المدرسة، يتعلم التلاميذ القراءة والكتابة والحساب. يحبون المعلم لأنّه يساعدهم على الفهم ويشجعهم دائمًا على الاجتهاد والتفوق.',
      'questions': [
        "أين تقع أحداث القصة؟",
        "ماذا يتعلم التلاميذ؟",
        "من يحبون؟",
        "لماذا يحبونه؟"
      ],
      'answers': [
        "في المدرسة",
        "القراءة والكتابة والحساب",
        "المعلم",
        "لأنه يشجعهم"
      ]
    },
    {
      'emoji': '🏖️',
      'title': 'عطلة على الشاطئ',
      'paragraph':
          'ذهبت العائلة إلى البحر في العطلة. بنوا قلاعًا من الرمل، وسبحوا في الماء، وأكلوا طعامًا لذيذًا تحت الشمس الدافئة.',
      'questions': [
        "إلى أين ذهبت العائلة؟",
        "ماذا بنوا؟",
        "أين سبحوا؟",
        "ماذا أكلوا؟"
      ],
      'answers': ["إلى البحر", "قلاع من الرمل", "في الماء", "طعامًا لذيذًا"]
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF7E4),
      appBar: AppBar(
        backgroundColor: Colors.orange,
        centerTitle: true,
        title: const Text("📚 اختر قصة",
            style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: GridView.builder(
          itemCount: stories.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 30,
            crossAxisSpacing: 30,
            childAspectRatio: 0.5,
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
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 4)
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(story['emoji'], style: const TextStyle(fontSize: 56)),
                    const SizedBox(height: 16),
                    Text(
                      story['title'],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4E342E),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      story['paragraph']
                              .toString()
                              .split(' ')
                              .take(4)
                              .join(' ') +
                          "...",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.brown,
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
    );
  }
}
