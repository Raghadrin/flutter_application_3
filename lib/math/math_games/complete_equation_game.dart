import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_fonts/google_fonts.dart';

class CompleteEquationGame extends StatefulWidget {
  const CompleteEquationGame({super.key});

  @override
  State<CompleteEquationGame> createState() => _CompleteEquationGameState();
}

class _CompleteEquationGameState extends State<CompleteEquationGame> {
  final FlutterTts flutterTts = FlutterTts();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final TextEditingController _controller = TextEditingController();

  final List<Map<String, dynamic>> _questions = [
    {
      'parts': [3, '+', 2, '=', 5],
      'hint': [
        {'text': 'hint1'.tr(), 'emoji': '🍊', 'count': 3},
        {'text': 'hint2'.tr(), 'emoji': '🍊', 'count': 2},
        {'text': 'hint3'.tr(), 'emoji': '🍊', 'count': 5},
      ],
    },
    {
      'parts': [8, '-', 3, '=', 5],
      'hint': [
        {'text': 'hint4'.tr(), 'emoji': '🍉', 'count': 8},
        {'text': 'hint5'.tr(), 'emoji': '🍉', 'count': 3},
        {'text': 'hint6'.tr(), 'emoji': '🍉', 'count': 5},
      ],
    },
  ];

  int _currentIndex = 0;
  String feedback = '';
  bool showHint = false;
  bool finished = false;

  @override
  void initState() {
    super.initState();
    _speakInstruction();
  }

  @override
  void dispose() {
    _controller.dispose();
    _audioPlayer.dispose();
    flutterTts.stop();
    super.dispose();
  }

  Future<void> _speakInstruction() async {
    await flutterTts.speak(tr("speak instruction"));
  }

  Future<void> _playCheeringSound() async {
    await _audioPlayer.play(AssetSource('audio/kids_cheering.mp3'));
  }

  Future<void> _checkAnswer() async {
    final userAnswer = _controller.text.trim();
    final correctAnswer = _questions[_currentIndex]['parts'][2].toString();

    if (userAnswer == correctAnswer) {
      setState(() {
        feedback = "🎉 ${tr("great_job")} 🎉";
      });
      await flutterTts.speak(tr("excellent"));
      await Future.delayed(const Duration(milliseconds: 500));
      _nextQuestion();
    } else {
      setState(() {
        feedback = "❌ ${tr("try_again")}";
      });
      await flutterTts.speak(tr("try_again"));
    }
  }

  void _nextQuestion() async {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        feedback = '';
        _controller.clear();
        showHint = false;
      });
      await _speakInstruction();
    } else {
      setState(() {
        finished = true;
      });
      await flutterTts.speak(tr("congrats"));
      await _playCheeringSound();
    }
  }

  void _restartGame() {
    setState(() {
      _currentIndex = 0;
      feedback = '';
      showHint = false;
      finished = false;
      _controller.clear();
    });
    _speakInstruction();
  }

  Future<void> _readFullHint(List<dynamic> hints) async {
    for (var hint in hints) {
      await flutterTts.speak(hint['text']);
      await Future.delayed(const Duration(milliseconds: 600));
    }
  }

  Widget _buildEquationBox(dynamic content) {
    return GestureDetector(
      onTap: () => flutterTts.speak(content.toString()),
      child: Container(
        margin: const EdgeInsets.all(6),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
              color: Color.fromARGB(255, 255, 134, 29),
              blurRadius: 5,
            )
          ],
        ),
        child: Text(
          content.toString(),
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w600,
            fontFamily: 'Arial',
          ),
        ),
      ),
    );
  }

  Widget _buildHintBox(List<dynamic> hints) {
    return Column(
      children: hints.map((hint) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            children: [
              Text(
                List.generate(hint['count'], (_) => hint['emoji']).join(),
                style: const TextStyle(fontSize: 30),
              ),
              Text(
                hint['text'],
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontFamily: 'Arial',
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final current = _questions[_currentIndex];
    final parts = List<dynamic>.from(current['parts']);
    final hints = List<dynamic>.from(current['hint']);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 167, 34),
        title: Text(
          tr("complete_equation"),
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            fontFamily: 'Arial',
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Center(
        child: finished
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "🎉 ${tr("congrats")} 🎉",
                    style: const TextStyle(
                      fontSize: 28,
                      color: Colors.green,
                      fontFamily: 'Arial',
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _restartGame,
                    child: Text(
                      tr("play_again"),
                      style: const TextStyle(
                        fontSize: 20,
                        fontFamily: 'Arial',
                      ),
                    ),
                  ),
                ],
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      tr("Solve Equation"),
                      style: const TextStyle(
                        fontSize: 30,
                        fontFamily: 'Arial',
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 4,
                      runSpacing: 4,
                      children: [
                        _buildEquationBox(parts[0]),
                        _buildEquationBox(parts[1]),
                        _buildEquationBox(' '),
                        _buildEquationBox(parts[3]),
                        _buildEquationBox(parts[4]),
                      ],
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _controller,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 28,
                        fontFamily: 'Arial',
                      ),
                      decoration: InputDecoration(
                        hintText: tr("Enter answer"),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _checkAnswer,
                      child: Text(
                        tr("check answer"),
                        style: const TextStyle(
                          fontSize: 22,
                          fontFamily: 'Arial',
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (feedback.isNotEmpty)
                      Text(
                        feedback,
                        style: GoogleFonts.caladea(
                          fontSize: 24,
                          color: feedback.startsWith('🎉')
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        setState(() => showHint = !showHint);
                        if (showHint) await _readFullHint(hints);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                      ),
                      child: Text(
                        showHint ? tr("hide_hint") : tr("show_hint"),
                        style: GoogleFonts.caladea(fontSize: 20),
                      ),
                    ),
                    if (showHint) _buildHintBox(hints),
                  ],
                ),
              ),
      ),
    );
  }
}
