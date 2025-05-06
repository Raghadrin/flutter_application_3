import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'game4_screen.dart';

class Game3Screen extends StatefulWidget {
  const Game3Screen({super.key});

  @override
  Game3ScreenState createState() => Game3ScreenState();
}

class Game3ScreenState extends State<Game3Screen> {
  final List<String> correctOrder = ["ب", 'ا', 'ت', 'ك'];
  List<String?> userOrder = [null, null, null, null];
  late List<String> shuffledLetters;
  bool showLottie = false;

  @override
  void initState() {
    super.initState();
    shuffledLetters = List<String>.from(correctOrder)..shuffle();
  }

  void checkAnswer() {
    if (userOrder.every((element) => element != null)) {
      if (userOrder.join() == correctOrder.join()) {
        setState(() {
          showLottie = true;
        });

        Future.delayed(const Duration(seconds: 2), () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("أحسنت",
                  style: TextStyle(color: Colors.green, fontSize: 22)),
              content: const Text("لقد رتبت الحروف بشكل صحيح"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Game4Screen()),
                    );
                  },
                  child: const Text("التالي",
                      style: TextStyle(color: Colors.blue)),
                )
              ],
            ),
          );
        });
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("حاول مرة أخرى",
                style: TextStyle(color: Colors.red, fontSize: 22)),
            content: const Text("لم يتم ترتيب الحروف بشكل صحيح، جرب مرة أخرى"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    userOrder = [null, null, null, null];
                    shuffledLetters = List<String>.from(correctOrder)
                      ..shuffle();
                    showLottie = false;
                  });
                },
                child:
                    const Text("حسناً", style: TextStyle(color: Colors.blue)),
              )
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0), // soft peach background
      appBar: AppBar(
        title: const Text("لعبة ترتيب الحروف",
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.orange,
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "🧩 اسحب الحروف وضعها في الترتيب الصحيح",
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(userOrder.length, (index) {
                  return DragTarget<String>(
                    onWillAcceptWithDetails: (data) => true,
                    onAcceptWithDetails: (data) {
                      setState(() {
                        if (userOrder.contains(data)) {
                          int oldIndex = userOrder.indexOf(data as String?);
                          userOrder[oldIndex] = null;
                        }
                        userOrder[index] = data as String?;
                      });
                      checkAnswer();
                    },
                    builder: (context, candidateData, rejectedData) {
                      return Container(
                        width: 70,
                        height: 70,
                        margin: const EdgeInsets.all(8),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: userOrder[index] == null
                              ? Colors.grey[200]
                              : Colors.lightBlue,
                          borderRadius: BorderRadius.circular(15),
                          border:
                              Border.all(color: Colors.deepOrange, width: 2),
                        ),
                        child: Text(
                          userOrder[index] ?? "",
                          style: const TextStyle(
                              fontSize: 30, color: Colors.white),
                        ),
                      );
                    },
                  );
                }),
              ),
              const SizedBox(height: 40),
              Wrap(
                spacing: 15,
                runSpacing: 15,
                children: shuffledLetters.map((letter) {
                  return Draggable<String>(
                    data: letter,
                    feedback: Material(
                      color: Colors.transparent,
                      child: letterBox(letter, Colors.orange),
                    ),
                    childWhenDragging: letterBox(
                        userOrder.contains(letter) ? "" : letter,
                        userOrder.contains(letter)
                            ? Colors.grey.shade400
                            : Colors.orange),
                    child: letterBox(
                        userOrder.contains(letter) ? "" : letter,
                        userOrder.contains(letter)
                            ? Colors.grey.shade400
                            : Colors.orange),
                  );
                }).toList(),
              ),
              const SizedBox(height: 30),
            ],
          ),
          if (showLottie)
            Positioned(
              bottom: 0,
              child: SizedBox(
                width: 200,
                height: 200,
                child: Lottie.asset('assets/success.json', repeat: false),
              ),
            ),
        ],
      ),
    );
  }

  Widget letterBox(String letter, Color color) {
    return Container(
      width: 70,
      height: 70,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.deepOrange, width: 2),
      ),
      child: Text(letter,
          style: const TextStyle(fontSize: 30, color: Colors.white)),
    );
  }
}
