import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class EnglishLetterQuizScreen extends StatefulWidget {
  const EnglishLetterQuizScreen({super.key});

  @override
  State<EnglishLetterQuizScreen> createState() => _EnglishLetterQuizScreenState();
}

class _EnglishLetterQuizScreenState extends State<EnglishLetterQuizScreen> {
  final FlutterTts flutterTts = FlutterTts();
  int currentIndex = 0;
  int correctAnswers = 0;
  String feedbackMessage = '';
  Color feedbackColor = Colors.transparent;
  IconData? feedbackIcon;

  final List<Map<String, dynamic>> questions = [
  // نوع: position
  {"type": "position", "word": "lamp", "letter": "l", "correctPosition": "beginning"},
  {"type": "position", "word": "piano", "letter": "a", "correctPosition": "middle"},
  {"type": "position", "word": "frog", "letter": "g", "correctPosition": "end"},

  // نوع: letterChoice
  {"type": "letterChoice", "prompt": "Choose the letter A", "correctLetter": "a", "options": ["a", "e", "o", "u"]},
  {"type": "letterChoice", "prompt": "Choose the letter G", "correctLetter": "g", "options": ["k", "g", "h"]},
  {"type": "letterChoice", "prompt": "Choose the letter R", "correctLetter": "r", "options": ["r", "n", "m"]},

  // نوع: missingLetter
  {"type": "missingLetter", "incompleteWord": "_ish", "correctLetter": "f", "options": ["f", "d", "t", "l"]},
  {"type": "missingLetter", "incompleteWord": "do_", "correctLetter": "g", "options": ["g", "t", "n", "b"]},
  {"type": "missingLetter", "incompleteWord": "ca_", "correctLetter": "t", "options": ["t", "p", "r", "n"]},

  // نوع: audioMatch
  {"type": "audioMatch", "audioLetter": "c", "correctLetter": "c", "options": ["s", "c", "k"]},
  {"type": "audioMatch", "audioLetter": "l", "correctLetter": "l", "options": ["l", "n", "r"]},
  {"type": "audioMatch", "audioLetter": "v", "correctLetter": "v", "options": ["v", "b", "w"]},

  // نوع: wordWithLetter
  {"type": "wordWithLetter", "targetLetter": "r", "correctWord": "rain", "options": ["sun", "rain", "dog"]},
  {"type": "wordWithLetter", "targetLetter": "f", "correctWord": "fish", "options": ["bird", "fish", "lion"]},
  {"type": "wordWithLetter", "targetLetter": "m", "correctWord": "moon", "options": ["star", "moon", "sun"]},
];


  @override
  void initState() {
    super.initState();
    _speakQuestion(questions[currentIndex]);
  }

  Future<void> _speakQuestion(Map<String, dynamic> question) async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setSpeechRate(0.4);
    String text = "";
    switch (question["type"]) {
      case "position":
        text = "Where is the letter ${question["letter"]} in the word ${question["word"]}?";
        break;
      case "letterChoice":
        text = question["prompt"];
        break;
      case "missingLetter":
        text = "What is the missing letter in the word ${question["incompleteWord"]}?";
        break;
      case "audioMatch":
        text = "Listen carefully and choose the correct letter.";
        break;
      case "wordWithLetter":
        text = "Choose the word that contains the letter ${question["targetLetter"]}.";
        break;
    }
    await flutterTts.speak(text);
  }

  void checkAnswer(String selected) {
    final q = questions[currentIndex];
    bool isCorrect = false;

    if (q["type"] == "position") {
      isCorrect = selected == q["correctPosition"];
    } else if (["letterChoice", "audioMatch", "missingLetter"].contains(q["type"])) {
      isCorrect = selected == q["correctLetter"];
    } else if (q["type"] == "wordWithLetter") {
      isCorrect = selected == q["correctWord"];
    }

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

        if (currentIndex < questions.length) {
      _speakQuestion(questions[currentIndex]); // أضف هذا السطر لنطق السؤال التالي
    }
      });
    });
  }

  Future<void> _playSound(String letter) async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.speak(letter);
  }

  @override
  Widget build(BuildContext context) {
    if (currentIndex >= questions.length) {
      int scorePercent = ((correctAnswers / questions.length) * 100).round();
      String message;
      Color color;

      if (scorePercent >= 90) {
        message = "🌟 Excellent!";
        color = Colors.green;
      } else if (scorePercent >= 70) {
        message = "👏 Great job!";
        color = Colors.orange;
      } else {
        message = "😅 Try again!";
        color = Colors.red;
      }

      return Scaffold(
        backgroundColor: Colors.orange[50],
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Final Score", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Text("$scorePercent%", style: const TextStyle(fontSize: 60, color: Colors.deepOrange, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Text(message, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: color)),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text("Next ⏭️", style: TextStyle(fontSize: 24, color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    final q = questions[currentIndex];
    return Scaffold(
      backgroundColor: Colors.orange[50],
      appBar: AppBar(
        title: const Text('Letter Quiz', style: TextStyle(fontSize: 26)),
        backgroundColor: Colors.deepOrange,
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildQuestionWidget(q),
              if (feedbackMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(feedbackIcon, color: feedbackColor, size: 32),
                      const SizedBox(width: 10),
                      Text(feedbackMessage, style: TextStyle(fontSize: 24, color: feedbackColor, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionWidget(Map<String, dynamic> q) {
    switch (q["type"]) {
      case "position":
        return _buildChoiceQuestion("Where is the letter '${q['letter']}' in the word '${q['word']}'?", ["beginning", "middle", "end"]);
      case "letterChoice":
        return _buildChoiceQuestion(q["prompt"], q["options"]);
      case "missingLetter":
        return _buildChoiceQuestion("What is the missing letter in: ${q["incompleteWord"]}", q["options"]);
      case "audioMatch":
        return Column(
          children: [
            const Text("🎧 Listen and choose the letter", style: TextStyle(fontSize: 24)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _playSound(q["audioLetter"]),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amberAccent, padding: const EdgeInsets.all(16)),
              child: const Icon(Icons.volume_up, size: 40),
            ),
            const SizedBox(height: 20),
            _answerButtons(q["options"]),
          ],
        );
      case "wordWithLetter":
        return _buildChoiceQuestion("Choose the word that has the letter '${q["targetLetter"]}'", q["options"]);
      default:
        return const Text("Unknown question");
    }
  }

  Widget _buildChoiceQuestion(String question, List options) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.orange, width: 3),
          ),
          child: Column(
            children: [
              Text("Question ${currentIndex + 1}", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.deepOrange)),
              const SizedBox(height: 10),
              Text(question, textAlign: TextAlign.center, style: const TextStyle(fontSize: 24)),
            ],
          ),
        ),
        _answerButtons(options),
      ],
    );
  }

  Widget _answerButtons(List options) {
    return Wrap(
      spacing: 20,
      runSpacing: 20,
      alignment: WrapAlignment.center,
      children: options.map<Widget>((opt) {
        return ElevatedButton(
          onPressed: () => checkAnswer(opt),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            minimumSize: const Size(140, 60),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: Text(opt, style: const TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold)),
        );
      }).toList(),
    );
  }
}
