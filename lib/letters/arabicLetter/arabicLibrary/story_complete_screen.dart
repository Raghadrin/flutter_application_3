import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class StoryCompleteScreen extends StatefulWidget {
  const StoryCompleteScreen({super.key});

  @override
  State<StoryCompleteScreen> createState() => _StoryCompleteScreenState();
}

class _StoryCompleteScreenState extends State<StoryCompleteScreen> {
  final FlutterTts flutterTts = FlutterTts();

  final List<Map<String, dynamic>> stories = [
    {
      "start": "خرجت سلمى في الصباح الباكر...",
      "endings": [
        {"text": "ولعبت في الحديقة مع أصدقائها.", "isCorrect": true},
        {"text": "وأكلت شوكولاتة فقط طوال اليوم.", "isCorrect": false},
        {"text": "ثم نامت في منتصف الطريق.", "isCorrect": false},
      ]
    },
    {
      "start": "استيقظ سامي مبكرًا ليذهب إلى المدرسة...",
      "endings": [
        {"text": "وذهب في الوقت المحدد.", "isCorrect": true},
        {"text": "ونسي حذاءه في المنزل.", "isCorrect": false},
        {"text": "وبدأ اللعب في الشارع.", "isCorrect": false},
      ]
    },
    {
      "start": "أخذت ليلى كتابها وبدأت تقرأ...",
      "endings": [
        {"text": "فاستمتعت بالقصة وتعلمت منها.", "isCorrect": true},
        {"text": "ثم مزقته وغضبت.", "isCorrect": false},
        {"text": "ونام الكتاب من التعب.", "isCorrect": false},
      ]
    },
  ];

  int currentStoryIndex = 0;
  String? feedback;

  List<Map<String, dynamic>> get currentEndings =>
      stories[currentStoryIndex]["endings"];

  String get currentStart => stories[currentStoryIndex]["start"];

  @override
  void initState() {
    super.initState();
    flutterTts.setLanguage("ar-SA");
    flutterTts.setSpeechRate(0.45);
    _speakText(currentStart);
    currentEndings.shuffle();
  }

  Future<void> _speakText(String text) async {
    await flutterTts.stop();
    await flutterTts.speak(text);
  }

  void _handleChoice(Map<String, dynamic> ending) {
    setState(() {
      feedback = ending["isCorrect"] ? "أحسنت! ✅" : "حاول مرة أخرى ❌";
    });
    _speakText(ending["text"]);
  }

  void _nextStory() {
    setState(() {
      currentStoryIndex = (currentStoryIndex + 1) % stories.length;
      feedback = null;
      currentEndings.shuffle();
    });
    _speakText(currentStart);
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFFFF6ED),
        appBar: AppBar(
          title: const Text("احكِلي وأنا أكمل", style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
          backgroundColor: const Color(0xFFFFA726),
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("بداية القصة:", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
                const SizedBox(height: 12),
                Text(
                  currentStart,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 22, color: Colors.orange, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),
                const Text("اختر النهاية الصحيحة:", style: TextStyle(fontSize: 18)),
                const SizedBox(height: 20),
                ...currentEndings.map((ending) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: ElevatedButton(
                        onPressed: () => _handleChoice(ending),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: const BorderSide(color: Colors.orange, width: 2),
                          padding: const EdgeInsets.all(12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          ending["text"],
                          style: const TextStyle(fontSize: 18, color: Colors.black87),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )),
                const SizedBox(height: 30),
                if (feedback != null)
                  Text(
                    feedback!,
                    style: TextStyle(
                      fontSize: 22,
                      color: feedback!.contains("✅") ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _nextStory,
                  icon: const Icon(Icons.refresh),
                  label: const Text("قصة جديدة"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
