import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math';

import 'package:flutter_application_3/letters/mathmatics/game.dart';

class TapTheLetterBScreen extends StatefulWidget {
  const TapTheLetterBScreen({super.key});

  @override
  _TapTheLetterBScreenState createState() => _TapTheLetterBScreenState();
}

class _TapTheLetterBScreenState extends State<TapTheLetterBScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  List<String> letters = ["b", "d", "p", "q", "b", "m", "b", "r", "b"];
  List<bool> tapped = List.filled(9, false);
  int correctTaps = 0;
  int totalB = 4; // Number of 'b' letters

  // Play correct sound
  void _playCorrectSound() async {
    await _audioPlayer.play(AssetSource('sounds/correct.mp3'));
  }

  // Play incorrect sound
  void _playWrongSound() async {
    await _audioPlayer.play(AssetSource('sounds/wrong.mp3'));
  }

  // Handle tap event
  void _handleTap(int index) {
    if (!tapped[index]) {
      setState(() {
        tapped[index] = true;
        if (letters[index] == "b") {
          correctTaps++;
          _playCorrectSound();
        } else {
          _playWrongSound();
        }
      });
    }
  }

  // Reset game
  void _resetGame() {
    setState(() {
      tapped = List.filled(9, false);
      correctTaps = 0;
      letters.shuffle(Random());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFF7E7),
      appBar: AppBar(
        title: Text("Tap the Letter 'b'"),
        backgroundColor: Colors.deepOrange,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Tap all the 'b' letters!",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),

          // Letter Grid
          GridView.builder(
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, // 3x3 grid
              childAspectRatio: 1.2,
            ),
            itemCount: letters.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => _handleTap(index),
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  margin: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: tapped[index]
                        ? (letters[index] == "b" ? Colors.green : Colors.red)
                        : Colors.white,
                    border: Border.all(color: Colors.deepOrange, width: 2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      letters[index],
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: tapped[index] ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          SizedBox(height: 20),

          // Success Message
          if (correctTaps == totalB)
            Column(
              children: [
                Text(
                  "✅ Well done! You found all 'b' letters!",
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.green),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => NumberGameScreen()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 40),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  child: Text("Next",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ],
            ),

          // Reset Button
          if (correctTaps < totalB)
            ElevatedButton(
              onPressed: _resetGame,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
              child: Text("Retry", style: TextStyle(fontSize: 18)),
            ),
        ],
      ),
    );
  }
}
