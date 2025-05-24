import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class EnglishLevel2WordQuizScreen extends StatefulWidget {
  const EnglishLevel2WordQuizScreen({super.key});

  @override
  State<EnglishLevel2WordQuizScreen> createState() => _EnglishLevel2WordQuizScreenState();
}

class _EnglishLevel2WordQuizScreenState extends State<EnglishLevel2WordQuizScreen> {
  final FlutterTts flutterTts = FlutterTts();
  int currentIndex = 0;
  int correctAnswers = 0;
  String feedbackMessage = '';
  Color feedbackColor = Colors.transparent;
  IconData? feedbackIcon;

  final List<Map<String, dynamic>> questions = [
    {
      "type": "sentenceChoice",
      "question": "Choose the sentence that has the word 'apple'",
      "correct": "Laila ate a red apple.",
      "options": [
        "Ahmad went to the market.",
        "Laila ate a red apple.",
        "Sami played in the park."
      ]
    },
    {
      "type": "synonymChoice",
      "question": "What is a synonym of 'happy'?",
      "correct": "Joyful",
      "options": ["Joyful", "Hungry", "Angry"]
    },
    {
      "type": "oppositeChoice",
      "question": "What is the opposite of 'big'?",
      "correct": "Small",
      "options": ["Tall", "Small", "Old"]
    },
    {
      "type": "categoryChoice",
      "question": "Which word belongs to the category 'fruits'?",
      "correct": "Apple",
      "options": ["Apple", "Pen", "Door"]
    },
    {
      "type": "audioWord",
      "sound": "apple",
      "correct": "Apple",
      "options": ["Apple", "Banana", "Orange"],
    },
    {
      "type": "missingWord",
      "sentence": "Sami ate a       red fruit.",
      "correct": "Apple",
      "options": ["Banana", "Apple", "Apples"],
    },
    {
      "type": "wordWithLetter",
      "letter": "s",
      "correct": "Sun",
      "options": ["Apple", "Sun", "Pen"],
    },
  ];

  @override
  void initState() {
    super.initState();
    _speakQuestion();
  }

  Future<void> _speakQuestion() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setSpeechRate(0.4);
    final q = questions[currentIndex];
    String text = "";
    switch (q['type']) {
      case "sentenceChoice":
      case "synonymChoice":
      case "oppositeChoice":
      case "categoryChoice":
        text = q['question'];
        break;
      case "audioWord":
        text = "Listen then choose the correct word";
        break;
      case "missingWord":
        text = "What is the missing word in the sentence: ${q['sentence']}";
        break;
      case "wordWithLetter":
        text = "Choose a word that contains the letter ${q['letter']}";
        break;
    }
    await flutterTts.speak(text);
  }

  void checkAnswer(String selected) {
    final q = questions[currentIndex];
    bool isCorrect = selected == q['correct'];

    setState(() {
      if (isCorrect) {
        correctAnswers++;
        feedbackMessage = "🎉 Correct!";
        feedbackColor = Colors.green;
        feedbackIcon = Icons.check_circle;
        flutterTts.speak("Correct answer");
      } else {
        feedbackMessage = "❌ Wrong!";
        feedbackColor = Colors.red;
        feedbackIcon = Icons.cancel;
        flutterTts.speak("Wrong answer");
      }
    });

    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        currentIndex++;
        feedbackMessage = '';
        feedbackColor = Colors.transparent;
        feedbackIcon = null;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (feedbackMessage == '' && currentIndex < questions.length) {
        _speakQuestion();
      }
    });

    if (currentIndex >= questions.length) {
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
              Text("$scorePercent%",
                  style: const TextStyle(fontSize: 50, color: Colors.deepOrange, fontWeight: FontWeight.bold)),
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

    final q = questions[currentIndex];
    return Scaffold(
      backgroundColor: Colors.orange[50],
      appBar: AppBar(
        title: const Text('Word Quiz - Level 2', style: TextStyle(fontSize: 26)),
        backgroundColor: Colors.deepOrange,
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6)],
                ),
                child: Column(
                  children: [
                    Text(
                      "Question ${currentIndex + 1} of ${questions.length}",
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepOrange),
                    ),
                    const SizedBox(height: 12),
                    if (q['type'] == 'missingWord')
                      Text(q['sentence'], style: const TextStyle(fontSize: 24))
                    else if (q['type'] == 'wordWithLetter')
                      Text("🔠 Choose a word with '${q['letter']}'", style: const TextStyle(fontSize: 24))
                    else if (q['type'] == 'audioWord')
                      Column(
                        children: [
                          const Text("🎧 Tap to listen", style: TextStyle(fontSize: 24)),
                          IconButton(
                            icon: const Icon(Icons.volume_up, size: 40),
                            onPressed: () => flutterTts.speak(q['sound']),
                          )
                        ],
                      )
                    else if (q.containsKey('question'))
                      Text(q['question'], style: const TextStyle(fontSize: 24)),
                    _readButton(),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ...q['options'].map<Widget>((opt) => _answerButton(opt)).toList(),
              if (feedbackMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(feedbackIcon, color: feedbackColor, size: 32),
                      const SizedBox(width: 10),
                      Text(
                        feedbackMessage,
                        style: TextStyle(fontSize: 24, color: feedbackColor, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _readButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: ElevatedButton.icon(
        onPressed: _speakQuestion,
        icon: const Icon(Icons.volume_up),
        label: const Text("Read the question", style: TextStyle(fontSize: 20)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepOrange,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
    );
  }

  Widget _answerButton(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ElevatedButton(
        onPressed: () => checkAnswer(text),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          elevation: 4,
        ),
        child: Container(
          width: double.infinity,
          alignment: Alignment.center,
          child: Text(
            text,
            style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
