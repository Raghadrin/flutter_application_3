import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'dart:async';
import 'dart:math';

class ArabicLevel1QuizScreen extends StatefulWidget {
  const ArabicLevel1QuizScreen({super.key});

  @override
  State<ArabicLevel1QuizScreen> createState() => _ArabicLevel1QuizScreenState();
}

class _ArabicLevel1QuizScreenState extends State<ArabicLevel1QuizScreen> {
  final FlutterTts flutterTts = FlutterTts();
  final stt.SpeechToText speech = stt.SpeechToText();

  int currentIndex = 0;
  int score = 0;
  String recognizedText = '';
  String feedback = '';
  Color feedbackColor = Colors.transparent;
  Timer? _timer;
  int timeLeft = 30;
  bool isSpeaking = false;
  bool answerSubmitted = false;

  final List<Map<String, dynamic>> questions = [
    {"type": "speech", "text": "القطة نائمة على السرير"},
    {"type": "speech", "text": "أكل سامي تفاحة حمراء"},
    {"type": "speech", "text": "قرأت مريم كتابًا مفيدًا"},
    {
      "type": "choice",
      "question": "ما أول حرف في كلمة \"تفاحة\"؟",
      "options": ["ت", "ب", "ن"],
      "answer": "ت"
    },
    {
      "type": "choice",
      "question": "أي كلمة تدل على مكان؟",
      "options": ["مدرسة", "يأكل", "سعيد"],
      "answer": "مدرسة"
    },
    {
      "type": "missing_word",
      "sentence": "ذهب الولد إلى ____",
      "options": ["البيت", "يأكل", "يلعب"],
      "answer": "البيت"
    },
  ];

  @override
  void initState() {
    super.initState();
    flutterTts.setLanguage("ar-SA");
    flutterTts.setSpeechRate(0.4);
    _speak("استمع وأجب عن الأسئلة");
    startTimer();
  }

