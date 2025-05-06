import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'game6_screen.dart';

class Game5Screen extends StatefulWidget {
  const Game5Screen({super.key});

  @override
  Game5ScreenState createState() => Game5ScreenState();
}

class Game5ScreenState extends State<Game5Screen> {
  final String incompleteWord = "_طة";
  final List<String> options = ["ب", "ج", "ث", "ت"];
  final String correctLetter = "ب";
  String? userAnswer;
  bool isCorrect = false;
  bool answered = false;

  void checkAnswer() {
    setState(() {
      answered = true;
      isCorrect = userAnswer == correctLetter;
    });
  }

  void resetGame() {
    setState(() {
      answered = false;
      userAnswer = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      appBar: AppBar(
        title: const Text("🔤 الحرف الناقص",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.orange,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'images/duck.png',
                width: 300,
                height: 300,
              ),
              const SizedBox(height: 10),
              Text(
                "أكمل الكلمة: $incompleteWord",
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              if (answered)
                Column(
                  children: [
                    SizedBox(
                      height: 200,
                      child: Lottie.asset(
                        isCorrect
                            ? 'assets/success.json'
                            : 'assets/try_again.json',
                        repeat: false,
                      ),
                    ),
                    Text(
                      isCorrect ? "أحسنت 🎉" : "❌ حاول مرة أخرى",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isCorrect ? Colors.green : Colors.red,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () {
                        if (isCorrect) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Game6Screen()),
                          );
                        } else {
                          resetGame();
                        }
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                      child: Text(
                        isCorrect ? "التالي" : "حاول مرة أخرى",
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              if (!answered)
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  alignment: WrapAlignment.center,
                  children: options.map((option) {
                    final bool isSelected = userAnswer == option;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          userAnswer = option;
                        });
                        checkAnswer();
                      },
                      child: Container(
                        width: 80,
                        height: 80,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color:
                              isSelected ? Colors.green : Colors.orangeAccent,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade400,
                              blurRadius: 6,
                              offset: const Offset(2, 4),
                            )
                          ],
                        ),
                        child: Text(
                          option,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
