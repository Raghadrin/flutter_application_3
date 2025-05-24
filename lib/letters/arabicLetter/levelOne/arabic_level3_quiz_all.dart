
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class ArabicLevel3QuizAllScreen extends StatefulWidget {
  const ArabicLevel3QuizAllScreen({super.key});

  @override
  State<ArabicLevel3QuizAllScreen> createState() => _ArabicLevel3QuizAllScreenState();
}

class _ArabicLevel3QuizAllScreenState extends State<ArabicLevel3QuizAllScreen> {
  final FlutterTts flutterTts = FlutterTts();
  int currentStep = 0;
  int selectedAnswerIndex = -1;
  bool answered = false;
  int correctAnswers = 0;

  final String story = "في صباح مشمس من أيام الربيع، قرر سامي أن يذهب مع والده في نزهة إلى الحديقة العامة القريبة من منزلهم. "
      "جهزوا سلة الطعام التي كانت مليئة بالفاكهة والعصائر والسندويشات اللذيذة، ثم انطلقوا بسعادة. عندما وصلا، كانت الحديقة تعج بالأطفال والعائلات، وكانت الطيور تزقزق فوق الأشجار. "
      "ركض سامي نحو أرجوحة كبيرة وبدأ يتأرجح عاليًا وهو يضحك. انضم إليه أصدقاؤه لاحقًا، فلعبوا معًا لعبة الغميضة وتسابقوا بين الأشجار. "
      "بعد اللعب، جلسوا جميعًا على البطانية التي فرشها والده، وبدأوا يتناولون الطعام وهم يتحدثون عن ألعابهم المدرسية. "
      "وبينما كانوا يأكلون، لاحظ سامي طيورًا كثيرة تحلق في السماء على شكل حرف V، فسأل والده عنها، فأجابه بأن هذه الطيور تهاجر مع تغير الفصول. "
      "ابتسم سامي وأكمل تناول تفاحته الحمراء بينما كانت الشمس تغرب ببطء، لتختتم يومًا مليئًا بالمرح والمعرفة.";

  final List<Map<String, dynamic>> questions = [
    {
      "question": "ما عنوان القصة؟",
      "options": ["رحلة إلى البحر", "نزهة في الحديقة", "مغامرة في الغابة"],
      "answerIndex": 1,
    },
    {
      "question": "من كان يرافق سامي؟",
      "options": ["أصدقاؤه", "والده", "المعلم"],
      "answerIndex": 1,
    },
    {
      "question": "ماذا كانت تحتوي سلة الطعام؟",
      "options": ["كتب والعصائر", "فاكهة وسندويشات", "لعب وحلوى"],
      "answerIndex": 1,
    },
    {
      "question": "ماذا فعل سامي أولاً عندما وصل الحديقة؟",
      "options": ["ركض نحو الأرجوحة", "تناول الطعام", "لعب مع أصدقائه"],
      "answerIndex": 0,
    },
    {
      "question": "بماذا كانت الحديقة تعج؟",
      "options": ["السيارات", "الأطفال والعائلات", "الكتب"],
      "answerIndex": 1,
    },
    {
      "question": "ماذا شاهد سامي في السماء؟",
      "options": ["طائرات", "طيور بشكل V", "غيوم سوداء"],
      "answerIndex": 1,
    },
    {
      "question": "ماذا كانت تفعل الطيور؟",
      "options": ["تبني أعشاشًا", "تهاجر", "تغني"],
      "answerIndex": 1,
    },
    {
      "question": "ماذا أكل سامي في نهاية القصة؟",
      "options": ["تفاحة حمراء", "موزة", "كعكة"],
      "answerIndex": 0,
    },
  ];

  @override
  void initState() {
    super.initState();
    flutterTts.setLanguage("ar-SA");
  }

  Future<void> speak(String text) async {
    await flutterTts.stop();
    await flutterTts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    if (currentStep > questions.length) {
      int scorePercent = ((correctAnswers / questions.length) * 100).round();
      return Scaffold(
        backgroundColor: const Color(0xFFFFF8E1),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("🎉 أحسنت!", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Text("لقد حصلت على: $scorePercent%",
                  style: const TextStyle(fontSize: 22, color: Colors.brown)),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                icon: const Icon(Icons.replay),
                label: const Text("إعادة الكويز", style: TextStyle(fontSize: 20)),
                onPressed: () {
                  setState(() {
                    currentStep = 0;
                    correctAnswers = 0;
                    selectedAnswerIndex = -1;
                    answered = false;
                  });
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              ),
            ],
          ),
        ),
      );
    }

    final isStoryPage = currentStep == 0;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      appBar: AppBar(
        backgroundColor: Colors.orange,
        centerTitle: true,
        title: const Text("📖 كويز الفهم القرائي", style: TextStyle(fontSize: 20)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: isStoryPage ? _buildStoryPage() : _buildQuestionPage(),
      ),
    );
  }

  Widget _buildStoryPage() {
    return Column(
      children: [
        const Text("القصة", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepOrange)),
        const SizedBox(height: 16),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: SingleChildScrollView(
              child: Text(
                story,
                textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 18, height: 1.6),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          icon: const Icon(Icons.volume_up),
          label: const Text("تشغيل القصة", style: TextStyle(fontSize: 18)),
          onPressed: () => speak(story),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          icon: const Icon(Icons.arrow_forward),
          label: const Text("ابدأ الأسئلة", style: TextStyle(fontSize: 18)),
          onPressed: () {
            setState(() {
              currentStep = 1;
            });
            speak(questions[0]['question']);
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
        ),
      ],
    );
  }

  Widget _buildQuestionPage() {
    final current = questions[currentStep - 1];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("${currentStep}/${questions.length}", style: const TextStyle(fontSize: 16, color: Colors.grey)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Text(current['question'], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            IconButton(
              icon: const Icon(Icons.volume_up),
              onPressed: () => speak(current['question']),
            )
          ],
        ),
        const SizedBox(height: 20),
        ...List.generate(current['options'].length, (index) {
          final option = current['options'][index];
          final isSelected = selectedAnswerIndex == index;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isSelected ? Colors.orange.shade300 : Colors.orange.shade100,
                minimumSize: const Size.fromHeight(50),
              ),
              onPressed: () {
                setState(() {
                  selectedAnswerIndex = index;
                  answered = true;
                });
              },
              child: Text(option, style: const TextStyle(fontSize: 18)),
            ),
          );
        }),
        const Spacer(),
        ElevatedButton.icon(
          icon: const Icon(Icons.arrow_forward),
          label: const Text("التالي", style: TextStyle(fontSize: 18)),
          onPressed: () {
            if (selectedAnswerIndex == current['answerIndex']) {
              correctAnswers++;
            }
            setState(() {
              currentStep++;
              selectedAnswerIndex = -1;
              answered = false;
              if (currentStep <= questions.length) {
                speak(questions[currentStep - 1]['question']);
              }
            });
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
        ),
      ],
    );
  }
}
