import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_application_3/letters/englishLetters/bLetter/b_match_g.dart';

class LetterBRecognitionScreen extends StatefulWidget {
  const LetterBRecognitionScreen({super.key});

  @override
  _LetterBRecognitionScreenState createState() =>
      _LetterBRecognitionScreenState();
}

class _LetterBRecognitionScreenState extends State<LetterBRecognitionScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isCorrect = false;
  bool _answered = false;

  void _checkAnswer(String selectedLetter) {
    setState(() {
      _answered = true;
      if (selectedLetter == 'b') {
        _isCorrect = true;
        _audioPlayer
            .play(AssetSource('sounds/correct.mp3')); // Play correct sound
      } else {
        _isCorrect = false;
        _audioPlayer.play(AssetSource('sounds/wrong.mp3')); // Play wrong sound
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFF7E7), // Light warm background
      appBar: AppBar(
        title: Text("Find the Letter 'b'"),
        backgroundColor: Colors.deepOrange,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Tap the correct letter!",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),

          // Letters to choose from
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLetterButton("d"),
              _buildLetterButton("b"),
              _buildLetterButton("q"),
              _buildLetterButton("p"),
            ],
          ),
          SizedBox(height: 30),

          // Feedback Message
          if (_answered)
            Text(
              _isCorrect ? "✅ Correct! Well done!" : "❌ Try Again!",
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _isCorrect ? Colors.green : Colors.red),
            ),

          SizedBox(height: 30),

          // Next Button
          if (_isCorrect)
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => WordBMatchingScreen()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 40),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
              child: Text("Next",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    );
  }

  // Letter Button Widget
  Widget _buildLetterButton(String letter) {
    return GestureDetector(
      onTap: () => _checkAnswer(letter),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 10),
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.deepOrange, width: 3),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          letter,
          style: TextStyle(
              fontSize: 50,
              fontWeight: FontWeight.bold,
              color: Colors.orangeAccent),
        ),
      ),
    );
  }
}
