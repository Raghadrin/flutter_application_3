import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_application_3/letters/englishLetters/bLetter/b_circle_draw.dart';

class WordBMatchingScreen extends StatefulWidget {
  const WordBMatchingScreen({super.key});

  @override
  _WordBMatchingScreenState createState() => _WordBMatchingScreenState();
}

class _WordBMatchingScreenState extends State<WordBMatchingScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final Map<String, bool> _selectedAnswers = {
    "Ball": false,
    "Bat": false,
    "Dog": false,
  };
  bool _answered = false;
  bool _isCorrect = false;

  void _checkAnswers() {
    setState(() {
      _answered = true;
      if (_selectedAnswers["Ball"] == true &&
          _selectedAnswers["Bat"] == true &&
          _selectedAnswers["Dog"] == false) {
        _isCorrect = true;
        _audioPlayer
            .play(AssetSource('sounds/correct.mp3')); // Play correct sound
      } else {
        _isCorrect = false;
        _audioPlayer.play(AssetSource('sounds/wrong.mp3')); // Play wrong sound
      }
    });
  }

  void _toggleSelection(String word) {
    setState(() {
      _selectedAnswers[word] = !_selectedAnswers[word]!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFF7E7), // Light warm background
      appBar: AppBar(
        title: Text("Find Words Starting with 'B'"),
        backgroundColor: Colors.deepOrange,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Tap the words that start with 'b'!",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),

          // Word options with images
          _buildWordCard("Ball", "images/ball.png"),
          _buildWordCard("Bat", "images/bat.png"),
          _buildWordCard("Dog", "images/dog.png"),

          SizedBox(height: 20),

          // Submit button
          ElevatedButton(
            onPressed: _checkAnswers,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 30),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
            ),
            child: Text("Check", style: TextStyle(fontSize: 18)),
          ),

          SizedBox(height: 20),

          // Feedback Message
          if (_answered)
            Text(
              _isCorrect ? "✅ Correct! Well done!" : "❌ Try Again!",
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _isCorrect ? Colors.green : Colors.red),
            ),

          SizedBox(height: 20),

          // Next Button
          if (_isCorrect)
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => TapTheLetterBScreen()));
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

  // Word Card Widget
  Widget _buildWordCard(String word, String imagePath) {
    return GestureDetector(
      onTap: () => _toggleSelection(word),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: _selectedAnswers[word]! ? Colors.orangeAccent : Colors.white,
          border: Border.all(color: Colors.deepOrange, width: 3),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image.asset(imagePath, height: 50),
            SizedBox(width: 20),
            Text(
              word,
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}
