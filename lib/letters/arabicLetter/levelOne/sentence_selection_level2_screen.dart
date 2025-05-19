import 'package:flutter/material.dart';
import 'arabic_level2_screen.dart';

class SentenceSelectionLevel2Screen extends StatelessWidget {
  final List<Map<String, String>> sentences = [
    {
      "emoji": "🏫",
      "title": "نشاط مدرسي",
      "text": "الولد المجتهد يذهب إلى المدرسة كل صباح بنشاط"
    },
    {
      "emoji": "🩺",
      "title": "علاج المرضى",
      "text": "الطبيبة تعالج المرضى في المستشفى باستخدام أدوات دقيقة"
    },
    {
      "emoji": "🚦",
      "title": "احترام القانون",
      "text": "السيارة الحمراء توقفت عند الإشارة الحمراء احترامًا للقانون"
    },
    {
      "emoji": "📚",
      "title": "القراءة اليومية",
      "text": "أنا أقرأ كتابًا مفيدًا في المكتبة كل يوم بعد المدرسة"
    },
    {
      "emoji": "👩‍🍳",
      "title": "الطبخ الصحي",
      "text": "الأم تحضر طعامًا لذيذًا بمكونات صحية للحفاظ على العائلة"
    },
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
            Expanded(
              child: GridView.builder(
                itemCount: sentences.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.85,
                ),
                itemBuilder: (context, index) {
                  final sentence = sentences[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ArabicLevel2Screen(sentence: sentence["text"]!),
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
                          // ✅ Removed the sentence text from view
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
