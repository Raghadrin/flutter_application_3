import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:reorderables/reorderables.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class EnglishComprehensiveQuizScreen extends StatefulWidget {
  const EnglishComprehensiveQuizScreen({super.key});

  @override
  State<EnglishComprehensiveQuizScreen> createState() => _EnglishComprehensiveQuizScreenState();
}

class _EnglishComprehensiveQuizScreenState extends State<EnglishComprehensiveQuizScreen> {
  late FlutterTts flutterTts;
  late stt.SpeechToText speech;
  Timer? countdownTimer;
  int remainingSeconds = 180;
  List<String> userOrder = [];

  final List<Map<String, dynamic>> questions = [
    {'type': 'speak', 'prompt': 'Say the word: strategy', 'answer': 'strategy'},
    {'type': 'reorder', 'prompt': 'Reorder the sentence: [the, sun, rises, in, the, east]', 'answer': 'the sun rises in the east'},
    {'type': 'choice', 'prompt': 'Why do students visit the museum?', 'options': ['To learn history', 'To buy gifts', 'To relax'], 'answer': 'To learn history'},
    {'type': 'yesno', 'prompt': 'Does the sentence "The student went to school early" contain a verb?', 'answer': 'Yes'},
    {'type': 'speak', 'prompt': 'Read the sentence: The sun shines in the morning.', 'answer': 'The sun shines in the morning'},
    {'type': 'choice', 'prompt': 'What is the synonym of "loyalty"?', 'options': ['Faithfulness', 'Forgetfulness', 'Deception'], 'answer': 'Faithfulness'},
    {'type': 'reorder', 'prompt': 'Reorder the sentence: [we, should, protect, the, environment]', 'answer': 'we should protect the environment'},
    {'type': 'choice', 'prompt': 'Which sentence is grammatically correct?', 'options': ['She play in the park', 'He ate the apple', 'They was going home'], 'answer': 'He ate the apple'},
  ];

  int currentIndex = 0;
  int score = 0;
  bool isListening = false;
  String recognizedText = '';
  String? selectedOption;
  String? selectedYesNo;
  List<Map<String, dynamic>> answerLog = [];

  @override
  bool showStartScreen = true;

  void initState() {
    super.initState();
    flutterTts = FlutterTts();
    flutterTts.setLanguage("en-US");
    flutterTts.setSpeechRate(0.4);
    speech = stt.SpeechToText();
    startTimer();
    if (questions.first['type'] == 'reorder') prepareReorder();
  }

  @override
  void dispose() {
    countdownTimer?.cancel();
    flutterTts.stop();
    super.dispose();
  }

