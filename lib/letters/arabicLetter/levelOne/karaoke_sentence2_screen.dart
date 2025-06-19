// Arabic Karaoke Level 2 Screen (Modified to Match English Structure + Categories)

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'FinalFeedbackScreenAr.dart';
import 'evaluation2_screen.dart';

class KaraokeSentenceLevel2Screen extends StatefulWidget {
  const KaraokeSentenceLevel2Screen({super.key});

  @override
  State<KaraokeSentenceLevel2Screen> createState() => _KaraokeSentenceLevel2ScreenState();
}

class _KaraokeSentenceLevel2ScreenState extends State<KaraokeSentenceLevel2Screen> with TickerProviderStateMixin {
  late stt.SpeechToText speech;
  late AudioPlayer audioPlayer;
  bool isListening = false;
  bool isPlaying = false;

  int currentSentenceIndex = 0;
  String recognizedText = '';
  int matchedWordCount = 0;
  double totalScore = 0.0;
  int totalStars = 0;
  double score = 0;
  int stars = 0;

  Map<String, bool> wordMatchResults = {};
  List<String> spokenWordSequence = [];
  final List<double> _sessionScores = [];

  final List<Map<String, String>> sentences = [
    {
      "text": "انتقل عمر مع عائلته إلى مدينة جديدة. في أول يوم في المدرسة، شعر بالخجل. جلس في المقعد الأخير يراقب زملاءه وهم يتحدثون. ضحك البعض على رسمة قام برسمها، فشعر بالحزن،وتساءل: هل سأبقى وحيدًا ؟",
      "audio": "audio/omar1.mp3"
    },
    {
      "text": 'في اليوم التالي، رأى عمر طفلًا يجلس وحده تحت شجرة. اقترب منه وقال: مرحبًا، هل أستطيع الجلوس؟ رد الطفل مبتسمًا: بالطبع، اسمي إياد، وأنت؟ ورد عمر: أنا عمر، وشعر عمر بالراحة لأول مرة.',
      "audio": "audio/omar2.mp3"
    },
    {
      "text": 'مع الوقت، أصبح عمر وإياد صديقين. شاركا في مسابقة للسيارات وفازا. قال عمر: "أنا سعيدٌ بصداقتنا." ابتسم إياد وقال: "وأنا سعيد كذلك بها."',
      "audio": "audio/omar3.mp3"
    }
  ];

  final Map<String, Map<String, String>> wordCategoriesLevel2Ar = {
    "عمر": {"category": "أشخاص", "description": "اسم الشخصية الرئيسية في القصة."},
    "إياد": {"category": "أشخاص", "description": "اسم الصديق الجديد لعمر."},
    "المدرسة": {"category": "أماكن", "description": "مكان التعليم والدراسة."},
    "شجرة": {"category": "أماكن", "description": "نبات طويل يوفر الظل."},
    "الراحة": {"category": "مشاعر", "description": "شعور بالطمأنينة والاستقرار."},
    "الخجل": {"category": "مشاعر", "description": "شعور بالخوف أو التردد في المواقف الاجتماعية."},
    "الحزن": {"category": "مشاعر", "description": "شعور بالأسى أو الألم العاطفي."},
    "ابتسم": {"category": "أفعال", "description": "تعبير عن الفرح أو الارتياح."},
    "شارك": {"category": "أفعال", "description": "دلالة على المشاركة في نشاط."},
    "جلس": {"category": "أفعال", "description": "فعل الجلوس على مقعد."},
    "يراقب": {"category": "أفعال", "description": "يتابع ما يحدث حوله."},
    "ضحك": {"category": "أفعال", "description": "تعبير عن التسلية أو الاستهزاء."},
    "رسم": {"category": "أفعال", "description": "القيام برسم صورة أو شيء."},
    "صديق": {"category": "مفاهيم", "description": "شخص يشاركك العلاقة والمشاعر الجيدة."},
    "عائلة": {"category": "مفاهيم", "description": "أفراد الأسرة المرتبطون بك."},
    "مسابقة": {"category": "أحداث", "description": "نشاط تنافسي يفوز فيه أحد المشاركين."},
    "السيارات": {"category": "أشياء", "description": "مركبات تُستخدم للتنقل والمنافسة هنا."}
  };

  Map<String, String> get currentSentence => sentences[currentSentenceIndex];

  @override
  void initState() {
    super.initState();
    speech = stt.SpeechToText();
    audioPlayer = AudioPlayer();
    audioPlayer.onPlayerComplete.listen((event) {
      setState(() => isPlaying = false);
    });
  }

  Future<void> playAudio(String path) async {
    await audioPlayer.stop();
    await audioPlayer.play(AssetSource(path));
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
        matchedWordCount = recognizedText
            .split(RegExp(r'\s+'))
            .where((w) => w.trim().isNotEmpty)
            .length;

        if (val.finalResult) {
          evaluateResult();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => Evaluation2Screen(
                recognizedText: recognizedText,
                score: score,
                stars: stars,
                level: 'level2',
                wordMatchResults: wordMatchResults,
                wordCategories: wordCategoriesLevel2Ar,
                onNext: nextSentence,
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
              level: 'level2',
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
      appBar: AppBar(title: const Text('🎤 كاريوكي - المستوى ٢')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Expanded(
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
              onPressed: () => playAudio(currentSentence["audio"]!),
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
  List<List<int>> dp = List.generate(s1.length + 1, (_) => List.filled(s2.length + 1, 0));
  for (int i = 0; i <= s1.length; i++) dp[i][0] = i;
  for (int j = 0; j <= s2.length; j++) dp[0][j] = j;
  for (int i = 1; i <= s1.length; i++) {
    for (int j = 1; j <= s2.length; j++) {
      int cost = s1[i - 1] == s2[j - 1] ? 0 : 1;
      dp[i][j] = [dp[i - 1][j] + 1, dp[i][j - 1] + 1, dp[i - 1][j - 1] + cost].reduce((a, b) => a < b ? a : b);
    }
  }
  return dp[s1.length][s2.length];
}