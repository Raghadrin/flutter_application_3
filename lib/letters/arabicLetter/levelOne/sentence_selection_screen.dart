import 'package:flutter/material.dart';
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
        backgroundColor: const Color(0xFFFFA726),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "📚 اختر جملتك",
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              "👇 اضغط على الجملة التي تريد تعلمها",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.orange,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.builder(
                itemCount: sentences.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 30,
                  mainAxisSpacing: 30,
                  childAspectRatio: 0.75,
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
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.orange, width: 2),
                        boxShadow: const [
                          BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              offset: Offset(2, 2)),
                        ],
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(sentence["emoji"]!,
                              style: const TextStyle(fontSize: 48)),
                          const SizedBox(height: 12),
                          Text(
                            sentence["title"]!,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.brown,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            sentence["text"]!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 22, color: Colors.brown),
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
