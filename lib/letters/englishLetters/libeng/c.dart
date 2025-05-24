import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:lottie/lottie.dart';

class HelloWordScreen extends StatefulWidget {
  const HelloWordScreen({super.key});

  @override
  State<HelloWordScreen> createState() => _HelloWordScreenState();
}

class _HelloWordScreenState extends State<HelloWordScreen> {
  final FlutterTts flutterTts = FlutterTts();
  final AudioPlayer _player = AudioPlayer();

  bool isConnecting = false;
  bool callStarted = false;
  String word = '';
  String message = '';
  String animationPath = '';
  int key = 0;

  final List<Map<String, String>> wordCalls = [
    {
      "word": "Brave",
      "message": "You face your fears like a true hero! That’s amazing bravery!",
      "animation": "images/Brave.json"
    },
    {
      "word": "Happy",
      "message": "Your smile is sunshine. You make others feel good just by being you!",
      "animation": "images/Happy.json"
    },
    {
      "word": "Creative",
      "message": "Your ideas are magical — the world needs your imagination!",
      "animation": "images/Creative.json"
    },
    {
      "word": "Kind",
      "message": "Kindness is your superpower. You make the world warmer!",
      "animation": "images/Kind.json"
    },
    {
      "word": "Confident",
      "message": "You believe in yourself, and that’s what makes you unstoppable!",
      "animation": "images/Confident.json"
    },
  ];

  Future<void> startCall() async {
    final selected = (wordCalls..shuffle()).first;
    setState(() {
      word = selected["word"]!;
      message = selected["message"]!;
      animationPath = selected["animation"]!;
      isConnecting = true;
    });

    await _player.play(AssetSource('audio/ring.mp3'));
    await Future.delayed(const Duration(seconds: 9));

    setState(() {
      isConnecting = false;
      callStarted = true;
      key++;
    });

    await flutterTts.setLanguage("en-US");
    await flutterTts.setSpeechRate(0.35);
    await flutterTts.speak("Hello! I’m $word. $message");
  }

  void tryAnother() {
    setState(() {
      callStarted = false;
      isConnecting = false;
    });
  }

  @override
  void dispose() {
    flutterTts.stop();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange.shade50,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 700),
        child: isConnecting
            ? buildConnectingScreen()
            : callStarted
                ? buildCallScreen()
                : buildStartScreen(),
      ),
    );
  }

  Widget buildConnectingScreen() {
    return Center(
      key: const ValueKey('connecting'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.ring_volume, size: 80, color: Colors.deepOrange),
          SizedBox(height: 20),
          Text(
            "Connecting...",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget buildCallScreen() {
    return Center(
      key: ValueKey(key),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(animationPath, width: 180, height: 180),
          const SizedBox(height: 20),
          AnimatedContainer(
            duration: const Duration(seconds: 1),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.shade200,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text("📞 Hello! I’m $word",
                style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 24),
            child: Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87)),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: tryAnother,
            icon: const Icon(Icons.refresh),
            label: const Text("Try another"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              textStyle: const TextStyle(fontSize: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildStartScreen() {
    return Center(
      key: const ValueKey('start'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.phone_in_talk, size: 120, color: Colors.green),
          const SizedBox(height: 30),
          const Text("Who's calling?",
              style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown)),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: startCall,
            icon: const Icon(Icons.phone),
            label: const Text("Answer Call"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              textStyle: const TextStyle(fontSize: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
          ),
        ],
      ),
    );
  }
}
