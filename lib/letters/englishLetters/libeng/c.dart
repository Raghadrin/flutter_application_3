import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:lottie/lottie.dart';
import 'particle_background.dart';

class HelloWordScreen extends StatefulWidget {
  const HelloWordScreen({super.key});

  @override
  State<HelloWordScreen> createState() => _HelloWordScreenState();
}

class _HelloWordScreenState extends State<HelloWordScreen>
    with TickerProviderStateMixin {
  final FlutterTts flutterTts = FlutterTts();
  final AudioPlayer _player = AudioPlayer();

  bool isConnecting = false;
  bool callStarted = false;
  bool _fadeIn = false;
  String word = '';
  String message = '';
  String animationPath = '';
  int key = 0;

  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

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

  @override
  void initState() {
    super.initState();
    flutterTts.setLanguage("en-US");
    flutterTts.setSpeechRate(0.35);
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOut),
    );
  }

  Future<void> startCall() async {
    final selected = (wordCalls..shuffle()).first;
    setState(() {
      word = selected["word"]!;
      message = selected["message"]!;
      animationPath = selected["animation"]!;
      isConnecting = true;
    });

    try {
      await _player.play(AssetSource('audio/ring.mp3'));
      await Future.delayed(const Duration(seconds: 9));
    } catch (e) {
      print("Error playing ring sound: $e");
    }

    setState(() {
      isConnecting = false;
      callStarted = true;
      key++;
      _fadeIn = false;
    });

    _slideController.reset();
    await Future.delayed(const Duration(milliseconds: 100));
    setState(() {
      _fadeIn = true;
    });
    _slideController.forward();

    await flutterTts.awaitSpeakCompletion(true);
    await flutterTts.speak("Hello! I’m $word. $message");
  }

  void tryAnother() {
    setState(() {
      callStarted = false;
      isConnecting = false;
      _fadeIn = false;
    });
  }

  @override
  void dispose() {
    flutterTts.stop();
    _player.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(seconds: 4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange.shade100, Colors.yellow.shade100],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          const ParticleBackground(),
          Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 700),
              child: isConnecting
                  ? buildConnectingScreen()
                  : callStarted
                      ? buildCallScreen()
                      : buildStartScreen(),
            ),
          ),
        ],
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
    return AnimatedOpacity(
      opacity: _fadeIn ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 700),
      child: SlideTransition(
        position: _slideAnimation,
        child: Center(
          key: ValueKey(key),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Hero(
                tag: 'lottie_$word',
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.deepOrangeAccent, width: 2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Lottie.asset(animationPath, width: 180, height: 180),
                ),
              ),
              const SizedBox(height: 24),
              Hero(
                tag: 'title_$word',
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.shade200,
                        blurRadius: 6,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    "📞 Hello! I’m $word",
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFB3541E),
                      shadows: [
                        Shadow(
                          blurRadius: 2,
                          color: Colors.white,
                          offset: Offset(1, 1),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: tryAnother,
                icon: const Icon(Icons.refresh),
                label: const Text("Try another"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  textStyle: const TextStyle(fontSize: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ],
          ),
        ),
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              textStyle: const TextStyle(fontSize: 20),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
            ),
          ),
        ],
      ),
    );
  }
}
