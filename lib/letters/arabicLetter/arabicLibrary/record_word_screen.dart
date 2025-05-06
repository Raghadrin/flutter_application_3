import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:audioplayers/audioplayers.dart';
import 'package:string_similarity/string_similarity.dart';

class ArabicRecordSentenceGame extends StatefulWidget {
  const ArabicRecordSentenceGame({super.key});

  @override
  _ArabicRecordSentenceGameState createState() => _ArabicRecordSentenceGameState();
}

class _ArabicRecordSentenceGameState extends State<ArabicRecordSentenceGame> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _recognizedText = '';
  final player = AudioPlayer();

  final List<String> sentences = [
    'العصفور يغني على الاشجار في الصباح',
    'كل لحظه تمر هي فرص جديده للنجاح',
    'حتى في اقسى اللحظات يمكن للأمل ان يولد من جديد'
  ];

  int currentSentenceIndex = 0;
  int attemptsLeft = 3;
  int correctAnswers = 0;
  int wrongAnswers = 0;

  String feedbackMessage = '';
  Color feedbackColor = Colors.transparent;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  Future<void> _startListening() async {
    bool available = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done') {
          setState(() => _isListening = false);
        }
      },
      onError: (error) {
        print('Speech error: $error');
      },
    );
    if (available) {
      setState(() {
        _isListening = true;
        _recognizedText = '';
      });
      await _speech.listen(
        localeId: 'ar_SA',
        onResult: (val) {
          setState(() {
            _recognizedText = val.recognizedWords;
          });
        },
      );
    }
  }

  void _stopListening() async {
    await _speech.stop();
    setState(() {
      _isListening = false;
    });
  }

  Future<void> _checkAnswer() async {
    if (_recognizedText.isEmpty) {
      setState(() {
        feedbackMessage = 'لم يتم تسجيل صوت!';
        feedbackColor = Colors.orange;
      });
      return;
    }

    String correctSentence = sentences[currentSentenceIndex];

    // استخدام similarity لمقارنة الجملة المسجلة بالجملة الصحيحة
    bool isCorrect = _recognizedText.similarityTo(correctSentence) > 0.8;

    if (isCorrect) {
      setState(() {
        feedbackMessage = '✅ نطق صحيح!';
        feedbackColor = Colors.green;
        correctAnswers++;
      });
      await player.play(AssetSource('correct.mp3'));

      Future.delayed(Duration(seconds: 2), () {
        _moveToNextSentence();
      });
    } else {
      setState(() {
        attemptsLeft--;
        feedbackMessage = '❌ خطأ! محاولات متبقية: $attemptsLeft';
        feedbackColor = Colors.red;
      });
      await player.play(AssetSource('wrong.mp3'));

      if (attemptsLeft == 0) {
        setState(() {
          wrongAnswers++;
        });
        Future.delayed(Duration(seconds: 2), () {
          _moveToNextSentence();
        });
      }
    }
  }

  void _moveToNextSentence() {
    if (currentSentenceIndex < sentences.length - 1) {
      setState(() {
        currentSentenceIndex++;
        attemptsLeft = 3;
        feedbackMessage = '';
        _recognizedText = '';
      });
    } else {
      _showFinishDialog();
    }
  }

  void _showFinishDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('نتيجتك 🎉', textAlign: TextAlign.center),
        content: Text(
          'جمل صحيحة: $correctAnswers\nجمل خاطئة: $wrongAnswers',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                currentSentenceIndex = 0;
                correctAnswers = 0;
                wrongAnswers = 0;
                attemptsLeft = 3;
                feedbackMessage = '';
                _recognizedText = '';
              });
            },
            child: Text('إعادة اللعب'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _speech.stop();
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String sentence = sentences[currentSentenceIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('سجّل الجملة'),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center, // كل شي بالنص أفقيًا
              children: [
                Text(
                  'انطق الجملة التالية:',
                  style: TextStyle(fontSize: 24),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                Text(
                  sentence,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed: _isListening ? _stopListening : _startListening,
                  icon: Icon(_isListening ? Icons.stop : Icons.mic),
                  label: Text(_isListening ? 'إيقاف' : 'ابدأ التسجيل'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isListening ? Colors.red : Colors.green,
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _checkAnswer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orangeAccent,
                  ),
                  child: Text('تحقق من النطق'),
                ),
                SizedBox(height: 20),
                Text(
                  feedbackMessage,
                  style: TextStyle(
                    fontSize: 22,
                    color: feedbackColor,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 30),
                Text(
                  'محاولات متبقية: $attemptsLeft',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Text(
                  'النص المسجل: $_recognizedText',
                  style: TextStyle(
                    fontSize: 18,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
