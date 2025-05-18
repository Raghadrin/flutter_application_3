import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:reorderables/reorderables.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class QuizAScreen extends StatefulWidget {
  const QuizAScreen({super.key});

  @override
  State<QuizAScreen> createState() => _QuizAScreenState();
}

class _QuizAScreenState extends State<QuizAScreen> {
  late FlutterTts flutterTts;
  late stt.SpeechToText speech;
  Timer? countdownTimer;
  int remainingSeconds = 180;
  List<String> userOrder = [];

  final List<Map<String, dynamic>> questions = [
    {'type': 'speak', 'prompt': 'انطق الكلمة: استراتيجيات', 'answer': 'استراتيجيات'},
    {'type': 'reorder', 'prompt': 'رتب الجملة: [المعلمة، لنا، قصة، قرأت]', 'answer': 'قرأت المعلمة لنا قصة'},
    {'type': 'choice', 'prompt': 'ما السبب الرئيسي لزيارة الطلاب إلى المتحف؟', 'options': ['للتعلم عن التاريخ', 'لشراء الهدايا', 'للاستراحة'], 'answer': 'للتعلم عن التاريخ'},
    {'type': 'yesno', 'prompt': 'هل تحتوي الجملة "ذهب الطالب إلى المدرسة باكرًا" على فعل؟', 'answer': 'نعم'},
    {'type': 'speak', 'prompt': 'اقرأ الجملة: الشمس تشرق في الصباح.', 'answer': 'الشمس تشرق في الصباح'},
    {'type': 'choice', 'prompt': 'ما مرادف كلمة "الوفاء"؟', 'options': ['الإخلاص', 'النسيان', 'الخداع'], 'answer': 'الإخلاص'},
    {'type': 'reorder', 'prompt': 'رتب الجملة: [البيئة، نحافظ، على، يجب]', 'answer': 'يجب أن نحافظ على البيئة'},
    {'type': 'choice', 'prompt': 'ما الجملة الصحيحة لغويًا؟', 'options': ['ذهبتُ إلى المدرسة في المساء', 'أكلَتْ الولد التفاحة', 'يلعب البنت في الحديقة'], 'answer': 'ذهبتُ إلى المدرسة في المساء'},
  ];

  int currentIndex = 0;
  int score = 0;
  bool isListening = false;
  String recognizedText = '';
  String? selectedOption;
  String? selectedYesNo;
  List<Map<String, dynamic>> answerLog = [];

  @override
  void initState() {
    super.initState();
    flutterTts = FlutterTts();
    flutterTts.setLanguage("ar-SA");
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
    bool available = await speech.initialize(
      onStatus: (val) => print('onStatus: $val'),
      onError: (val) => print('onError: $val'),
    );
    if (!available) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر الوصول إلى ميزة التعرف على الصوت')));
      return;
    }
    setState(() {
      isListening = true;
      recognizedText = '';
    });
    speech.listen(
      localeId: 'ar_SA',
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
      speak('إجابة صحيحة!');
    } else {
      speak('إجابة خاطئة');
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
      .replaceAll('ة', 'ه')
      .replaceAll('ى', 'ي')
      .replaceAll(RegExp(r'[\u064B-\u065F]'), '') // Remove diacritics
      .replaceAll(RegExp(r'[،؟!.؛:-ـ]'), '')
      .replaceAll('أ', 'ا')
      .replaceAll('إ', 'ا')
      .replaceAll('آ', 'ا')
      .replaceAll('ؤ', 'و')
      .replaceAll('ئ', 'ي')
      .trim();
  }

