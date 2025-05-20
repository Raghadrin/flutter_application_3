import 'package:flutter/material.dart';
import 'english_level2_screen.dart';

class EnglishSentenceSelectionLevel2Screen extends StatelessWidget {
  final List<Map<String, String>> sentences = [
    {
      "emoji": "🏫",
      "title": "School Activity",
      "text": "The hardworking boy goes to school every morning with energy."
    },
    {
      "emoji": "🩺",
      "title": "Treating Patients",
      "text": "The doctor treats patients at the hospital using precise tools."
    },
    {
      "emoji": "🚦",
      "title": "Obeying the Law",
      "text": "The red car stopped at the red light in respect of the law."
    },
    {
      "emoji": "📚",
      "title": "Daily Reading",
      "text": "I read a useful book in the library every day after school."
    },
    {
      "emoji": "👩‍🍳",
      "title": "Healthy Cooking",
      "text": "Mom prepares delicious food with healthy ingredients for the family."
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
          "📚 Choose Your Sentence",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            const Text(
              "👇 Tap the sentence you want to learn",
              style: TextStyle(
                fontSize: 16,
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
                          builder: (_) => EnglishLevel2Screen(
                            sentence: sentence["text"]!,
                          ),
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
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(sentence["emoji"]!, style: const TextStyle(fontSize: 36)),
                          const SizedBox(height: 8),
                          Text(
                            sentence["title"]!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 18,
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
