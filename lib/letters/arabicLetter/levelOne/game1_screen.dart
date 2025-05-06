import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'game2_screen.dart';

class Game1Screen extends StatefulWidget {
  const Game1Screen({super.key});

  @override
  Game1ScreenState createState() => Game1ScreenState();
}

class Game1ScreenState extends State<Game1Screen> {
  String targetLetter = 'ب';
  String feedbackMessage = '';
  bool isCorrect = false;
  bool answered = false;

  List<String> letters = ['ت', 'ب', 'ث', 'ي'];

  void checkAnswer(String selectedLetter) {
    setState(() {
      answered = true;
      isCorrect = selectedLetter == targetLetter;
      feedbackMessage = isCorrect ? '🎉 أحسنت!' : '❌ حاول مرة أخرى';
    });
  }

  void resetGame() {
    setState(() {
      answered = false;
      feedbackMessage = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      appBar: AppBar(
        title: const Text("🎯 اختر الحرف "),
        backgroundColor: Colors.orange,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "اضغط على الحرف الصحيح ($targetLetter)",
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 30),

              // Letters Grid
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                childAspectRatio: 1,
                physics: const NeverScrollableScrollPhysics(),
                children: letters.map((letter) {
                  return GestureDetector(
                    onTap: () => checkAnswer(letter),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
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
                      alignment: Alignment.center,
                      child: Text(
                        letter,
                        style: const TextStyle(
                          fontSize: 50,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 30),

              if (answered) ...[
                SizedBox(
                  height: 120,
                  child: Lottie.asset(
                    isCorrect ? 'assets/success.json' : 'assets/try_again.json',
                    repeat: false,
                  ),
                ),
                Text(
                  feedbackMessage,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: isCorrect ? Colors.green : Colors.red,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (isCorrect) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const Game2Screen()),
                      );
                    } else {
                      resetGame();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isCorrect ? Colors.green : Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                    textStyle: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: Text(isCorrect ? 'التالي' : 'حاول مرة أخرى'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
