import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  List<int> numbers = [];
  List<Color> cardColors = [];
  List<bool> revealed = [];
  int? firstSelectedIndex;
  int score = 0;
  int timeLeft = 60;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    generateNumbers();
    startTimer();
  }

  void generateNumbers() {
    List<int> numList = List.generate(8, (index) => Random().nextInt(10) + 1);
    numbers = [...numList, ...numList];
    numbers.shuffle();
    revealed = List.filled(numbers.length, false);
    cardColors = List.filled(numbers.length, Colors.grey);
  }

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (timeLeft > 0) {
          timeLeft--;
        } else {
          timer.cancel();
          showGameOverDialog("Time's Up! You Lose!");
        }
      });
    });
  }

  void checkMatch(int index) {
    if (firstSelectedIndex == null) {
      firstSelectedIndex = index;
    } else {
      if (numbers[firstSelectedIndex!] == numbers[index]) {
        setState(() {
          score += 100;
          cardColors[firstSelectedIndex!] = Colors.green;
          cardColors[index] = Colors.green;
          firstSelectedIndex = null;
        });
      } else {
        setState(() {
          cardColors[firstSelectedIndex!] = Colors.red;
          cardColors[index] = Colors.red;
        });
        Future.delayed(Duration(seconds: 1), () {
          setState(() {
            revealed[firstSelectedIndex!] = false;
            revealed[index] = false;
            cardColors[firstSelectedIndex!] = Colors.grey;
            cardColors[index] = Colors.grey;
            firstSelectedIndex = null;
          });
        });
      }
    }
  }

  void showGameOverDialog(String message) {
    timer?.cancel();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Game Over"),
        content: Text("$message\nScore: $score"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              resetGame();
            },
            child: Text("Play Again"),
          ),
        ],
      ),
    );
  }

  void resetGame() {
    setState(() {
      score = 0;
      timeLeft = 60;
      generateNumbers();
    });
    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Match The Numbers")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Score: $score", style: TextStyle(fontSize: 24)),
          Text("Time Left: $timeLeft s",
              style: TextStyle(fontSize: 20, color: Colors.red)),
          SizedBox(height: 20),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 1.4,
              ),
              itemCount: numbers.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    if (!revealed[index]) {
                      setState(() {
                        revealed[index] = true;
                      });
                      checkMatch(index);
                    }
                  },
                  child: Card(
                    color: revealed[index] ? cardColors[index] : Colors.grey,
                    child: Center(
                      child: Text(
                        revealed[index] ? "${numbers[index]}" : "?",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
