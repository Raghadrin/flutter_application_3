import 'package:flutter/material.dart';
import 'english_level1_screen.dart';

class EnglishSentenceSelectionScreen extends StatelessWidget {
  final List<Map<String, String>> sentences = [
    {"emoji": "🌞", "title": "Sunrise", "text": "The sun rises every morning"},
    {"emoji": "✍️", "title": "Homework", "text": "The boy is doing his homework"},
    {"emoji": "👩‍🍳", "title": "Cooking", "text": "Mom is cooking food"},
    {"emoji": "🚗", "title": "Road", "text": "The car drives on the road"},
    {"emoji": "📖", "title": "Reading", "text": "I love reading books"},
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
              "👇 Tap on the sentence you want to learn",
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
                  childAspectRatio: 0.5,
                ),
                itemBuilder: (context, index) {
                  final sentence = sentences[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EnglishLevel1Screen(sentence: sentence["text"]!),
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
                          Text(sentence["emoji"]!, style: const TextStyle(fontSize: 40)),
                          const SizedBox(height: 8),
                          Text(
                            sentence["title"]!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
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
