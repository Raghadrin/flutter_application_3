import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EnglishLevel3QuizAllScreen extends StatefulWidget {
  const EnglishLevel3QuizAllScreen({super.key});

  @override
  State<EnglishLevel3QuizAllScreen> createState() =>
      _EnglishLevel3QuizAllScreenState();
}

class _EnglishLevel3QuizAllScreenState
    extends State<EnglishLevel3QuizAllScreen> {
  final FlutterTts flutterTts = FlutterTts();
  int currentStep = 0;
  int selectedAnswerIndex = -1;
  bool answered = false;
  int correctAnswers = 0;

  String feedbackMessage = '';
  Color feedbackColor = Colors.transparent;
  IconData? feedbackIcon;
  final String story =
      "One rainy afternoon, Emma heard a soft meow outside her window. "
      "She opened the door and saw a tiny kitten shivering on the porch. "
      "Emma quickly brought it inside, dried its fur, and gave it warm milk. "
      "She made posters and asked her neighbors if they lost a kitten. "
      "Two days later, a boy named Alex came and said it was his. "
      "Emma smiled and gave the kitten back. Alex thanked her, and they became good friends.";

  final List<Map<String, dynamic>> questions = [
    {
      "question": "What did Emma hear?",
      "options": ["A knock on the door", "A soft meow", "Thunder"],
      "answerIndex": 1,
    },
    {
      "question": "Where was the kitten when Emma found it?",
      "options": ["In the garden", "On her bed", "On the porch"],
      "answerIndex": 2,
    },
    {
      "question": "What did Emma give to the kitten?",
      "options": ["Water", "Milk", "Bread"],
      "answerIndex": 1,
    },
    {
      "question": "What did Emma do to find the kitten’s owner?",
      "options": ["Posted online", "Made posters", "Called the police"],
      "answerIndex": 1,
    },
    {
      "question": "Who claimed the kitten after two days?",
      "options": ["Her friend Lily", "A boy named Alex", "Her neighbor's dog"],
      "answerIndex": 1,
    },
    {
      "question": "What happened after Emma gave the kitten back?",
      "options": ["They became friends", "She cried", "Alex left silently"],
      "answerIndex": 0,
    },
  ];

  @override
  void initState() {
    super.initState();
    flutterTts.setLanguage("en-US");
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
          .collection('english')
          .doc('english3')
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
        finalMessage = "Excellent 🎉";
        msgColor = Colors.green;
      } else if (scorePercent >= 70) {
        finalMessage = "Great job 👏";
        msgColor = Colors.orange;
      } else {
        finalMessage = "Nice try 💪";
        msgColor = Colors.red;
      }

      return Scaffold(
        backgroundColor: Colors.orange[50],
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Final Score",
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
                child: const Text("Next ⏭️",
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
        title: const Text("📖 Reading Comprehension Quiz",
            style: TextStyle(fontSize: 20)),
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
        const Text("Story",
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
                textAlign: TextAlign.left,
                style: const TextStyle(
                    fontSize: 20, height: 1.6, color: Colors.black87),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          icon: const Icon(Icons.volume_up),
          label: const Text("Play Story", style: TextStyle(fontSize: 20)),
          onPressed: () => speak(story),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          icon: const Icon(Icons.arrow_forward),
          label: const Text("Start Quiz", style: TextStyle(fontSize: 20)),
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
          Text("Question $currentStep of ${questions.length}",
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
                      feedbackMessage = "Correct ✅";
                      feedbackColor = Colors.green;
                      feedbackIcon = Icons.check_circle;
                      speak("Correct");
                    } else {
                      feedbackMessage = "Wrong ❌";
                      feedbackColor = Colors.red;
                      feedbackIcon = Icons.cancel;
                      speak("Wrong");
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
            label: const Text("Next", style: TextStyle(fontSize: 20)),
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
