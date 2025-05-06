import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class HamzatGameScreen extends StatefulWidget {
  const HamzatGameScreen({super.key});

  @override
  _HamzatGameScreenState createState() => _HamzatGameScreenState();
}

class _HamzatGameScreenState extends State<HamzatGameScreen> {
  int currentQuestion = 0;
  String feedbackMessage = '';
  Color feedbackColor = Colors.transparent;
  final player = AudioPlayer();

 final List<HamzaQuestion> questions = [
  HamzaQuestion(sentenceWithGap: 'فَ_ ادُ يحبُّ المدرسة', correctHaraka: 'ؤ', options: ['و', 'ؤ', 'وء']),
  HamzaQuestion(sentenceWithGap: 'الماءُ داف_ في الصيف', correctHaraka: 'ئ', options: ['ئ', 'ا', 'أ']),
  HamzaQuestion(sentenceWithGap: 'أقر_ كتاباً عن الفضاء.', correctHaraka: 'أ', options: ['ا', 'إ', 'أ']),
  HamzaQuestion(sentenceWithGap: 'التَّفا_لُ مفتاحُ النَّجاح', correctHaraka: 'ؤ', options: ['و', 'ؤ', 'وُ']),
  HamzaQuestion(sentenceWithGap: 'ما _ سمك؟', correctHaraka: 'ا', options: ['أ', 'ا', 'إ']),
  HamzaQuestion(sentenceWithGap: 'ضو_ الشمس ساطع', correctHaraka: 'ء', options: ['أ', 'ء', 'ؤ']),
 ];


  void checkAnswer(String selectedHaraka) async {
    bool isCorrect = selectedHaraka == questions[currentQuestion].correctHaraka;

    setState(() {
      feedbackMessage = isCorrect ? '✅ إجابة صحيحة' : '❌ إجابة خاطئة';
      feedbackColor = isCorrect ? Colors.green : Colors.red;
    });

    if (isCorrect) {
      await player.play(AssetSource('correct.mp3'));
      Future.delayed(const Duration(seconds: 2), () {
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
              title: const Text('🎉 أحسنت!'),
              content: const Text('لقد أكملت التمارين بنجاح!'),
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
                  child: const Text('🔁 إعادة'),
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
      backgroundColor: const Color(0xFFF0FAF8),
      appBar: AppBar(
        title: const Text('✍️ ضع الهمزة المناسبة', style: TextStyle(fontSize: 24)),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
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
                  color: Colors.teal,
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
                  children: question.options.map((haraka) {
                    return ElevatedButton(
                      onPressed: () => checkAnswer(haraka),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal.shade400,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        haraka,
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
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: feedbackColor,
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class HamzaQuestion {
  final String sentenceWithGap;
  final String correctHaraka;
  final List<String> options;

  HamzaQuestion({
    required this.sentenceWithGap,
    required this.correctHaraka,
    required this.options,
  });
}
