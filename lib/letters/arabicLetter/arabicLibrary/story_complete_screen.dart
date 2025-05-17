import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class AdvancedStoryCompleteScreen extends StatefulWidget {
  const AdvancedStoryCompleteScreen({super.key});

  @override
  State<AdvancedStoryCompleteScreen> createState() => _AdvancedStoryCompleteScreenState();
}

class _AdvancedStoryCompleteScreenState extends State<AdvancedStoryCompleteScreen> {
  final FlutterTts flutterTts = FlutterTts();
  int score = 0;
  int attempts = 0;
  bool showScore = false;

  final List<Map<String, dynamic>> stories = [
    {
      "title": "رحلة إلى الحديقة",
      "start": "في يوم مشمس جميل، قررت سلمى أن تذهب إلى الحديقة القريبة من منزلها. أخذت معها كيسًا صغيرًا وضعت فيه بعض الفواكه وزجاجة ماء...",
      "hint": "ما هو التصرف الصحيح في الحديقة؟",
      "endings": [
        {"text": "فالتقت بصديقاتها ولعبت معهن بأمان وسعادة.", "isCorrect": true},
        {"text": "فقطعت بعض الأزهار وألقتها على الأرض.", "isCorrect": false},
        {"text": "فأكلت كل ما معها من طعام ثم نامت تحت شجرة.", "isCorrect": false},
        {"text": "فسخرت من الأطفال الآخرين في الحديقة.", "isCorrect": false},
      ]
    },
    {
      "title": "الواجب المدرسي",
      "start": "عاد خالد من المدرسة متعبًا، وكان عليه إنهاء واجبه المدرسي قبل موعد النوم. جلس على مكتبه وفتح كتبه...",
      "hint": "ما هو السلوك المسؤول؟",
      "endings": [
        {"text": "فبدأ بتركيز في حل الواجب حتى انتهى منه.", "isCorrect": true},
        {"text": "فأغلق الكتب وذهب للعب بالكرة.", "isCorrect": false},
        {"text": "فطلب من أخيه أن يحل الواجب بدلاً منه.", "isCorrect": false},
        {"text": "فكتب أي شيء بسرعة لينهي المهمة.", "isCorrect": false},
      ]
    },
    {
      "title": "الكتاب الجديد",
      "start": "حصلت ليلى على كتاب جديد هدية من عمتها. كان الكتاب يحتوي على قصص مشوقة ورسومات جميلة...",
      "hint": "كيف نتعامل مع الكتب؟",
      "endings": [
        {"text": "فقرأته بعناية وحافظت عليه نظيفًا مرتبًا.", "isCorrect": true},
        {"text": "فمزقت بعض الصفحات لتلصقها على حائط غرفتها.", "isCorrect": false},
        {"text": "فنسيته تحت السرير ولم تفتحه أبدًا.", "isCorrect": false},
        {"text": "فأعطته لصديقتها دون أن تقرأه.", "isCorrect": false},
      ]
    },
    {
      "title": "الحيوان الأليف",
      "start": "وجد ياسر قطة صغيرة تموء عند باب المنزل. بدت القطة جائعة وخائفة...",
      "hint": "كيف نتعامل مع الحيوانات؟",
      "endings": [
        {"text": "فأحضر لها بعض الطعام والماء بلطف.", "isCorrect": true},
        {"text": "فصرخ عليها لتبتعد عن منزله.", "isCorrect": false},
        {"text": "فأمسكها بقوة وألقاها بعيدًا.", "isCorrect": false},
        {"text": "فتجاهلها وتركها كما هي.", "isCorrect": false},
      ]
    },
  ];

  int currentStoryIndex = 0;
  String? feedback;
  bool showHint = false;

  List<Map<String, dynamic>> get currentEndings => stories[currentStoryIndex]["endings"];
  String get currentStart => stories[currentStoryIndex]["start"];
  String get currentTitle => stories[currentStoryIndex]["title"];
  String get currentHint => stories[currentStoryIndex]["hint"];

  @override
  void initState() {
    super.initState();
    flutterTts.setLanguage("ar-SA");
    flutterTts.setSpeechRate(0.45);
    _speakText(currentTitle + ". " + currentStart);
    currentEndings.shuffle();
  }

  Future<void> _speakText(String text) async {
    await flutterTts.stop();
    await flutterTts.speak(text);
  }

  void _handleChoice(Map<String, dynamic> ending) {
    setState(() {
      feedback = ending["isCorrect"] ? "أحسنت! ✅" : "حاول مرة أخرى ❌";
      if (ending["isCorrect"]) {
        score++;
      }
      attempts++;
      showHint = false;
    });
    _speakText(ending["isCorrect"] 
      ? "إجابة صحيحة! ${ending["text"]}" 
      : "للأسف هذه ليست الإجابة المثالية. ${ending["text"]}");
  }

