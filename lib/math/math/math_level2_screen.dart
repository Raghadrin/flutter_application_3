import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../games/operation_sequence_game.dart';
import '../games/hard_equation_game.dart';
import '../quiz/level2_quiz.dart';
import '../game_audio_helper.dart';


class MathLevel2Screen extends StatelessWidget {
  final FlutterTts tts = FlutterTts();

  MathLevel2Screen({super.key});

  void _speak(String text) async {
    await tts.setLanguage("en-US");
    await tts.setPitch(1.0);
    await tts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    _speak("Welcome to Level 2. Let's solve harder math problems.");

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackButton(color: Colors.black),
        title: Text(
          "Math - Level 2",
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'Arial',
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          Image.asset("images/subject_fox.PNG", height: 140),
          SizedBox(height: 20),
          _buildGameButton(context, "Solve Two-Step Equations", () {
            GameAudioHelper.speak("Solve two-step equations like 2 plus 3 times 2.");
            Navigator.push(context, MaterialPageRoute(builder: (_) => OperationSequenceGame()));
          }),
          _buildGameButton(context, "Find the Missing Number", () {
            GameAudioHelper.speak("Find the missing number in equations like x times 3 equals 12.");
            Navigator.push(context, MaterialPageRoute(builder: (_) => HardEquationGame()));
          }),
          Divider(height: 40),
          _buildGameButton(context, "Test What You Learned", () {
            GameAudioHelper.sayStartQuiz();
            Navigator.push(context, MaterialPageRoute(builder: (_) => Level2Quiz()));
          }),
        ],
      ),
    );
  }

  Widget _buildGameButton(BuildContext context, String title, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 65,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: const LinearGradient(
              colors: [Color(0xFFFBD1B2), Color(0xFFFEE5D3)],
            ),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Arial',
              ),
            ),
          ),
        ),
      ),
    );
  }
}
