import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ArabicLevel3QuizAllScreen extends StatefulWidget {
  const ArabicLevel3QuizAllScreen({super.key});

  @override
  State<ArabicLevel3QuizAllScreen> createState() =>
      _ArabicLevel3QuizAllScreenState();
}

class _ArabicLevel3QuizAllScreenState extends State<ArabicLevel3QuizAllScreen> {
  final FlutterTts flutterTts = FlutterTts();
  int currentStep = 0;
  int selectedAnswerIndex = -1;
  bool answered = false;
  int correctAnswers = 0;

  String feedbackMessage = '';
  Color feedbackColor = Colors.transparent;
  IconData? feedbackIcon;

  final String story =
      "في يوم ربيعي جميل، ذهب سامي مع والده إلى الحديقة القريبة. "
      "أحضرا معهما سلة طعام مليئة بالفاكهة والعصائر. "
      "لعب سامي على الأرجوحة وضحك كثيرًا، ثم انضم إليه أصدقاؤه. "
      "جلسوا لاحقًا لتناول الطعام. "
      "رأى سامي طيورًا تطير في السماء على شكل حرف V، فسأل والده، فأجابه بأنها تهاجر. "
      "ابتسم سامي وأكل تفاحته الحمراء، وكان يومًا ممتعًا.";

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

  Future<void> _saveScore(int score) async {
    try {
      String? parentId = ""; // fetch parentId
      String? childId = ""; // fetch childId

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print("User not logged in");
        return;
      }
      parentId = user.uid;

      final childrenSnapshot = await FirebaseFirestore.instance
          .collection('parents')
          .doc(parentId)
          .collection('children')
          .get();
      if (childrenSnapshot.docs.isNotEmpty) {
        childId = childrenSnapshot.docs.first.id;
      } else {
        print("No children found for this parent.");
        return null;
      }

      if (parentId.isEmpty || childId == null) {
        print("Cannot save score: parentId or childId missing");
        return;
      }

      await FirebaseFirestore.instance
          .collection('parents')
          .doc(parentId)
          .collection('children')
          .doc(childId)
          .collection('arabic')
          .doc('arabic3')
          .collection('attempts') // optional: track multiple attempts
          .add({
        'score': score,
        'timestamp': FieldValue.serverTimestamp(),
      });

      print("Score saved successfully");
    } catch (e) {
      print("Error saving score: $e");
    }
  }

  Future<void> speak(String text) async {
    await flutterTts.stop();
    await flutterTts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    if (currentStep > questions.length) {
      int scorePercent = ((correctAnswers / questions.length) * 100).round();
      String finalMessage;
      Color msgColor;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _saveScore(scorePercent);
      });

      if (scorePercent >= 90) {
        finalMessage = "ممتاز جدًا 🎉";
        msgColor = Colors.green;
      } else if (scorePercent >= 70) {
        finalMessage = "عمل رائع 👏";
        msgColor = Colors.orange;
      } else {
        finalMessage = "أحسنت المحاولة 💪";
        msgColor = Colors.red;
      }

      return Scaffold(
        backgroundColor: Colors.orange[50],
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("النتيجة النهائية",
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Text("$scorePercent%",
                  style: const TextStyle(
                      fontSize: 50,
                      color: Colors.deepOrange,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Text(finalMessage,
                  style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: msgColor)),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text("التالي ⏭️",
                    style: TextStyle(fontSize: 24, color: Colors.white)),
              )
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
        title:
            const Text("📖 كويز الفهم القرائي", style: TextStyle(fontSize: 20)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: isStoryPage ? _buildStoryPage() : _buildQuestionPage(),
      ),
    );
  }

  Widget _buildStoryPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text("القصة",
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.deepOrange)),
        const SizedBox(height: 12),
        SizedBox(
          height: 250,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: SingleChildScrollView(
              child: Text(
                story,
                textAlign: TextAlign.right,
                style: const TextStyle(
                    fontSize: 22, height: 1.8, color: Colors.black87),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          icon: const Icon(Icons.volume_up),
          label: const Text("تشغيل القصة", style: TextStyle(fontSize: 20)),
          onPressed: () => speak(story),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          icon: const Icon(Icons.arrow_forward),
          label: const Text("ابدأ الأسئلة", style: TextStyle(fontSize: 20)),
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

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text("السؤال $currentStep من ${questions.length}",
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrange)),
          const SizedBox(height: 12),
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      current['question'],
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.w600),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.volume_up, size: 28),
                    onPressed: () => speak(current['question']),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          ...List.generate(current['options'].length, (index) {
            final option = current['options'][index];
            final isSelected = selectedAnswerIndex == index;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    selectedAnswerIndex = index;
                    answered = true;
                    if (index == current['answerIndex']) {
                      correctAnswers++;
                      feedbackMessage = "إجابة صحيحة ✅";
                      feedbackColor = Colors.green;
                      feedbackIcon = Icons.check_circle;
                      speak("إجابة صحيحة");
                    } else {
                      feedbackMessage = "إجابة خاطئة ❌";
                      feedbackColor = Colors.red;
                      feedbackIcon = Icons.cancel;
                      speak("إجابة خاطئة");
                    }
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSelected ? Colors.orange : Colors.white,
                  side: const BorderSide(color: Colors.orange, width: 2),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 3,
                ),
                child: Center(
                  child: Text(
                    option,
                    style: TextStyle(
                      fontSize: 20,
                      color: isSelected ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          }),
          if (feedbackMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(feedbackIcon, color: feedbackColor, size: 28),
                  const SizedBox(width: 10),
                  Text(
                    feedbackMessage,
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: feedbackColor),
                  ),
                ],
              ),
            ),
          const Spacer(),
          ElevatedButton.icon(
            icon: const Icon(Icons.arrow_forward),
            label: const Text("التالي", style: TextStyle(fontSize: 20)),
            onPressed: () {
              setState(() {
                currentStep++;
                selectedAnswerIndex = -1;
                answered = false;
                feedbackMessage = '';
                feedbackColor = Colors.transparent;
                feedbackIcon = null;
                if (currentStep <= questions.length) {
                  speak(questions[currentStep - 1]['question']);
                }
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ],
      ),
    );
  }
}
