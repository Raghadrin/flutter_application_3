import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'evaluation2_screen.dart';
import 'FinalFeedbackScreenAr.dart';

class KaraokeSentenceArabicScreen extends StatefulWidget {
  const KaraokeSentenceArabicScreen({super.key});

  @override
  State<KaraokeSentenceArabicScreen> createState() => _KaraokeSentenceArabicScreenState();
}

class _KaraokeSentenceArabicScreenState extends State<KaraokeSentenceArabicScreen> with TickerProviderStateMixin {
  late stt.SpeechToText speech;
  late AudioPlayer audioPlayer;
  bool isListening = false;
  bool isPlaying = false;

  String recognizedText = '';
  double score = 0.0;
  int stars = 0;
  int currentSentenceIndex = 0;
  int matchedWordCount = 0;
  Map<String, bool> wordMatchResults = {};
  List<String> spokenWordSequence = [];
  final List<double> _sessionScores = [];

  final List<Map<String, String>> sentences = [
    {
      "text": "في غابة جميلة، كانت تعيش سلحفاة. كانت تمشي ببطء، لكنها تفكر بهدوء. كلما اختلفت الحيوانات، نادت السلحفاة. الكل يسمع كلامها لأنها حكيمة وطيبة.",
      "audio": "audio/turtle1.mp3"
    },
    {
      "text": "في يوم من الأيام، ضاع أرنب صغير. ركض كثيرًا ولم يعرف طريق البيت. كان خائفًا ويبكي تحت الشجرة. جاءت السلحفاة وسألته: \"هل تحتاج مساعدة؟\"",
      "audio": "audio/turtle2.mp3"
    },
    {
      "text": "سارت معه حتى وصل إلى بيته. قال الأرنب: \"كنت أظن السلاحف بطيئة فقط !\" ولكنك ذكية وتعرفين ما تفعلين. ابتسمت السلحفاة وقالت: \"لا تحكم من الشكل!\" ومن يومها، أصبح الأرنب صديقها.",
      "audio": "audio/turtle3.mp3"
    }
  ];

  final Map<String, Map<String, String>> wordCategoriesLevel1Ar = {
    "سلحفاة": {"category": "حيوانات", "description": "نوع من الحيوانات بطيئة الحركة."},
    "أرنب": {"category": "حيوانات", "description": "حيوان صغير سريع الجري."},
    "غابة": {"category": "أماكن", "description": "منطقة مليئة بالأشجار والحيوانات."},
    "الشجرة": {"category": "أماكن", "description": "نبات طويل له جذع وفروع."},
    "بيت": {"category": "أماكن", "description": "مكان السكن والراحة."},
    "ضياع": {"category": "أفعال / مشاعر", "description": "فقدان الطريق أو الاتجاه."},
    "ركض": {"category": "أفعال / مشاعر", "description": "الجري بسرعة."},
    "خائف": {"category": "أفعال / مشاعر", "description": "شعور بعدم الأمان أو التهديد."},
    "يبكي": {"category": "أفعال / مشاعر", "description": "تساقط الدموع بسبب الحزن أو الخوف."},
    "ذكية": {"category": "صفات", "description": "تدل على الفطنة والذكاء."},
    "بطيئة": {"category": "صفات", "description": "عكس سريعة، تمشي ببطء."},
    "طيبة": {"category": "صفات", "description": "تدل على حسن النية والحنان."},
    "مساعدة": {"category": "قيم", "description": "تقديم يد العون للآخرين."},
    "الشكل": {"category": "مفاهيم", "description": "مظهر أو هيئة الشيء."}
  };

  Map<String, String> get currentSentence => sentences[currentSentenceIndex];

  @override
  void initState() {
    super.initState();
    speech = stt.SpeechToText();
    audioPlayer = AudioPlayer();
    audioPlayer.onPlayerComplete.listen((_) => setState(() => isPlaying = false));
  }

  Future<void> playAudio() async {
    await audioPlayer.stop();
    await audioPlayer.play(AssetSource(currentSentence['audio']!));
    setState(() => isPlaying = true);
  }

