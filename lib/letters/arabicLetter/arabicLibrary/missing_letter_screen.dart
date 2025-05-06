import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class MissingTashkeelScreen extends StatefulWidget {
  const MissingTashkeelScreen({super.key});

  @override
  _MissingTashkeelScreenState createState() => _MissingTashkeelScreenState();
}

class _MissingTashkeelScreenState extends State<MissingTashkeelScreen> {
  int currentQuestion = 0;
  String feedbackMessage = '';
  Color feedbackColor = Colors.transparent;
  final player = AudioPlayer();

  final List<TashkeelQuestion> questions = [
    TashkeelQuestion(sentenceWithGap: 'كـ _ ـتبَ الولدُ الدرسَ', correctHaraka: 'َ', options: ['َ', 'ُ', 'ِ']),
    TashkeelQuestion(sentenceWithGap: 'الــباب_ مفتوح', correctHaraka: 'ُ', options: ['َ', 'ُ', 'ِ']),
    TashkeelQuestion(sentenceWithGap: '_يلعبُ أحمدُ في الحديقة', correctHaraka: 'ِ', options: ['َ', 'ُ', 'ِ']),
    TashkeelQuestion(sentenceWithGap: 'الطـ _ ـفلُ يأكلُ التفاحةَ', correctHaraka: 'ِ', options: ['ِ', 'َ', 'ُ']),
    TashkeelQuestion(sentenceWithGap: 'ذهـ _ ـبَتْ فاطمةُ إلى المدرسةِ', correctHaraka: 'َ', options: ['َ', 'ُ', 'ْ']),
    TashkeelQuestion(sentenceWithGap: 'رأى خالدٌ الــقمر- في السماءِ', correctHaraka: 'َ', options: ['َ', 'ِ', 'ُ']),
    TashkeelQuestion(sentenceWithGap: 'المُعلمُ يــشرحُ الدرسَ جيد_ا', correctHaraka: 'دً', options: ['ِد', 'دً', 'ُدن']),
    TashkeelQuestion(sentenceWithGap: 'اللـ _ ـعبُ في الخارجِ ممتعٌ', correctHaraka: 'َّ', options: ['َّ', 'ُ', 'ِ']),
    TashkeelQuestion(sentenceWithGap: 'الـ _ ـطُ يجلسُ على السريرِ', correctHaraka: 'قِ', options: ['قَ', 'قِ', 'قُ']),
    TashkeelQuestion(sentenceWithGap: 'قـ _ ـرأَ سامي كتابًا جديدًا', correctHaraka: 'َ', options: ['َ', 'ُ', 'ِ']),
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
        title: const Text('✍️ ضع الحركة المناسبة', style: TextStyle(fontSize: 24)),
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

class TashkeelQuestion {
  final String sentenceWithGap;
  final String correctHaraka;
  final List<String> options;

  TashkeelQuestion({
    required this.sentenceWithGap,
    required this.correctHaraka,
    required this.options,
  });
}
