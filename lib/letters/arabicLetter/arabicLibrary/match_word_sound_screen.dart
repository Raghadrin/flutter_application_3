import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class MatchWordSoundScreen extends StatefulWidget {
  const MatchWordSoundScreen({super.key});

  @override
  _MatchWordSoundScreenState createState() => _MatchWordSoundScreenState();
}

class _MatchWordSoundScreenState extends State<MatchWordSoundScreen> {
  int currentQuestion = 0;
  String feedbackMessage = '';
  Color feedbackColor = Colors.transparent;
  final player = AudioPlayer();

  final List<SoundQuestion> questions = [
    SoundQuestion(
      soundPath: 'sounds/apple.mp3',
      correctWord: 'تُفاحةٌ',
      options: ['تُفاحةٌ', 'تِفاحةٍ', 'تَفاحةً'],
    ),
    SoundQuestion(
      soundPath: 'sounds/car.mp3',
      correctWord: 'سَيارةٌ',
      options: ['سَيارةٌ', 'سِيارةٍ', 'سُيارةُ'],
    ),
    SoundQuestion(
      soundPath: 'sounds/kitab.mp3',
      correctWord: 'كِتابً',
      options: ['كِتابً', 'كُتابً', 'كَتابُ'],
    ),
  ];

  void playSound() {
    player.stop();
    player.play(AssetSource(questions[currentQuestion].soundPath));
  }

  void checkAnswer(String selectedWord) async {
    bool isCorrect = selectedWord == questions[currentQuestion].correctWord;

    setState(() {
      feedbackMessage = isCorrect ? 'إجابة صحيحة ✅' : 'إجابة خاطئة ❌';
      feedbackColor = isCorrect ? Colors.green : Colors.red;
    });

    if (isCorrect) {
      await player.play(AssetSource('correct.mp3'));

      Future.delayed(Duration(seconds: 2), () {
        if (currentQuestion < questions.length - 1) {
          setState(() {
            currentQuestion++;
            feedbackMessage = '';
            feedbackColor = Colors.transparent;
          });
          playSound();
        } else {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(
                'رائع!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              content: Text(
                'أكملت جميع التمارين بنجاح 🎉',
                style: TextStyle(fontSize: 20),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      currentQuestion = 0;
                      feedbackMessage = '';
                      feedbackColor = Colors.transparent;
                    });
                  },
                  child: Text(
                    'إعادة',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          );
        }
      });
    } else {
      await player.play(AssetSource('wrong.mp3'));
    }
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final question = questions[currentQuestion];

    return Scaffold(
      backgroundColor: const Color(0xFFFFF6ED),
      appBar: AppBar(
        title: Text(
          'مطابقة الكلمة بالصوت',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.orangeAccent,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: playSound,
                icon: Icon(Icons.volume_up, size: 30),
                label: Text(
                  'استمع للكلمة',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.orange,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              SizedBox(height: 40),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: question.options.map((word) {
                  return ElevatedButton(
                    onPressed: () => checkAnswer(word),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blueAccent,
                      padding:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      word,
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 40),
              Text(
                feedbackMessage,
                style: TextStyle(
                  color: feedbackColor,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SoundQuestion {
  final String soundPath;
  final String correctWord;
  final List<String> options;

  SoundQuestion({
    required this.soundPath,
    required this.correctWord,
    required this.options,
  });
}
