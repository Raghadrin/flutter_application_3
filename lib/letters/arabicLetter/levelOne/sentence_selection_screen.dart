import 'package:flutter/material.dart';
import 'package:flutter_application_3/letters/arabicLetter/levelOne/arabic_level1_quiz_all.dart';
import 'arabic_level1_screen.dart';

class SentenceSelectionScreen extends StatelessWidget {
  final List<Map<String, String>> sentences = [
    {"emoji": "🌞", "title": "شروق الشمس", "text": "الشمس تشرق كل صباح"},
    {"emoji": "✍️", "title": "كتابة الواجب", "text": "الولد يكتب الواجب"},
    {"emoji": "👩‍🍳", "title": "الطبخ", "text": "الأم تطبخ الطعام"},
    {"emoji": "🚗", "title": "الطريق", "text": "السيارة تسير في الطريق"},
    {"emoji": "📖", "title": "القراءة", "text": "أنا أحب القراءة"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      appBar: AppBar(
        backgroundColor: Colors.orange,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "📚 اختر جملتك",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            const Text(
              "👇 اضغط على الجملة التي تريد تعلمها",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.orange,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // ✅ مربع كويز مضاف قبل الشبكة
           GestureDetector(
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ArabicQuizWithSentenceEvaluation(),
      ),
    );
  },
  child: Container(
    margin: const EdgeInsets.only(bottom: 20),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.deepOrange.shade100,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.deepOrange, width: 2),
    ),
    child: Row(
      children: const [
        Icon(Icons.quiz, size: 32, color: Colors.deepOrange),
        SizedBox(width: 12),
        Text(
          "ابدأ الكويز الشامل",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.deepOrange,
          ),
        ),
      ],
    ),
  ),
),

            // الشبكة الأصلية
            Expanded(
              child: GridView.builder(
                itemCount: sentences.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.5,
                ),
                itemBuilder: (context, index) {
                  final sentence = sentences[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ArabicLevel1Screen(sentence: sentence["text"]!),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.orange, width: 2),
                        boxShadow: const [
                          BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              offset: Offset(2, 2)),
                        ],
                      ),
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(sentence["emoji"]!,
                              style: const TextStyle(fontSize: 40)),
                          const SizedBox(height: 8),
                          Text(
                            sentence["title"]!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.brown,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
