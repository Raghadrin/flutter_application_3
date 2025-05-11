import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';

class FeelingsScreen extends StatefulWidget {
  const FeelingsScreen({super.key});

  @override
  State<FeelingsScreen> createState() => _FeelingsScreenState();
}

class _FeelingsScreenState extends State<FeelingsScreen>
    with TickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();
  late AnimationController _foxController;
  late AnimationController _textController;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _foxController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _textController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _confettiController = ConfettiController(duration: const Duration(seconds: 1));

    _foxController.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      _textController.forward();
    });

    _playIntro();
  }

  Future<void> _playIntro() async {
    try {
      await _audioPlayer.play(AssetSource('audio/fox_intro.mp3'));
    } catch (e) {
      debugPrint('Error playing intro: $e');
    }
  }

  @override
  void dispose() {
    _foxController.dispose();
    _textController.dispose();
    _audioPlayer.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _showSupportDialog(
    BuildContext context,
    String feeling,
    String message,
    String animationPath,
    String audioFileName,
    Color backgroundColor,
  ) {
    showDialog(
      context: context,
      builder: (_) {
        Future.delayed(const Duration(milliseconds: 300), () async {
          await _audioPlayer.stop();
          try {
            await _audioPlayer.play(AssetSource('audio/$audioFileName'));
          } catch (e) {
            debugPrint('Audio play failed: $e');
          }
        });

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
          child: Stack(
            alignment: Alignment.center,
            children: [
              _buildAnimatedBackground(),
              Container(
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.all(24),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Lottie.asset(animationPath, width: 180, height: 180),
                      const SizedBox(height: 20),
                      Text(
                        feeling,
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrange,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.deepOrange, width: 2),
                        ),
                        child: Text(
                          message,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w500,
                            height: 1.4,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: () {
                          _confettiController.play();
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
                        ),
                        child: const Text("Thanks, Fox!", style: TextStyle(fontSize: 22)),
                      ),
                    ],
                  ),
                ),
              ),
              ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                emissionFrequency: 0.6,
                numberOfParticles: 20,
                shouldLoop: false,
                colors: [Colors.orange, Colors.deepOrange, Colors.white],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAnimatedBackground() {
    return CustomPaint(
      painter: BokehPainter(animation: _foxController),
      size: Size.infinite,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange[50],
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        title: const Text("How Are You Feeling?",
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            FadeTransition(
              opacity: _foxController,
              child: Lottie.asset('images/happy_fox.json', width: 180, height: 180),
            ),
            const SizedBox(height: 20),
            FadeTransition(
              opacity: _textController,
              child: const Text(
                "Hey buddy,\nI'm your math fox friend!\nHow are you feeling today?",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, height: 1.5),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                children: [
                  FeelingButton(
                    label: "I'm Happy!",
                    message: "You’re doing great!",
                    animationPath: "images/Happy.json",
                    audioFileName: "youre_doing_great.mp3",
                    backgroundColor: Colors.yellow[100]!,
                    onTap: _showSupportDialog,
                  ),
                  FeelingButton(
                    label: "I'm Confused...",
                    message: "Hmm… that's okay! Let's figure it out together.",
                    animationPath: "images/Confused.json",
                    audioFileName: "lets_figure_together.mp3",
                    backgroundColor: Colors.blue[100]!,
                    onTap: _showSupportDialog,
                  ),
                  FeelingButton(
                    label: "I'm Frustrated",
                    message: "Breathe, my friend. Mistakes help you grow!",
                    animationPath: "images/Angry.json",
                    audioFileName: "breathe.mp3",
                    backgroundColor: Colors.red[100]!,
                    onTap: _showSupportDialog,
                  ),
                  FeelingButton(
                    label: "I'm Proud!",
                    message: "You should be! You are amazing!",
                    animationPath: "images/Stars.json",
                    audioFileName: "you_are_amazing.mp3",
                    backgroundColor: Colors.green[100]!,
                    onTap: _showSupportDialog,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FeelingButton extends StatefulWidget {
  final String label;
  final String message;
  final String animationPath;
  final String audioFileName;
  final Color backgroundColor;
  final Function(BuildContext, String, String, String, String, Color) onTap;

  const FeelingButton({
    super.key,
    required this.label,
    required this.message,
    required this.animationPath,
    required this.audioFileName,
    required this.backgroundColor,
    required this.onTap,
  });

  @override
  State<FeelingButton> createState() => _FeelingButtonState();
}

class _FeelingButtonState extends State<FeelingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _bounceController;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
      lowerBound: 0.0,
      upperBound: 0.1,
    );
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  Future<void> _onTap() async {
    await _bounceController.forward();
    await _bounceController.reverse();
    widget.onTap(
      context,
      widget.label,
      widget.message,
      widget.animationPath,
      widget.audioFileName,
      widget.backgroundColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: AnimatedBuilder(
        animation: _bounceController,
        builder: (context, child) {
          return Transform.scale(
            scale: 1 + _bounceController.value,
            child: child,
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFFFA726), width: 2),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(widget.animationPath, width: 80, height: 80),
              const SizedBox(height: 10),
              Text(
                widget.label,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BokehPainter extends CustomPainter {
  final Animation<double> animation;
  final random = Random();

  BokehPainter({required this.animation}) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (int i = 0; i < 25; i++) {
      final x = random.nextDouble() * size.width;
      final y = (random.nextDouble() * size.height +
              (animation.value * 100)) %
          size.height;
      final opacity = 0.5 + 0.5 * sin(animation.value * 2 * pi + i);
      paint.color = Colors.white.withOpacity(opacity);
      canvas.drawCircle(Offset(x, y), 5, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
