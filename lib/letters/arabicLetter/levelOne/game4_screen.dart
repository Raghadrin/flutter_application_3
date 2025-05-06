import 'package:flutter/material.dart';
import 'game5_screen.dart'; // استيراد لعبة 5

class Game4Screen extends StatefulWidget {
  const Game4Screen({super.key});

  @override
  Game4ScreenState createState() => Game4ScreenState();
}

class Game4ScreenState extends State<Game4Screen> {
  final String word = "أرنب";
  final String targetLetter = "ب";
  final String correctPosition = "نهاية";
  List<String> options = ["بداية", "وسط", "نهاية"];
  String? userAnswer;

  void checkAnswer() {
    if (userAnswer == correctPosition) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("🎉 أحسنت!",
              style: TextStyle(color: Colors.green, fontSize: 26)),
          content: const Text("لقد اخترت الإجابة الصحيحة!",
              style: TextStyle(fontSize: 20)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Game5Screen()),
                );
              },
              child: const Text("التالي",
                  style: TextStyle(fontSize: 20, color: Colors.blue)),
            )
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("❌ حاول مرة أخرى",
              style: TextStyle(color: Colors.red, fontSize: 24)),
          content: const Text("لم تكن الإجابة صحيحة، جرب مرة أخرى",
              style: TextStyle(fontSize: 18)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  userAnswer = null;
                });
              },
              child: const Text("حسناً",
                  style: TextStyle(fontSize: 18, color: Colors.blue)),
            )
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      appBar: AppBar(
        title: const Text("📍 موقع الحروف",
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
                'images/rabbit.png',
                width: 150,
                height: 300,
              ),
              //const SizedBox(height: 10),
              Text(
                "أين يقع الحرف '$targetLetter' في الكلمة '$word'؟",
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ...options.map((option) {
                final bool isSelected = userAnswer == option;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      userAnswer = option;
                    });
                    checkAnswer();
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 40),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.green : Colors.orangeAccent,
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
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
