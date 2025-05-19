import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:audioplayers/audioplayers.dart';

class ConfidenceMessagesScreen extends StatefulWidget {
  const ConfidenceMessagesScreen({super.key});

  @override
  State<ConfidenceMessagesScreen> createState() =>
      _ConfidenceMessagesScreenState();
}

class _ConfidenceMessagesScreenState extends State<ConfidenceMessagesScreen>
    with TickerProviderStateMixin {
  final List<Map<String, String>> encouragements = [
    {
      "title": "Brave Explorer",
      "message": "Be brave, my friend. Mistakes help you grow!",
      "sound": "brave_explorer.mp3",
    },
    {
      "title": "Go at Your Speed",
      "message": "It’s okay to go slow — you are still amazing!",
      "sound": "going_slow.mp3",
    },
    {
      "title": "Mistakes Help Us",
      "message": "Mistakes are part of learning. Keep going!",
      "sound": "mistakes_steps.mp3",
    },
    {
      "title": "Puzzle Solver",
      "message": "Numbers can be tricky. Let’s solve the puzzle together!",
      "sound": "numbers_puzzles.mp3",
    },
    {
      "title": "You're a Hero!",
      "message": "You’re doing great! Keep smiling!",
      "sound": "true_heroes.mp3",
    },
  ];

  late Map<String, String> selectedMessage;
  final AudioPlayer _audioPlayer = AudioPlayer();
  final AudioPlayer _effectPlayer = AudioPlayer();
  late AnimationController _bgController;
  late AnimationController _scaleController;

  String? favoriteMessage;
  bool hasPlayedHeyBuddy = false;

  @override
  void initState() {
    super.initState();
    _bgController =
        AnimationController(vsync: this, duration: const Duration(seconds: 6))
          ..repeat();
    _scaleController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));

    selectedMessage = encouragements[0];
    WidgetsBinding.instance.addPostFrameCallback((_) => _selectRandomMessage());
  }

  Future<void> _selectRandomMessage() async {
    final random = math.Random();
    Map<String, String> newMessage;
    do {
      newMessage = encouragements[random.nextInt(encouragements.length)];
    } while (newMessage['title'] == selectedMessage['title']);

    selectedMessage = newMessage;

    await _effectPlayer.play(AssetSource('audio/pop.mp3'));

    if (!hasPlayedHeyBuddy) {
      hasPlayedHeyBuddy = true;
      await _audioPlayer.play(AssetSource('audio/Hey_buddy.mp3'));
      await Future.delayed(const Duration(seconds: 1));
    }

    await _audioPlayer.play(AssetSource('audio/${selectedMessage['sound']}'));

    _scaleController.forward(from: 0);
    setState(() {});
  }

  Future<void> _playVoice() async {
    await _audioPlayer.stop();
    await _audioPlayer.play(AssetSource('audio/${selectedMessage['sound']}'));
  }

  Future<void> _cheerAndChange() async {
    await _effectPlayer.play(AssetSource('audio/kids_cheering.mp3'));
    await _selectRandomMessage();
  }

  void _saveFavoriteMessage() {
    setState(() {
      favoriteMessage = selectedMessage['message'];
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _effectPlayer.dispose();
    _bgController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text("Fox's Special Message", style: TextStyle(fontSize: 24)),
        backgroundColor: const Color(0xFFFBCEB1),
      ),
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFFFCCBC), // Soft orange
                  Color(0xFFFAD6D6), // Champagne pink
                ],
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Fox with visible border
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border:
                              Border.all(color: Colors.deepOrange, width: 2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Lottie.asset("images/happy_fox.json",
                            width: 120, height: 120),
                      ),
                      const SizedBox(height: 20),

                      // Greeting text
                      const Text(
                        "Hey buddy,\nThis is just for you today:",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          height: 1.5,
                          color: Color(0xFFD84315), // Stronger orange
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 30),

                      // Main message card
                      ScaleTransition(
                        scale: CurvedAnimation(
                            parent: _scaleController,
                            curve: Curves.easeOutBack),
                        child: Card(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          elevation: 6,
                          margin: const EdgeInsets.symmetric(vertical: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Lottie.asset("images/Stars.json",
                                    width: 80, height: 80),
                                const SizedBox(height: 16),
                                Text(
                                  selectedMessage['title']!,
                                  style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepOrange,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  selectedMessage['message']!,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w500,
                                    height: 1.6,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                if (favoriteMessage != null)
                                  Text(
                                    "Your Favorite Message:\n$favoriteMessage",
                                    style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.green.shade700),
                                    textAlign: TextAlign.center,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Buttons

                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 20,
                          runSpacing: 16,
                          children: [
                            ElevatedButton.icon(
                              onPressed: _playVoice,
                              icon: const Icon(Icons.volume_up, size: 28),
                              label: const Text("Hear Again",
                                  style: TextStyle(fontSize: 22)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepOrange,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: _cheerAndChange,
                              icon: const Icon(Icons.refresh, size: 28),
                              label: const Text("Try Another",
                                  style: TextStyle(fontSize: 22)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: _saveFavoriteMessage,
                              icon: const Icon(Icons.star, size: 28),
                              label: const Text("Save Favorite",
                                  style: TextStyle(fontSize: 22)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amber,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