  void startTimer() {
    _timer?.cancel();
    timeLeft = 30;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timeLeft > 0) {
        setState(() => timeLeft--);
      } else {
        _nextQuestion();
      }
    });
  }

  Future<void> _speak(String text) async {
    setState(() => isSpeaking = true);
    await flutterTts.stop();
    await flutterTts.speak(text);
    await Future.delayed(Duration(seconds: text.length ~/ 5));
    setState(() => isSpeaking = false);
  }

  Future<void> _evaluateSpeech(String expected) async {
    if (isSpeaking || answerSubmitted) return;

    bool available = await speech.initialize();
    if (!available) return;

    recognizedText = '';
    speech.listen(
      localeId: 'ar_SA',
      partialResults: false,
      onResult: (val) async {
        recognizedText = val.recognizedWords;
        final spoken = normalizeArabic(recognizedText.trim());
        final correct = normalizeArabic(expected.trim());

        final percentage = calculateSimilarityPercentage(correct, spoken);
        final color = percentage >= 80 ? Colors.green : Colors.red;

        setState(() {
          feedback = "$percentage%";
          feedbackColor = color;
          answerSubmitted = true;
        });

        await Future.delayed(const Duration(milliseconds: 300));
        await _speak("أحرزت $percentage بالمئة");

        if (percentage >= 80) {
          score++;
        }
      },
    );
  }

  void _evaluateChoice(String selected, String correct) async {
    if (answerSubmitted) return;

    final isCorrect = selected == correct;
    final color = isCorrect ? Colors.green : Colors.red;

    setState(() {
      feedback = isCorrect ? "إجابة صحيحة!" : "إجابة خاطئة";
      feedbackColor = color;
      answerSubmitted = true;
    });

    await _speak(feedback);
    if (isCorrect) {
      score++;
    }
  }

  void _nextQuestion() {
    _timer?.cancel();
    setState(() {
      currentIndex++;
      feedback = '';
      feedbackColor = Colors.transparent;
      answerSubmitted = false;
    });

    if (currentIndex < questions.length) {
      startTimer();
    } else {
      _showResult();
    }
  }

  void _skipQuestion() {
    _nextQuestion();
  }

  void _showResult() {
    String message;
    if (score == questions.length) {
      message = "ممتاز! 🌟";
    } else if (score >= questions.length * 0.7) {
      message = "جيد جدًا! 👍";
    } else if (score >= questions.length * 0.4) {
      message = "جيد، يمكنك التحسن 💪";
    } else {
      message = "لا بأس، حاول مجددًا!";
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("🌟 النتيجة النهائية", textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "أحرزت $score من ${questions.length}",
              style: const TextStyle(fontSize: 22),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              message,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                currentIndex = 0;
                score = 0;
                feedback = '';
                feedbackColor = Colors.transparent;
                answerSubmitted = false;
              });
              _speak("لنبدأ من جديد");
              startTimer();
            },
            child: const Text("إعادة المحاولة", style: TextStyle(fontSize: 20)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("العودة", style: TextStyle(fontSize: 20)),
          ),
        ],
      ),
    );
  }

  String normalizeArabic(String input) {
    return input
        .replaceAll('ة', 'ه')
        .replaceAll(RegExp(r'[ًٌٍ]'), '')
        .replaceAll('ئ', 'ي')
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا');
  }

  int calculateSimilarityPercentage(String expected, String spoken) {
    final int distance = levenshtein(expected, spoken);
    final int maxLength = expected.length > 0 ? expected.length : 1;
    return (((1 - (distance / maxLength)) * 100).round()).clamp(0, 100);
  }

  int levenshtein(String s, String t) {
    if (s == t) return 0;
    if (s.isEmpty) return t.length;
    if (t.isEmpty) return s.length;

    List<List<int>> matrix = List.generate(
      s.length + 1,
      (_) => List.filled(t.length + 1, 0),
    );

    for (int i = 0; i <= s.length; i++) matrix[i][0] = i;
    for (int j = 0; j <= t.length; j++) matrix[0][j] = j;

    for (int i = 1; i <= s.length; i++) {
      for (int j = 1; j <= t.length; j++) {
        int cost = s[i - 1] == t[j - 1] ? 0 : 1;
        matrix[i][j] = [
          matrix[i - 1][j] + 1,
          matrix[i][j - 1] + 1,
          matrix[i - 1][j - 1] + cost
        ].reduce((a, b) => a < b ? a : b);
      }
    }

    return matrix[s.length][t.length];
  }

  Widget _buildMissingWordQuestion(Map<String, dynamic> question) {
    return Column(
      children: [
        Text(
          "املأ الفراغ بالكلمة الصحيحة:",
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        Text(
          question['sentence'],
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.brown,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 30),
        ...List.generate(question['options'].length, (i) {
          final option = question['options'][i];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ElevatedButton(
              onPressed: () => _evaluateChoice(option, question['answer']),
              child: Text(option, style: const TextStyle(fontSize: 24)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple.shade100,
                minimumSize: const Size.fromHeight(60),
              ),
            ),
          );
        }),
      ],
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final current = questions[currentIndex];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFFFF8E1),
        appBar: AppBar(
          title:
              const Text("📝 كويز المستوى 1", style: TextStyle(fontSize: 26)),
          centerTitle: true,
          backgroundColor: Colors.orange,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "السؤال ${currentIndex + 1} من ${questions.length}",
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  "⏰ الوقت المتبقي: $timeLeft ثانية",
                  style: TextStyle(
                      color: timeLeft < 10 ? Colors.red : Colors.grey[700],
                      fontSize: 18),
                ),
                const SizedBox(height: 20),
                if (current['type'] == 'speech') ...[
                  Text(
                    current['text'],
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.volume_up, size: 28),
                    label: const Text("استمع للجملة",
                        style: TextStyle(fontSize: 22)),
                    onPressed: () => _speak(current['text']),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 16),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.mic, size: 28),
                    label:
                        const Text("أجب بصوتك", style: TextStyle(fontSize: 22)),
                    onPressed: () => _evaluateSpeech(current['text']),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrangeAccent,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 16),
                    ),
                  ),
                ] else if (current['type'] == 'choice') ...[
                  Text(
                    current['question'],
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ...List.generate(current['options'].length, (i) {
                    final option = current['options'][i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: ElevatedButton(
                        onPressed: () =>
                            _evaluateChoice(option, current['answer']),
                        child:
                            Text(option, style: const TextStyle(fontSize: 24)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange.shade100,
                          minimumSize: const Size.fromHeight(60),
                        ),
                      ),
                    );
                  }),
                ] else if (current['type'] == 'missing_word') ...[
                  _buildMissingWordQuestion(current),
                ],
                const SizedBox(height: 20),
                if (feedback.isNotEmpty)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: feedbackColor, width: 2),
                      color: feedbackColor.withOpacity(0.1),
                    ),
                    child: Text(
                      feedback,
                      style: TextStyle(
                          color: feedbackColor,
                          fontSize: 26,
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                const Spacer(),
                if (answerSubmitted || feedback.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: ElevatedButton(
                      onPressed: _nextQuestion,
                      child:
                          const Text("التالي", style: TextStyle(fontSize: 22)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50, vertical: 16),
                      ),
                    ),
                  ),
                if (!answerSubmitted && feedback.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 30),
                    child: ElevatedButton(
                      onPressed: _skipQuestion,
                      child: const Text("تخطي السؤال",
                          style: TextStyle(fontSize: 22)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 16),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
