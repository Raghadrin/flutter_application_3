import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_application_3/letters/arabicLetter/levelOne/game1_screen.dart';

class Game6Screen extends StatefulWidget {
  const Game6Screen({super.key});

  @override
  Game6ScreenState createState() => Game6ScreenState();
}

class Game6ScreenState extends State<Game6Screen> {
  List<List<String>> grid = [
    ['ب', 'ا', 'ت'],
    ['ج', 'ح', 'ر'],
  ];
  String targetWord = 'بحر';
  List<String> selectedLetters = [];
  List<List<int>> selectedPositions = [];
  bool wordFound = false;

  void _onLetterSelected(int row, int col) {
    if (wordFound) return; // prevent further interaction after win

    setState(() {
      if (!selectedPositions.any((pos) => pos[0] == row && pos[1] == col)) {
        selectedLetters.add(grid[row][col]);
        selectedPositions.add([row, col]);

        if (selectedLetters.join() == targetWord) {
          wordFound = true;
        }
      }
    });
  }

  void _resetSelection() {
    setState(() {
      selectedLetters.clear();
      selectedPositions.clear();
    });
  }

  void _goToNextGame() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => Game1Screen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0), // fun background color
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: const Text('🎲  البحث عن الكلمات'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '🔍 ابحث عن الكلمة: "بحر"',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Grid
              GridView.builder(
                shrinkWrap: true,
                itemCount: grid.length * grid[0].length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.2,
                ),
                itemBuilder: (context, index) {
                  int row = index ~/ grid[0].length;
                  int col = index % grid[0].length;
                  bool isSelected = selectedPositions
                      .any((pos) => pos[0] == row && pos[1] == col);
                  return GestureDetector(
                    onTap: () => _onLetterSelected(row, col),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color.fromARGB(255, 255, 174, 43)
                            : Colors.orange.shade200,
                        borderRadius: BorderRadius.circular(15),
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
                        grid[row][col],
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),
              Text(
                '📘 الحروف المحددة: ${selectedLetters.join()}',
                style: const TextStyle(fontSize: 22),
              ),

              const SizedBox(height: 20),

              // Win Section
              if (wordFound)
                Column(
                  children: [
                    Lottie.asset('assets/success.json',
                        width: 300, height: 300, repeat: false),
                    const Text(
                      '🎉 تهانينا! لقد وجدت الكلمة الصحيحة 🎉',
                      style: TextStyle(
                          fontSize: 22,
                          color: Colors.green,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _goToNextGame,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('التالي'),
                    ),
                  ],
                ),

              // Retry Button
              if (!wordFound && selectedLetters.length == targetWord.length)
                ElevatedButton(
                  onPressed: _resetSelection,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('🔄 حاول مرة أخرى'),
                )
            ],
          ),
        ),
      ),
    );
  }
}
