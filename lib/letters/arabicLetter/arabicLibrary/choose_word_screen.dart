import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class ChoosePunctuationScreen extends StatefulWidget {
  const ChoosePunctuationScreen({super.key});

  @override
  _ChoosePunctuationScreenState createState() => _ChoosePunctuationScreenState();
}

class _ChoosePunctuationScreenState extends State<ChoosePunctuationScreen> {
  int currentQuestion = 0;
  String feedbackMessage = '';
  Color feedbackColor = Colors.transparent;
  final player = AudioPlayer();

  final List<PunctuationQuestion> questions = [
    PunctuationQuestion(
      sentenceWithGap: '_ كيف حالك ',
      correctMark: '؟',
      options: ['.', '؟', '!'],
    ),
    PunctuationQuestion(
      sentenceWithGap: '.أنا أحب القراءة _ الرسم _ والموسيقى',
      correctMark: '،',
      options: ['،', '.', '؟'],
    ),
    PunctuationQuestion(
      sentenceWithGap: '_  ما اجمل السماء ',
      correctMark: '!',
      options: ['.', '؟', '!'],
    ),
    PunctuationQuestion(
      sentenceWithGap: '.ذهبت إلى المدرسة _ ثم إلى المكتبة',
      correctMark: '،',
      options: ['،', '؟', '.'],
    ),
    PunctuationQuestion(
      sentenceWithGap: '_ ما اسمك ',
      correctMark: '؟',
      options: ['؟', '.', '!'],
    ),
  ];

  void checkAnswer(String selectedMark) async {
    bool isCorrect = selectedMark == questions[currentQuestion].correctMark;

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
        } else {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('أحسنت!'),
              content: Text('لقد أكملت جميع التمارين 🎉'),
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
                  child: Text('إعادة التمرين'),
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
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'اختر علامة الترقيم',
          style: TextStyle(fontSize: 24),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 8),
                ],
              ),
              child: Text(
                question.sentenceWithGap,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
            ),
            const SizedBox(height: 40),
            Expanded(
              child: Center(
                child: Wrap(
                  spacing: 20,
                  runSpacing: 20,
                  alignment: WrapAlignment.center,
                  children: question.options.map((mark) {
                    return ElevatedButton(
                      onPressed: () => checkAnswer(mark),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurpleAccent,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        mark,
                        style: const TextStyle(fontSize: 30, color: Colors.white),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              feedbackMessage,
              style: TextStyle(
                color: feedbackColor,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class PunctuationQuestion {
  final String sentenceWithGap;
  final String correctMark;
  final List<String> options;

  PunctuationQuestion({
    required this.sentenceWithGap,
    required this.correctMark,
    required this.options,
  });
}
