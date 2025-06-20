import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'FinalFeedbackScreenAr.dart';
import 'evaluation2_screen.dart';

class KaraokeSentenceLevel3Screen extends StatefulWidget {
  const KaraokeSentenceLevel3Screen({super.key});

  @override
  State<KaraokeSentenceLevel3Screen> createState() => _KaraokeSentenceLevel3ScreenState();
}

class _KaraokeSentenceLevel3ScreenState extends State<KaraokeSentenceLevel3Screen> with TickerProviderStateMixin {
  late AudioPlayer audioPlayer;
  late stt.SpeechToText speech;
  bool isListening = false;
  bool isPlaying = false;
  String recognizedText = "";
  double score = 0.0;
  int stars = 0;
  int currentSentenceIndex = 0;
  int matchedWordCount = 0;

  Map<String, bool> wordMatchResults = {};
  List<String> spokenWordSequence = [];
  late Map<String, List<String>> categoryIssues;
  final List<double> _sessionScores = [];

  final Map<String, Map<String, String>> wordCategoriesLevel3Ar = {
    'سامر': {'category': 'أشخاص', 'description': 'اسم ولد بطل القصة.'},
    'زميلًا': {'category': 'أشخاص', 'description': 'صديق أو طالب في الصف.'},
    'المعلمة': {'category': 'أشخاص', 'description': 'التي تدرّس الطلاب.'},
    'العلوم': {'category': 'مفاهيم', 'description': 'مجال دراسي عن الطبيعة والتجارب.'},
    'الرياضيات': {'category': 'مفاهيم', 'description': 'فرع من فروع العلم يختص بالأعداد والحساب.'},
    'ورقة': {'category': 'أشياء', 'description': 'شيء يُكتب عليه.'},
    'الارتباك': {'category': 'مشاعر', 'description': 'حالة من القلق أو التشويش.'},
    'العشاء': {'category': 'أحداث/زمن', 'description': 'الوجبة الأخيرة من اليوم.'},
    'المنزل': {'category': 'أماكن', 'description': 'مكان السكن والعيش.'},
    'الصدق': {'category': 'قيم', 'description': 'قول الحقيقة والتصرف بأمانة.'},
    'الاحترام': {'category': 'قيم', 'description': 'تقدير الآخرين ومعاملتهم بلطف.'},
    'شعر': {'category': 'أفعال', 'description': 'إحساس داخلي أو عاطفة.'},
    'فكر': {'category': 'أفعال', 'description': 'قام بعملية عقلية للتفكير.'},
    'أخبر': {'category': 'أفعال', 'description': 'نقل معلومة لشخص آخر.'},
    'شكرته': {'category': 'أفعال', 'description': 'عبّر عن الامتنان والتقدير.'},
    'تحدثت': {'category': 'أفعال', 'description': 'تكلمت مع شخص.'},
    'شرحَت': {'category': 'أفعال', 'description': 'فسّرت أو وضّحت معلومة.'},
    'أثنت': {'category': 'أفعال', 'description': 'مدحت أو عبّرت عن إعجاب.'},
    'شجاعًا': {'category': 'صفات', 'description': 'صفة لمن يتصرف بشجاعة وقوة قلب.'},
    'صامتًا': {'category': 'صفات', 'description': 'لا يتكلم، في حالة سكوت.'},
    'قلق': {'category': 'مشاعر', 'description': 'شعور بالخوف أو الانزعاج.'},
    'واشٍ': {'category': 'صفات/سلبية', 'description': 'من يُبلّغ عن الآخرين بشكل سلبي.'}
  };

  final List<Map<String, String>> sentences = [
    {
      "text":
          "كان سامر فتى ذكيًا يحب القراءة والعلوم. في يوم امتحان الرياضيات، رأى زميلًا يغش من ورقة طالب آخر. شعر بالارتباك، ولم يعرف كيف يتصرف. حاول التركيز، ولم يستطع.",
      "audio": "audio/samer1.mp3"
    },
    {
      "text":
          "عاد سامر إلى المنزل وهو قلق. فكر كثيرًا: هل يخبر المعلمة أم يصمت؟ خاف أن يظن زملاؤه أنه واشٍ. بقي صامتًا أثناء العشاء، ولم يكن مستعدًا للكلام.",
      "audio": "audio/samer2.mp3"
    },
    {
      "text":
          "في اليوم التالي، أخبر سامر المعلمة بما رأى. شكرته وقالت إنها ستتصرف بالشكل المناسب. تحدثت مع الطالب وشرحَت له أهمية الأمانة. ثم أخبرت سامرًا أن تصرفه كان شجاعًا، وأثنت عليه أمام زملائه. شعر سامر بالفخر، لأنه اختار الصدق ونال احترام الجميع.",
      "audio": "audio/samer3.mp3"
    }
  ];

  Map<String, String> get currentSentence => sentences[currentSentenceIndex];

  @override
  void initState() {
    super.initState();
    audioPlayer = AudioPlayer();
    speech = stt.SpeechToText();
    audioPlayer.onPlayerComplete.listen((_) => setState(() => isPlaying = false));
  }

  Future<void> toggleAudio(String path) async {
    if (isPlaying) {
      await audioPlayer.stop();
      setState(() => isPlaying = false);
    } else {
      setState(() => isPlaying = true);
      await audioPlayer.play(AssetSource(path));
    }
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
      listenFor: const Duration(seconds: 90),
      pauseFor: const Duration(seconds: 5),
      onResult: (val) async {
        recognizedText = val.recognizedWords;
        updateMatchedWords();
        matchedWordCount = recognizedText.split(RegExp(r'\s+')).where((w) => w.trim().isNotEmpty).length;

        if (val.finalResult) {
          await evaluateResult();
          if (!mounted) return;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => Evaluation2Screen(
                recognizedText: recognizedText,
                score: score,
                stars: stars,
                level: 'level3',
                wordMatchResults: wordMatchResults,
                wordCategories: wordCategoriesLevel3Ar,
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

  Future<void> evaluateResult() async {
    int correct = wordMatchResults.values.where((v) => v).length;
    int total = wordMatchResults.length;
    score = total > 0 ? (correct / total) * 100 : 0.0;
    stars = score >= 90 ? 3 : (score >= 60 ? 2 : (score > 0 ? 1 : 0));
    _sessionScores.add(score);
  }

  void nextSentence() {
    setState(() {
      if (currentSentenceIndex < sentences.length - 1) {
        currentSentenceIndex++;
      } else {
        final avgPct = _sessionScores.isEmpty
            ? 0.0
            : _sessionScores.reduce((a, b) => a + b) / _sessionScores.length;
        final avgStars = avgPct >= 90 ? 3 : (avgPct >= 60 ? 2 : (avgPct > 0 ? 1 : 0));

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => FinalFeedbackScreenAr(
              averageScore: avgPct,
              totalStars: avgStars,
              level: 'level3',
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
      appBar: AppBar(title: const Text('🎤 كاريوكي - المستوى ٣')),
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
              valueColor: const AlwaysStoppedAnimation(Color(0xFF4B9CD3)),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: Icon(isPlaying ? Icons.stop : Icons.volume_up),
              label: Text(isPlaying ? 'إيقاف الصوت' : 'استمع للجملة'),
              onPressed: () => toggleAudio(currentSentence["audio"]!),
              style: ElevatedButton.styleFrom(
                backgroundColor: isPlaying ? const Color(0xFFFFAAAA) : const Color(0xFFFFE7B0),
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
                backgroundColor: isListening ? const Color(0xFFFFCCCC) : const Color(0xFFCCFFCC),
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
