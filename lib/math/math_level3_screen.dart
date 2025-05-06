import 'package:flutter/material.dart';
import 'package:flutter_application_3/math/math_games/multi_step_equation_game.dart';
import 'package:flutter_application_3/math/math_games/reverse_equation_game.dart';
import 'package:flutter_application_3/math/math_quizes/game_audio_helper.dart';
import 'package:flutter_application_3/math/math_quizes/level3_quiz.dart';
import 'package:flutter_tts/flutter_tts.dart';

class MathLevel3Screen extends StatelessWidget {
  final FlutterTts tts = FlutterTts();

  MathLevel3Screen({super.key});

  void _speak(String text) async {
    await tts.setLanguage("en-US");
    await tts.setPitch(1.0);
    await tts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    _speak("Welcome to Level 3. Let's solve advanced math equations.");

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackButton(color: Colors.black),
        title: Text(
          "Math - Level 3",
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
          _buildGameButton(context, "Solve Multi-Step Equations", () {
            GameAudioHelper.speak(
                "Solve multi-step equations with multiple operations.");
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => MultiStepEquationGame()));
          }),
          _buildGameButton(
              context, "Find the Missing Part in Reverse Equations", () {
            GameAudioHelper.speak(
                "Find the missing part in equations like 18 = x * 3 + 3.");
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => ReverseEquationGame()));
          }),
          Divider(height: 40),
          _buildGameButton(context, "Test What You Learned", () {
            GameAudioHelper.sayStartQuiz();
            Navigator.push(
                context, MaterialPageRoute(builder: (_) => Level3Quiz()));
          }),
        ],
      ),
    );
  }

  Widget _buildGameButton(
      BuildContext context, String title, VoidCallback onTap) {
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