  @override
  Widget build(BuildContext context) {
    final question = questions[currentIndex];
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFFFF8E1),
        appBar: AppBar(
          backgroundColor: Colors.deepOrange,
          title: const Text('الكويز الشامل', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Center(child: Text('⏱ $remainingSeconds ثانية', style: const TextStyle(fontSize: 16))),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(4),
            child: LinearProgressIndicator(
              value: remainingSeconds / 180,
              backgroundColor: Colors.orange.shade100,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 4,
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(12),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Question counter and score
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'السؤال ${currentIndex + 1} من ${questions.length}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange),
                      ),
                      Text(
                        'النقاط: $score',
                        style: const TextStyle(fontSize: 18, color: Colors.brown, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),

                // Question box
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: const Offset(0, 2),
                    )
                    ],
                  ),
                  child: Text(
                    question['prompt'],
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.brown),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Question content based on type
                if (question['type'] == 'speak') ...[
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: isListening ? null : startListening,
                      icon: const Icon(Icons.mic, size: 24),
                      label: const Text('ابدأ التسجيل', style: TextStyle(fontSize: 18)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: isListening ? stopListening : null,
                      icon: const Icon(Icons.stop_circle, size: 24),
                      label: const Text('إيقاف', style: TextStyle(fontSize: 18)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange),
                    ),
                    child: Text(
                      recognizedText.isEmpty ? 'سيظهر النص المقروء هنا' : recognizedText,
                      style: TextStyle(
                        fontSize: 18,
                        color: recognizedText.isEmpty ? Colors.grey : Colors.brown,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ] else if (question['type'] == 'choice') ...[
                  ...question['options'].map<Widget>((opt) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: RadioListTile<String>(
                        title: Text(opt, style: const TextStyle(fontSize: 18)),
                        value: opt,
                        groupValue: selectedOption,
                        onChanged: (val) => setState(() => selectedOption = val),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                        tileColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        controlAffinity: ListTileControlAffinity.trailing,
                      ),
                    ),
                  )),
                  const SizedBox(height: 12),
                  Center(
                    child: ElevatedButton(
                      onPressed: selectedOption != null ? validateAnswer : null,
                      child: const Text('تحقق من الإجابة', style: TextStyle(fontSize: 18)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ] else if (question['type'] == 'yesno') ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: RadioListTile<String>(
                        title: const Text('نعم', style: TextStyle(fontSize: 18)),
                        value: 'نعم',
                        groupValue: selectedYesNo,
                        onChanged: (val) => setState(() => selectedYesNo = val),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                        tileColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        controlAffinity: ListTileControlAffinity.trailing,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: RadioListTile<String>(
                        title: const Text('لا', style: TextStyle(fontSize: 18)),
                        value: 'لا',
                        groupValue: selectedYesNo,
                        onChanged: (val) => setState(() => selectedYesNo = val),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                        tileColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        controlAffinity: ListTileControlAffinity.trailing,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: ElevatedButton(
                      onPressed: selectedYesNo != null ? validateAnswer : null,
                      child: const Text('تحقق من الإجابة', style: TextStyle(fontSize: 18)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ] else if (question['type'] == 'reorder') ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: ReorderableWrap(
                      spacing: 12,
                      runSpacing: 12,
                      needsLongPressDraggable: false,
                      onReorder: onReorder,
                      children: userOrder
                          .map((word) => Chip(
                                key: ValueKey(word),
                                label: Text(word, style: const TextStyle(fontSize: 18)),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                backgroundColor: Colors.orange.shade100,
                              ))
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: ElevatedButton(
                      onPressed: validateAnswer,
                      child: const Text('تحقق من الترتيب', style: TextStyle(fontSize: 18)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
                
                // End quiz button
                const SizedBox(height: 24),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      countdownTimer?.cancel();
                      showResult();
                    },
                    icon: const Icon(Icons.exit_to_app, size: 24),
                    label: const Text('إنهاء الكويز الآن', style: TextStyle(fontSize: 18)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
            '🎯 النتيجة النهائية',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'أحرزت $score من ${questions.length}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'النسبة: ${percentage.toStringAsFixed(1)}%',
                        style: const TextStyle(fontSize: 18, color: Colors.teal, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          stars,
                          (index) => const Icon(Icons.star, color: Colors.orange, size: 30),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: Text(
                    '📋 تفاصيل إجاباتك:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                ...answerLog.map((e) => Padding(
                  padding: const EdgeInsets.only(right: 12, bottom: 12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            e['prompt'],
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 6),
                          Text('إجابتك: ${e['yourAnswer']}', style: const TextStyle(fontSize: 16)),
                          Text('الصحيح: ${e['correctAnswer']}', style: const TextStyle(fontSize: 16)),
                          const SizedBox(height: 6),
                          Icon(
                            e['correct'] ? Icons.check_circle : Icons.cancel,
                            color: e['correct'] ? Colors.green : Colors.red,
                            size: 24,
                          ),
                        ],
                      ),
                    ),
                  ),
                )),
              ],
            ),
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق', style: TextStyle(fontSize: 18)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              restartQuiz();
            },
            child: const Text('🔁 إعادة الاختبار', style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }
}