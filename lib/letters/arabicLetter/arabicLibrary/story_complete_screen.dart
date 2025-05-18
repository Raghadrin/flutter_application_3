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
      "start": "في يوم مشمس جميل، قررت سلمى أن تذهب إلى الحديقة القريبة من منزلها...",
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
      "start": "عاد خالد من المدرسة متعبًا، وكان عليه إنهاء واجبه المدرسي...",
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
      "start": "حصلت ليلى على كتاب جديد هدية من عمتها...",
      "hint": "كيف نتعامل مع الكتب؟",
      "endings": [
        {"text": "فقرأته بعناية وحافظت عليه نظيفًا مرتبًا.", "isCorrect": true},
        {"text": "فمزقت بعض الصفحات لتلصقها على الحائط.", "isCorrect": false},
        {"text": "فنسيته تحت السرير ولم تفتحه أبدًا.", "isCorrect": false},
        {"text": "فأعطته لصديقتها دون أن تقرأه.", "isCorrect": false},
      ]
    },
    {
      "title": "الحيوان الأليف",
      "start": "وجد ياسر قطة صغيرة تموء عند باب المنزل...",
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
      if (ending["isCorrect"]) score++;
      attempts++;
      showHint = false;
    });
    _speakText(
      ending["isCorrect"]
          ? "إجابة صحيحة! ${ending["text"]}"
          : "للأسف هذه ليست الإجابة المثالية. ${ending["text"]}",
    );
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
    if (!showScore) _speakText(currentTitle + ". " + currentStart);
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
    if (showHint) _speakText("تلميح: $currentHint");
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
          title: const Text("أكمل القصة", style: TextStyle(fontSize: 18)),
          centerTitle: true,
          backgroundColor: Colors.orange,
          actions: [
            IconButton(
              icon: const Icon(Icons.help_outline, size: 20),
              onPressed: _toggleHint,
            ),
          ],
        ),
        body: showScore
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("🎉 النتيجة النهائية 🎉",
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.orange)),
                    const SizedBox(height: 20),
                    Text("الإجابات الصحيحة: $score من ${stories.length}",
                        style: const TextStyle(fontSize: 18, color: Colors.green)),
                    const SizedBox(height: 10),
                    Text("الدقة: ${(score / stories.length * 100).toStringAsFixed(1)}%",
                        style: const TextStyle(fontSize: 16, color: Colors.blue)),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _resetGame,
                      icon: const Icon(Icons.refresh, size: 20),
                      label: const Text("إعادة", style: TextStyle(fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(currentTitle,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.orange)),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.orange),
                      ),
                      child: Text(currentStart,
                          style: const TextStyle(fontSize: 16, color: Colors.brown), textAlign: TextAlign.center),
                    ),
                    if (showHint) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.blue),
                        ),
                        child: Text("💡 $currentHint",
                            style: const TextStyle(fontSize: 14, color: Colors.blue),
                            textAlign: TextAlign.center),
                      ),
                    ],
                    const SizedBox(height: 20),
                    const Text("اختر النهاية:", style: TextStyle(fontSize: 18)),
                    const SizedBox(height: 10),
                    ...currentEndings.map(
                      (ending) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: ElevatedButton(
                          onPressed: feedback == null ? () => _handleChoice(ending) : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            side: BorderSide(
                              color: feedback != null && ending["isCorrect"] ? Colors.green : Colors.orange,
                              width: 2,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(ending["text"], style: const TextStyle(fontSize: 14)),
                        ),
                      ),
                    ),
                    if (feedback != null) ...[
                      const SizedBox(height: 20),
                      Text(
                        feedback!,
                        style: TextStyle(
                          fontSize: 16,
                          color: feedback!.contains("✅") ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        onPressed: _nextStory,
                        icon: const Icon(Icons.arrow_forward, size: 20),
                        label: const Text("التالي", style: TextStyle(fontSize: 14)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _speakText(currentStart),
                          icon: const Icon(Icons.volume_up, size: 20),
                          label: const Text("اسمع", style: TextStyle(fontSize: 14)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: _toggleHint,
                          icon: Icon(showHint ? Icons.visibility_off : Icons.visibility, size: 20),
                          label: Text(showHint ? "إخفاء" : "تلميح", style: const TextStyle(fontSize: 14)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text("القصة ${currentStoryIndex + 1} من ${stories.length}",
                        style: const TextStyle(fontSize: 14, color: Colors.grey)),
                  ],
                ),
              ),
      ),
    );
  }
}
