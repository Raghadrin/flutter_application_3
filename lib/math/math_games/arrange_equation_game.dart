import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:easy_localization/easy_localization.dart';

class ArrangeEquationGame extends StatefulWidget {
  const ArrangeEquationGame({super.key});

  @override
  State<ArrangeEquationGame> createState() => _ArrangeEquationGameState();
}

class _ArrangeEquationGameState extends State<ArrangeEquationGame>
    with TickerProviderStateMixin {
  final FlutterTts flutterTts = FlutterTts();
  final AudioPlayer _audioPlayer = AudioPlayer();

  final List<Map<String, dynamic>> _questions = [
    {
      'parts': ['3', '+', '2', '=', '5'],
      'answer': ['3', '+', '2', '=', '5'],
      'hint': '🍎 Add 3 apples and 2 apples to get 5 apples! 🍏'
    },
    {
      'parts': ['5', '-', '2', '=', '3'],
      'answer': ['5', '-', '2', '=', '3'],
      'hint': '⚽ Start with 5 balls, remove 2 balls ➔ 3 balls remain 🎯'
    },
    {
      'parts': ['8', '-', '3', '=', '5'],
      'answer': ['8', '-', '3', '=', '5'],
      'hint': '🍉 8 watermelons minus 3 gives 5! 🍉'
    },
    {
      'parts': ['6', '+', '4', '=', '10'],
      'answer': ['6', '+', '4', '=', '10'],
      'hint': '🍎 6 apples plus 4 apples make 10! 🍎'
    },
    {
      'parts': ['9', '-', '2', '=', '7'],
      'answer': ['9', '-', '2', '=', '7'],
      'hint': '🚌 9 buses, take away 2, you have 7 left! 🚌'
    },
  ];

  late List<String> _targets;
  late List<String> _shuffledParts;
  int _currentIndex = 0;
  bool finished = false;
  String? feedbackMessage;
  bool showHint = false;

  late AnimationController _feedbackController;
  late Animation<double> _feedbackAnimation;
  late AnimationController _playAgainGlowController;
  late Animation<double> _playAgainGlowAnimation;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _setupQuestion();
    _speakInstruction();
    _feedbackController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _feedbackAnimation = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _feedbackController, curve: Curves.elasticOut));
    _playAgainGlowController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat(reverse: true);
    _playAgainGlowAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
        CurvedAnimation(
            parent: _playAgainGlowController, curve: Curves.easeInOut));
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 4));
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    _playAgainGlowController.dispose();
    _confettiController.dispose();
    flutterTts.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _setupQuestion() {
    _targets = List.filled(_questions[_currentIndex]['parts'].length, '');
    _shuffledParts = List<String>.from(_questions[_currentIndex]['parts'])
      ..shuffle();
  }

  Future<void> _speakInstruction() async {
    await flutterTts.speak(tr("instruction"));
  }

  Future<void> _playCheeringSound() async {
    try {
      await _audioPlayer.play(AssetSource('audio/kids_cheering.mp3'));
    } catch (e) {
      debugPrint("Error playing cheering sound: $e");
    }
  }

  Future<void> _checkAnswer() async {
    if (listEquals(_targets, _questions[_currentIndex]['answer'])) {
      setState(() => feedbackMessage = tr("correct"));
      _feedbackController.forward(from: 0.0);
      await flutterTts.speak("Excellent!");
      await Future.delayed(const Duration(seconds: 2));
      setState(() => feedbackMessage = null);
      _nextQuestion();
    } else {
      setState(() => feedbackMessage = tr("wrong"));
      _feedbackController.forward(from: 0.0);
      await flutterTts.speak("Try again!");
      await Future.delayed(const Duration(seconds: 2));
      setState(() => feedbackMessage = null);
    }
  }

  void _nextQuestion() async {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _setupQuestion();
        showHint = false;
      });
      await _speakInstruction();
    } else {
      setState(() => finished = true);
      _confettiController.play();
      await flutterTts.speak("You did very well!");
      await _playCheeringSound();
    }
  }

  void _restartGame() {
    setState(() {
      finished = false;
      _currentIndex = 0;
      _setupQuestion();
      feedbackMessage = null;
      showHint = false;
    });
    _speakInstruction();
  }

  Widget _dragItem(String e, Color color, double size) => Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
            color: color, borderRadius: BorderRadius.circular(10)),
        child: Text(e,
            style: TextStyle(fontSize: size * 0.45, color: Colors.white)),
      );

  @override
  Widget build(BuildContext context) {
    final current = _questions[_currentIndex];
    final size = MediaQuery.of(context).size;
    final dragSize = size.width * 0.15;
    final buttonFontSize = size.width * 0.05;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange.shade100,
        elevation: 0,
        title: Text(tr("title"),
            style: TextStyle(
                fontSize: size.width * 0.06,
                fontWeight: FontWeight.bold,
                color: Colors.black)),
        centerTitle: true,
        leading: BackButton(color: Colors.black),
      ),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              colors: [Color.fromARGB(255, 255, 255, 255), Color(0xFFFFCC80)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter),
        ),
        child: finished
            ? _buildCelebration(buttonFontSize)
            : SingleChildScrollView(
                child: Column(
                  children: [
                    Text(tr("instruction"),
                        style: TextStyle(
                            fontSize: size.width * 0.055,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(_targets.length, (i) {
                        return DragTarget<String>(
                          onAccept: (data) async {
                            setState(() => _targets[i] = data);
                            await flutterTts.setSpeechRate(
                                data == '+' || data == '-' || data == '='
                                    ? 0.4
                                    : 0.7);
                            await flutterTts.speak(data == '+'
                                ? "plus"
                                : data == '-'
                                    ? "minus"
                                    : data == '='
                                        ? "equals"
                                        : data);
                          },
                          builder: (_, __, ___) => Container(
                            width: dragSize,
                            height: dragSize,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.yellow.shade100,
                              border: Border.all(color: Colors.orange),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(_targets[i],
                                style: TextStyle(fontSize: dragSize * 0.45)),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: _shuffledParts
                          .map((e) => Draggable<String>(
                                data: e,
                                feedback:
                                    _dragItem(e, Colors.orangeAccent, dragSize),
                                childWhenDragging: _dragItem(
                                    e, Colors.grey.shade300, dragSize),
                                child: _dragItem(e, Colors.orange, dragSize),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _checkAnswer,
                      child: Text(tr("check answer"),
                          style: TextStyle(fontSize: buttonFontSize)),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () => setState(() => showHint = !showHint),
                      child: Text(showHint ? tr("hide_hint") : tr("show_hint"),
                          style: TextStyle(fontSize: buttonFontSize)),
                    ),
                    if (showHint)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(current['hint'],
                            style: TextStyle(
                                fontSize: size.width * 0.05,
                                color: Colors.deepOrange)),
                      ),
                    if (feedbackMessage != null)
                      ScaleTransition(
                        scale: _feedbackAnimation,
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            feedbackMessage!,
                            style: TextStyle(
                                fontSize: size.width * 0.07,
                                color: feedbackMessage!.contains("Correct")
                                    ? Colors.green
                                    : Colors.red),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildCelebration(double fontSize) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            numberOfParticles: 30,
          ),
          const SizedBox(height: 30),
          Text(tr("congrats"),
              style: TextStyle(
                  fontSize: fontSize + 8, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          ScaleTransition(
            scale: _playAgainGlowAnimation,
            child: ElevatedButton(
              onPressed: _restartGame,
              child:
                  Text(tr("play_again"), style: TextStyle(fontSize: fontSize)),
            ),
          ),
        ],
      );
}
