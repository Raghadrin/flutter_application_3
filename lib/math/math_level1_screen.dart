import 'package:flutter/material.dart';
import 'package:flutter_application_3/math/math_games/arrange_equation_game.dart';
import 'package:flutter_application_3/math/math_games/complete_equation_game.dart'
    as complete;
import 'package:flutter_application_3/math/math_games/operation_choice_game.dart'
    as operation;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:easy_localization/easy_localization.dart';

class MathLevel1Screen extends StatelessWidget {
  final FlutterTts tts = FlutterTts();

  MathLevel1Screen({super.key});

  void _speak(String text) async {
    await tts.setLanguage("en-US");
    await tts.setPitch(1.0);
    await tts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    _speak(tr("tts_level1_intro"));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackButton(color: Colors.black),
        title: Text(
          tr("math_level1"),
          style: const TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'Arial',
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 30),
          Image.asset("images/subject_fox.jpg", height: 300),
          const SizedBox(height: 30),
          _buildGameButton(context, tr("complete_equation"), () {
            _speak(tr("tts_complete_equation"));
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => complete.CompleteEquationGame()),
            );
          }),
          _buildGameButton(context, tr("choose_operation"), () {
            _speak(tr("tts_choose_operation"));
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => operation.OperationChoiceGame()),
            );
          }),
          _buildGameButton(context, tr("arrange_equation"), () {
            _speak(tr("tts_arrange_equation"));
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ArrangeEquationGame()),
            );
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
          height: 85,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: const LinearGradient(
              colors: [Color(0xFFFBD1B2), Color(0xFFFEE5D3)],
            ),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 8.0), // prevents text overflow
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Arial',
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
