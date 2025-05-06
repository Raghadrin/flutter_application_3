import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_application_3/letters/mathmatics/cardgame.dart';

class NumberGameScreen extends StatefulWidget {
  const NumberGameScreen({super.key});

  @override
  _NumberGameScreenState createState() => _NumberGameScreenState();
}

class _NumberGameScreenState extends State<NumberGameScreen> {
  final List<int> targetNumbers = []; // Store multiple questions
  int currentTarget = 0;
  List<int> numbers = [];
  List<int> selectedNumbersList = [];
  int score = 0;
  int timeLeft = 30;
  Timer? timer;
  bool isGameOver = false;

  @override
  void initState() {
    super.initState();
    startGame();
  }

  void startGame() {
    setState(() {
      score = 0;
      isGameOver = false;
      selectedNumbersList.clear();
      targetNumbers.clear(); // Reset questions
    });
    generateQuestions(); // Generate multiple targets
    selectRandomTarget();
    generateNumbers();
    startTimer();
  }

  void generateQuestions() {
    Random random = Random();
    for (int i = 0; i < 5; i++) {
      targetNumbers
          .add(random.nextInt(15) + 5); // Generate 5 different target values
    }
  }

  void selectRandomTarget() {
    Random random = Random();
    setState(() {
      currentTarget = targetNumbers[random.nextInt(targetNumbers.length)];
    });
  }

  void generateNumbers() {
    Random random = Random();
    Set<int> uniqueNumbers = {};

    int num1 = random.nextInt(currentTarget - 1) + 1;
    int num2 = currentTarget - num1;
    uniqueNumbers.add(num1);
    uniqueNumbers.add(num2);

    while (uniqueNumbers.length < 6) {
      uniqueNumbers.add(random.nextInt(12) + 1);
    }

    numbers = uniqueNumbers.toList()..shuffle();
    setState(() {});
  }

  void startTimer() {
    timer?.cancel();
    timeLeft = 30;
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (timeLeft > 0) {
        setState(() {
          timeLeft--;
        });
      } else {
        setState(() {
          isGameOver = true;
        });
        timer.cancel();
      }
    });
  }

  void checkSelection(int number) {
    if (isGameOver || selectedNumbersList.contains(number)) return;

    setState(() {
      selectedNumbersList.add(number);
    });

    if (selectedNumbersList.length == 2) {
      int sum = selectedNumbersList.reduce((a, b) => a + b);
      if (sum == currentTarget) {
        setState(() {
          score += 10;
        });

        Future.delayed(Duration(milliseconds: 500), () {
          setState(() {
            selectedNumbersList.clear();
            selectRandomTarget(); // Shuffle to a new question
            generateNumbers(); // Generate new numbers for the new question
          });
        });
      } else {
        Future.delayed(Duration(milliseconds: 500), () {
          setState(() {
            selectedNumbersList.clear();
          });
        });
      }
    }
  }

  void restartGame() {
    timer?.cancel();
    startGame();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple.shade900,
      appBar: AppBar(
        title: Text("Number Matching Game"),
        backgroundColor: Colors.purple,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Text("Target: $currentTarget",
                style: TextStyle(fontSize: 24, color: Colors.green)),
            SizedBox(height: 10),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.5,
                  ),
                  itemCount: numbers.length,
                  itemBuilder: (context, index) {
                    int num = numbers[index];
                    bool isSelected = selectedNumbersList.contains(num);

                    return GestureDetector(
                      onTap: () => checkSelection(num),
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.green : Colors.amber,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          num.toString(),
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  Text("Score: $score",
                      style: TextStyle(fontSize: 24, color: Colors.white)),
                  Text("Time Left: $timeLeft",
                      style: TextStyle(fontSize: 20, color: Colors.red)),
                  if (isGameOver)
                    Column(
                      children: [
                        Text("Game Over!",
                            style:
                                TextStyle(fontSize: 30, color: Colors.white)),
                        Text("Final Score: $score",
                            style:
                                TextStyle(fontSize: 24, color: Colors.amber)),
                        SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: restartGame,
                          child: Text("Restart"),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => GameScreen()));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                                vertical: 12, horizontal: 40),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                          ),
                          child: Text(
                            "Next",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