  Future<void> startListening() async {
    bool available = await speech.initialize(
      onStatus: (val) => setState(() => isListening = val != 'done'),
      onError: (val) => setState(() => isListening = false),
    );
    if (!available) return;

    setState(() {
      isListening = true;
      recognizedText = '';
      wordMatchResults.clear();
      spokenWordSequence.clear();
      matchedWordCount = 0;
    });

    speech.listen(
      localeId: 'ar_SA',
      listenMode: stt.ListenMode.dictation,
      partialResults: true,
      listenFor: const Duration(seconds: 60),
      pauseFor: const Duration(seconds: 4),
      onResult: (val) {
        recognizedText = val.recognizedWords;
        updateMatchedWords();
        matchedWordCount = recognizedText.split(RegExp(r'\s+')).length;

        if (val.finalResult) {
          evaluateResult();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => Evaluation2Screen(
                recognizedText: recognizedText,
                score: score,
                stars: stars,
                wordMatchResults: wordMatchResults,
                wordCategories: wordCategoriesLevel1Ar,
                onNext: nextSentence,
                level: 'level1',
              ),
            ),
          );
        }
      },
    );
  }

  void updateMatchedWords() {
    final expectedWords = currentSentence["text"]!.split(RegExp(r'\s+'));
    final spokenWords = recognizedText.split(RegExp(r'\s+'));

    final newResults = <String, bool>{};
    for (var word in expectedWords) {
      final clean = word.replaceAll(RegExp(r'[^ء-ي]'), '');
      newResults[clean] = spokenWords.any((spoken) => levenshtein(clean, spoken) <= 1);
    }

    setState(() {
      wordMatchResults = newResults;
      spokenWordSequence = spokenWords;
    });
  }

  void evaluateResult() {
    final correct = wordMatchResults.values.where((v) => v).length;
    final total = wordMatchResults.length;
    score = total > 0 ? (correct / total) * 100 : 0.0;
    stars = score >= 90 ? 3 : (score >= 60 ? 2 : (score > 0 ? 1 : 0));
    _sessionScores.add(score);
  }

  void nextSentence() {
    setState(() {
      if (currentSentenceIndex < sentences.length - 1) {
        currentSentenceIndex++;
      } else {
        final avg = _sessionScores.isEmpty ? 0 : _sessionScores.reduce((a, b) => a + b) / _sessionScores.length;
        final avgStars = avg >= 90 ? 3 : (avg >= 60 ? 2 : (avg > 0 ? 1 : 0));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => FinalFeedbackScreenAr(
              averageScore: avg.toDouble(),
              totalStars: avgStars,
              level: 'level1',
            ),
          ),
        );
      }

      recognizedText = '';
      score = 0.0;
      stars = 0;
      wordMatchResults.clear();
      spokenWordSequence.clear();
      matchedWordCount = 0;
    });
  }

  List<InlineSpan> buildHighlightedSentence() {
    final sentence = currentSentence["text"]!;
    final words = sentence.split(RegExp(r'\s+'));

    return words.asMap().entries.map((entry) {
      final idx = entry.key;
      final w = entry.value;
      final clean = w.replaceAll(RegExp(r'[^ء-ي]'), '');
      Color color = Colors.black;

      if (isListening && idx < matchedWordCount)
        color = Colors.blue;
      else if (!isListening && recognizedText.isNotEmpty)
        color = (wordMatchResults[clean] ?? false) ? Colors.green : Colors.red;

      return TextSpan(
        text: '$w ',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(title: const Text('🎤 كاريوكي - المستوى ١')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Flexible(
              fit: FlexFit.loose,
              child: Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))],
                ),
                child: SingleChildScrollView(
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(children: buildHighlightedSentence()),
                  ),
                ),
              ),
            ),
            LinearProgressIndicator(
              value: (currentSentenceIndex + 1) / sentences.length.toDouble(),
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation(Color(0xFFFFA726)),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: Icon(isPlaying ? Icons.stop : Icons.volume_up),
              label: Text(isPlaying ? 'إيقاف الصوت' : 'استمع للجملة'),
              onPressed: playAudio,
              style: ElevatedButton.styleFrom(
                backgroundColor: isPlaying ? Color(0xFFFFAAAA) : Color(0xFFFFE7B0),
                foregroundColor: Colors.black,
                minimumSize: Size(w * 0.8, 44),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: Icon(isListening ? Icons.stop : Icons.mic),
              label: Text(isListening ? 'إيقاف' : 'ابدأ التحدث'),
              onPressed: () {
                if (isListening) {
                  speech.stop();
                  setState(() => isListening = false);
                } else {
                  startListening();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isListening ? Color(0xFFFFCCCC) : Color(0xFFCCFFCC),
                foregroundColor: Colors.black,
                minimumSize: Size(w * 0.8, 44),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

int levenshtein(String s1, String s2) {
  final dp = List.generate(s1.length + 1, (_) => List.filled(s2.length + 1, 0));
  for (var i = 0; i <= s1.length; i++) dp[i][0] = i;
  for (var j = 0; j <= s2.length; j++) dp[0][j] = j;
  for (var i = 1; i <= s1.length; i++) {
    for (var j = 1; j <= s2.length; j++) {
      final cost = s1[i - 1] == s2[j - 1] ? 0 : 1;
      dp[i][j] = [dp[i - 1][j] + 1, dp[i][j - 1] + 1, dp[i - 1][j - 1] + cost].reduce((a, b) => a < b ? a : b);
    }
  }
  return dp[s1.length][s2.length];
}