  void startTimer() {
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (remainingSeconds > 0) {
        setState(() => remainingSeconds--);
      } else {
        timer.cancel();
        showResult();
      }
    });
  }

  void prepareReorder() {
    userOrder = questions[currentIndex]['answer'].toString().split(' ');
    userOrder.shuffle();
  }

  void onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final item = userOrder.removeAt(oldIndex);
      userOrder.insert(newIndex, item);
    });
  }

  Future<void> speak(String text) async {
    await flutterTts.stop();
    await flutterTts.speak(text);
  }

  Future<void> startListening() async {
    bool available = await speech.initialize();
    if (!available) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Speech recognition not available')));
      return;
    }
    setState(() {
      isListening = true;
      recognizedText = '';
    });
    speech.listen(
      localeId: 'en_US',
      listenMode: stt.ListenMode.dictation,
      partialResults: false,
      onResult: (val) => setState(() => recognizedText = val.recognizedWords),
    );
  }

  Future<void> stopListening() async {
    await speech.stop();
    setState(() => isListening = false);
    validateAnswer();
  }

  
  void validateAnswer() {
    final question = questions[currentIndex];
    final correct = question['answer'].toString().trim();
    bool isCorrect = false;
    String userAnswer = '';

    if (question['type'] == 'speak') {
      userAnswer = recognizedText.trim();
      isCorrect = normalize(userAnswer).contains(normalize(correct));
    } else if (question['type'] == 'choice') {
      userAnswer = selectedOption ?? '';
      isCorrect = selectedOption == correct;
    } else if (question['type'] == 'yesno') {
      userAnswer = selectedYesNo ?? '';
      isCorrect = selectedYesNo == correct;
    } else if (question['type'] == 'reorder') {
      userAnswer = userOrder.join(' ');
      isCorrect = normalize(userAnswer) == normalize(correct);
    }

    answerLog.add({
      'prompt': question['prompt'],
      'yourAnswer': userAnswer,
      'correctAnswer': correct,
      'correct': isCorrect
    });

    if (isCorrect) {
      score++;
      ();
      speak('Great job!');
      speak('Correct answer!');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.close, color: Color(0xFFF44336), size: 28),
              SizedBox(width: 10),
              Text('Wrong!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFF44336)))
            ],
          ),
          backgroundColor: Color(0xFFFFEBEE),
          duration: Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
        ),
      );
      speak('Wrong answer');
    }

    Future.delayed(const Duration(seconds: 2), nextQuestion);
  }

  void nextQuestion() {
    if (currentIndex < questions.length - 1) {
      setState(() {
        currentIndex++;
        recognizedText = '';
        selectedOption = null;
        selectedYesNo = null;
        if (questions[currentIndex]['type'] == 'reorder') prepareReorder();
      });
    } else {
      countdownTimer?.cancel();
      showResult();
    }
  }

  void restartQuiz() {
    setState(() {
      currentIndex = 0;
      score = 0;
      recognizedText = '';
      selectedOption = null;
      selectedYesNo = null;
      userOrder.clear();
      answerLog.clear();
      remainingSeconds = 180;
    });
    startTimer();
    if (questions.first['type'] == 'reorder') prepareReorder();
  }

  String normalize(String input) {
    return input
      .toLowerCase()
      .replaceAll(RegExp(r'[.,!?]'), '')
      .trim();
  }

  void showResult() {
    double percentage = (score / questions.length) * 100;
    int stars = percentage >= 80 ? 3 : percentage >= 50 ? 2 : 1;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        title: const Center(
          child: Text(
            '🎯 Final Score',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('You got $score out of ${questions.length}', style: const TextStyle(fontSize: 18)),
              Text('Percentage: ${percentage.toStringAsFixed(1)}%', style: const TextStyle(fontSize: 18, color: Colors.teal)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  stars,
                  (index) => const Icon(Icons.star, color: Colors.orange, size: 30),
                ),
              )
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          TextButton(onPressed: () { Navigator.pop(context); restartQuiz(); }, child: const Text('Retry')),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    if (showStartScreen) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5FAFF),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '🎓 Ready to start the quiz?',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  setState(() => showStartScreen = false);
                  startTimer();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: const Text('Start Quiz', style: TextStyle(fontSize: 20)),
              ),
            ],
          ),
        ),
      );
    }
    final question = questions[currentIndex];
    return Scaffold(
      backgroundColor: const Color(0xFFF5FAFF),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 243, 88, 5),
        title: const Text('Quiz', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Center(child: Text('⏱ $remainingSeconds s', style: const TextStyle(fontSize: 16))),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: remainingSeconds / 180,
            backgroundColor: Color.fromARGB(255, 243, 88, 5),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            minHeight: 4,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Question ${currentIndex + 1} of ${questions.length}',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 170, 5, 49)),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 4)],
                ),
                child: Text(
                  question['prompt'],
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              if (question['type'] == 'speak') ...[
                Center(
                  child: ElevatedButton.icon(
                    onPressed: isListening ? null : startListening,
                    icon: const Icon(Icons.mic, size: 24),
                    label: const Text('Start Recording', style: TextStyle(fontSize: 22)),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: isListening ? stopListening : null,
                    icon: const Icon(Icons.stop_circle, size: 24),
                    label: const Text('Stop', style: TextStyle(fontSize: 22)),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blueAccent),
                  ),
                  child: Text(
                    recognizedText.isEmpty ? 'Recognized text will appear here' : recognizedText,
                    style: TextStyle(fontSize: 22, color: recognizedText.isEmpty ? const Color.fromARGB(255, 207, 32, 32) : Colors.black87),
                    textAlign: TextAlign.center,
                  ),
                ),
              ] else if (question['type'] == 'choice') ...[
                ...question['options'].map<Widget>((opt) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: RadioListTile<String>(
                    title: Text(opt, style: const TextStyle(fontSize: 22)),
                    value: opt,
                    groupValue: selectedOption,
                    onChanged: (val) => setState(() => selectedOption = val),
                  ),
                )),
                Center(
                  child: ElevatedButton(
                    onPressed: selectedOption != null ? validateAnswer : null,
                    child: const Text('Check Answer', style: TextStyle(fontSize: 22)),

                    style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                  ),
                )
              ] else if (question['type'] == 'yesno') ...[
                RadioListTile<String>(
                  title: const Text('Yes', style: TextStyle(fontSize: 22)),
                  value: 'Yes',
                  groupValue: selectedYesNo,
                  onChanged: (val) => setState(() => selectedYesNo = val),
                ),
                RadioListTile<String>(
                  title: const Text('No', style: TextStyle(fontSize: 22)),
                  value: 'No',
                  groupValue: selectedYesNo,
                  onChanged: (val) => setState(() => selectedYesNo = val),
                ),
                Center(
                  child: ElevatedButton(
                    onPressed: selectedYesNo != null ? validateAnswer : null,
                    child: const Text('Check Answer', style: TextStyle(fontSize: 22)),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                    
                  ),
                )
              ] else if (question['type'] == 'reorder') ...[
                ReorderableWrap(
                  spacing: 12,
                  runSpacing: 12,
                  needsLongPressDraggable: false,
                  onReorder: onReorder,
                  children: userOrder
                      .map((word) => Chip(
                            key: ValueKey(word),
                            label: Text(word, style: const TextStyle(fontSize: 22)),
                            backgroundColor: Colors.lightBlue.shade100,
                          ))
                      .toList(),
                ),
                const SizedBox(height: 16),
                Center(
                  child: ElevatedButton(
                    onPressed: validateAnswer,
                    child: const Text('Check Order', style: TextStyle(fontSize: 22)),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                  ),
                )
              ],
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    countdownTimer?.cancel();
                    showResult();
                  },
                  icon: const Icon(Icons.exit_to_app, size: 24),
                  label: const Text('Finish Quiz Now', style: TextStyle(fontSize:22 )),
                  style: ElevatedButton.styleFrom(backgroundColor: Color.fromARGB(255, 243, 88, 5)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
