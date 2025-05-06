import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:audioplayers/audioplayers.dart';

class RecordWordGame extends StatefulWidget {
  const RecordWordGame({super.key});

  @override
  _RecordWordGameState createState() => _RecordWordGameState();
}

class _RecordWordGameState extends State<RecordWordGame> {
  final List<Map<String, String>> words = [
    {
      "word": "تفاحة",
      "image": "images/apple.png",
      "audio": "sounds/tuffaha.mp3",
    },
    {
      "word": "موزة",
      "image": "images/banana.png",
      "audio": "sounds/mawza.mp3",
    },
    {
      "word": "كتاب",
      "image": "images/book.png",
      "audio": "sounds/kitaab.mp3",
    },
    {
      "word": "سمكة",
      "image": "images/fish.png",
      "audio": "sounds/samakah.mp3",
    },
  ];

  final player = AudioPlayer();
  final recorder = FlutterSoundRecorder();
  late stt.SpeechToText _speech;
  String recognizedText = '';
  String? recordedPath;
  bool isRecording = false;
  String? feedbackMessage;
  Color feedbackColor = Colors.transparent;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    initRecorder();
    _speech = stt.SpeechToText();
    _speech.initialize();
  }

  Future<void> initRecorder() async {
    await recorder.openRecorder();
    Directory tempDir = await getTemporaryDirectory();
    recordedPath = '${tempDir.path}/recorded.wav';
  }

  @override
  void dispose() {
    recorder.closeRecorder();
    player.dispose();
    _speech.stop();
    super.dispose();
  }

  Future<void> playAudio(String path) async {
    await player.play(AssetSource(path));
  }

  Future<void> startRecording() async {
    await recorder.startRecorder(toFile: recordedPath!, codec: Codec.pcm16WAV);
    setState(() {
      isRecording = true;
      feedbackMessage = null;
    });
  }

  Future<void> stopRecording() async {
    await recorder.stopRecorder();
    setState(() {
      isRecording = false;
    });
  }

  Future<void> evaluateSpeech(String expected) async {
    recognizedText = '';
    feedbackMessage = null;
    feedbackColor = Colors.transparent;
    setState(() {});
    await _speech.listen(
      localeId: 'ar', // دعم عام للغة العربية
      onResult: (result) {
        recognizedText = result.recognizedWords.trim();
        if (recognizedText.contains(expected)) {
          feedbackMessage = "نطق جيد ✅";
          feedbackColor = Colors.green;
        } else {
          feedbackMessage = "❌ نطق غير دقيق: $recognizedText";
          feedbackColor = Colors.red;
        }
        setState(() {});
      },
    );
  }

  void nextWord() {
    if (currentIndex < words.length - 1) {
      setState(() {
        currentIndex++;
        feedbackMessage = null;
        feedbackColor = Colors.transparent;
        recognizedText = '';
      });
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text("أحسنت!"),
          content: Text("انتهيت من كل الكلمات 🎉"),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context), child: Text("إغلاق")),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final word = words[currentIndex];

    return Scaffold(
      backgroundColor: Color(0xFFFFF7ED),
      appBar: AppBar(
        backgroundColor: Color(0xFFFAB25F),
        title: Text("سجل الكلمة", style: TextStyle(fontFamily: 'Arial')),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Center(
          child: Column(
            children: [
              Text("الكلمة ${currentIndex + 1} من ${words.length}",
                  style: TextStyle(color: Colors.orange)),
              SizedBox(height: 10),
              Image.asset(word["image"]!, height: 130),
              SizedBox(height: 10),
              Text(word["word"]!,
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                onPressed: () => playAudio(word["audio"]!),
                icon: Icon(Icons.volume_up),
                label: Text("اسمع الكلمة"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              ),
              SizedBox(height: 20),
              isRecording
                  ? ElevatedButton.icon(
                      onPressed: stopRecording,
                      icon: Icon(Icons.stop),
                      label: Text("إيقاف التسجيل"),
                      style:
                          ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    )
                  : ElevatedButton.icon(
                      onPressed: startRecording,
                      icon: Icon(Icons.mic),
                      label: Text("سجل الكلمة"),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber),
                    ),
              SizedBox(height: 15),
              ElevatedButton.icon(
                onPressed: () => evaluateSpeech(word["word"]!),
                icon: Icon(Icons.record_voice_over),
                label: Text("قيّم نطقي"),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orangeAccent),
              ),
              SizedBox(height: 20),
              if (recognizedText.isNotEmpty)
                Text(
                  'الكلمة التي تم التعرف عليها: $recognizedText',
                  style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                  textAlign: TextAlign.center,
                ),
              SizedBox(height: 10),
              if (feedbackMessage != null)
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: feedbackColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    feedbackMessage!,
                    style: TextStyle(
                        color: Colors.orangeAccent,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: nextWord,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                child: Text("التالي"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