  void _nextStory() {
    setState(() {
      if (currentStoryIndex < stories.length - 1) {
        currentStoryIndex++;
      } else {
        showScore = true;
      }
      feedback = null;
      currentEndings.shuffle();
      showHint = false;
    });
    if (!showScore) {
      _speakText(currentTitle + ". " + currentStart);
    }
  }

  void _resetGame() {
    setState(() {
      currentStoryIndex = 0;
      score = 0;
      attempts = 0;
      feedback = null;
      showScore = false;
      currentEndings.shuffle();
    });
    _speakText(currentTitle + ". " + currentStart);
  }

  void _toggleHint() {
    setState(() {
      showHint = !showHint;
    });
    if (showHint) {
      _speakText("تلميح: $currentHint");
    }
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (showScore) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: const Color(0xFFFFF6ED),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "🎉 النتيجة النهائية 🎉",
                  style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.orange),
                ),
                const SizedBox(height: 30),
                Text(
                  "الإجابات الصحيحة: $score من ${stories.length}",
                  style: const TextStyle(fontSize: 28, color: Colors.green),
                ),
                const SizedBox(height: 20),
                Text(
                  "الدقة: ${(score / stories.length * 100).toStringAsFixed(1)}%",
                  style: const TextStyle(fontSize: 24, color: Colors.blue),
                ),
                const SizedBox(height: 40),
                ElevatedButton.icon(
                  onPressed: _resetGame,
                  icon: const Icon(Icons.refresh, size: 30),
                  label: const Text("إعادة اللعبة", style: TextStyle(fontSize: 24)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFFFF6ED),
        appBar: AppBar(
          title: const Text("احكِلي وأنا أكمل - المستوى المتقدم", 
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          centerTitle: true,
          backgroundColor: const Color(0xFFFFA726),
          actions: [
            IconButton(
              icon: const Icon(Icons.help_outline, size: 30),
              onPressed: _toggleHint,
              tooltip: 'إظهار التلميح',
            ),
          ],
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  currentTitle,
                  style: const TextStyle(fontSize: 28, color: Colors.orange, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                const Text(
                  "بداية القصة:",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.orange, width: 2),
                  ),
                  child: Text(
                    currentStart,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 22, color: Colors.brown),
                  ),
                ),
                const SizedBox(height: 20),
                if (showHint)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue),
                    ),
                    child: Text(
                      "💡 تلميح: $currentHint",
                      style: const TextStyle(fontSize: 20, color: Colors.blue),
                      textAlign: TextAlign.center,
                    ),
                  ),
                const SizedBox(height: 20),
                const Text(
                  "اختر النهاية المناسبة:",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 20),
                ...currentEndings.map((ending) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: ElevatedButton(
                        onPressed: feedback == null ? () => _handleChoice(ending) : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black87,
                          side: BorderSide(
                            color: feedback != null && ending["isCorrect"] 
                              ? Colors.green 
                              : Colors.orange, 
                            width: 3),
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 4,
                        ),
                        child: Text(
                          ending["text"],
                          style: const TextStyle(fontSize: 20),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )),
                const SizedBox(height: 30),
                if (feedback != null)
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: feedback!.contains("✅") ? Colors.green[50] : Colors.red[50],
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: feedback!.contains("✅") ? Colors.green : Colors.red, 
                            width: 2),
                        ),
                        child: Text(
                          feedback!,
                          style: TextStyle(
                            fontSize: 24,
                            color: feedback!.contains("✅") ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: _nextStory,
                        icon: const Icon(Icons.arrow_forward, size: 30),
                        label: const Text("التالي", style: TextStyle(fontSize: 24)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                    ),  ],
                  ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _speakText(currentStart),
                      icon: const Icon(Icons.volume_up, size: 28),
                      label: const Text("سماع القصة", style: TextStyle(fontSize: 20)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                    const SizedBox(width: 15),
                    ElevatedButton.icon(
                      onPressed: _toggleHint,
                      icon: Icon(showHint ? Icons.visibility_off : Icons.visibility, size: 28),
                      label: Text(showHint ? "إخفاء التلميح" : "تلميح", style: const TextStyle(fontSize: 20)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                 ), ],
                ),
                const SizedBox(height: 20),
                Text(
                  "القصة ${currentStoryIndex + 1} من ${stories.length}",
                  style: const TextStyle(fontSize: 20, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}