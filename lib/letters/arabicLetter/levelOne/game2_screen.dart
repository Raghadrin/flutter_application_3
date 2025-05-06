import 'package:flutter/material.dart';
import 'game3_screen.dart'; // شاشة اللعبة التالية

class Game2Screen extends StatefulWidget {
  const Game2Screen({super.key});

  @override
  Game2ScreenState createState() => Game2ScreenState();
}

class Game2ScreenState extends State<Game2Screen> {
  String targetLetter = 'ب'; // الحرف المستهدف
  List<Map<String, dynamic>> words = [
    {'word': 'ارنب', 'image': '🐇', 'selected': false},
    {'word': 'برتقال', 'image': '🍊', 'selected': false},
    {'word': 'دب', 'image': '🐻', 'selected': false},
  ];

  String feedbackMessage = '';
  bool isCorrect = false;

  void checkAnswers() {
    setState(() {
      bool allCorrect = words.every((word) =>
          (word['word'].startsWith(targetLetter) && word['selected']) ||
          (!word['word'].startsWith(targetLetter) && !word['selected']));

      if (allCorrect) {
        isCorrect = true;
        feedbackMessage = '✅ أحسنت!';
      } else {
        isCorrect = false;
        feedbackMessage = '❌ حاول مرة أخرى';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1), // خلفية ممتعة للأطفال
      appBar: AppBar(
        title: Text("🔠 اختر الكلمة التي تبدأ بـ $targetLetter"),
        backgroundColor: Colors.orange,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "اضغط على الكلمة التي تبدأ بالحرف '$targetLetter'",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 30),

              // Grid with square-shaped cards
              GridView.count(
                crossAxisCount: 1,
                shrinkWrap: true,
                mainAxisSpacing: 20,
                childAspectRatio: 2.5,
                physics: const NeverScrollableScrollPhysics(),
                children: words.map((word) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        word['selected'] = !word['selected'];
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: word['selected']
                            ? Colors.orange.shade400
                            : Colors.white,
                        border: Border.all(color: Colors.orange, width: 4),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: Offset(2, 2),
                          )
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            word['image'],
                            style: const TextStyle(fontSize: 40),
                          ),
                          const SizedBox(width: 20),
                          Text(
                            word['word'],
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: checkAnswers,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  textStyle: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: const Text("تحقق"),
              ),

              Text(
                feedbackMessage,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: isCorrect ? Colors.green : Colors.red,
                ),
              ),

              if (isCorrect)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => Game3Screen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 15),
                      textStyle: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: const Text('التالي'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
