import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class EnglishLevel3QuizAllScreen extends StatefulWidget {
  const EnglishLevel3QuizAllScreen({super.key});

  @override
  State<EnglishLevel3QuizAllScreen> createState() => _EnglishLevel3QuizAllScreenState();
}

class _EnglishLevel3QuizAllScreenState extends State<EnglishLevel3QuizAllScreen> {
  final FlutterTts flutterTts = FlutterTts();
  int currentStep = 0;
  int selectedAnswerIndex = -1;
  bool answered = false;
  int correctAnswers = 0;

  String feedbackMessage = '';
  Color feedbackColor = Colors.transparent;
  IconData? feedbackIcon;

  final String story = "On a beautiful spring day, Sami went to the nearby park with his father. "
      "They brought a basket full of fruits and juices. "
      "Sami played on the swing and laughed a lot, then his friends joined him. "
      "Later, they sat down to eat. "
      "Sami saw birds flying in a V shape in the sky, and asked his father, who told him they were migrating. "
      "Sami smiled and ate his red apple. It was a fun day.";

  final List<Map<String, dynamic>> questions = [
    {
      "question": "What is the title of the story?",
      "options": ["Trip to the beach", "Picnic in the park", "Adventure in the forest"],
      "answerIndex": 1,
    },
    {
      "question": "Who accompanied Sami?",
      "options": ["His friends", "His father", "The teacher"],
      "answerIndex": 1,
    },
    {
      "question": "What was in the food basket?",
      "options": ["Books and juices", "Fruits and sandwiches", "Toys and candy"],
      "answerIndex": 1,
    },
    {
      "question": "What did Sami do first in the park?",
      "options": ["Ran to the swing", "Ate food", "Played with his friends"],
      "answerIndex": 0,
    },
    {
      "question": "What was the park full of?",
      "options": ["Cars", "Children and families", "Books"],
      "answerIndex": 1,
    },
    {
      "question": "What did Sami see in the sky?",
      "options": ["Planes", "Birds in a V shape", "Dark clouds"],
      "answerIndex": 1,
    },
    {
      "question": "What were the birds doing?",
      "options": ["Building nests", "Migrating", "Singing"],
      "answerIndex": 1,
    },
    {
      "question": "What did Sami eat at the end?",
      "options": ["A red apple", "A banana", "A cake"],
      "answerIndex": 0,
    },
  ];

  @override
  void initState() {
    super.initState();
    flutterTts.setLanguage("en-US");
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
              const Text("Final Score", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Text("$scorePercent%", style: const TextStyle(fontSize: 50, color: Colors.deepOrange, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Text(finalMessage, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: msgColor)),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text("Next ⏭️", style: TextStyle(fontSize: 24, color: Colors.white)),
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
        title: const Text("📖 Reading Comprehension Quiz", style: TextStyle(fontSize: 20)),
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
        const Text("Story", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.deepOrange)),
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
                style: const TextStyle(fontSize: 20, height: 1.6, color: Colors.black87),
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
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepOrange)),
          const SizedBox(height: 12),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      current['question'],
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: feedbackColor),
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ],
      ),
    );
  }
}
