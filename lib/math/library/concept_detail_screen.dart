import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'dart:math';

class ConceptDetailScreen extends StatefulWidget {
  final Map<String, String> concept;

  const ConceptDetailScreen({super.key, required this.concept});

  @override
  State<ConceptDetailScreen> createState() => _ConceptDetailScreenState();
}

class _ConceptDetailScreenState extends State<ConceptDetailScreen> with SingleTickerProviderStateMixin {
  final FlutterTts _flutterTts = FlutterTts();
  late AnimationController _tipController;
  late Animation<Offset> _cloudOffset;

  @override
  void initState() {
    super.initState();
    _tipController = AnimationController(vsync: this, duration: const Duration(seconds: 10))..repeat(reverse: true);
    _cloudOffset = Tween<Offset>(
      begin: const Offset(-1.2, -0.6),
      end: const Offset(1.2, -0.6),
    ).animate(CurvedAnimation(parent: _tipController, curve: Curves.easeInOut));
    _setupTTS();
  }

  Future<void> _setupTTS() async {
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setSpeechRate(0.5);
  }

  @override
  void dispose() {
    _tipController.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  void _speak(String text) async {
    await _setupTTS();
    await _flutterTts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    final concept = widget.concept;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFA726),
        title: Text(concept["title"] ?? "Math Concept"),
      ),
      backgroundColor: const Color(0xFFFFF6ED),
      body: Stack(
        children: [
          const Positioned.fill(child: GeometricBackground()),
          SlideTransition(
            position: _cloudOffset,
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.3),
                        blurRadius: 12,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: Text(
                    concept["tip"] ?? '',
                    style: const TextStyle(fontSize: 18, fontStyle: FontStyle.italic, color: Colors.black87),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(concept["emoji"] ?? "📘", style: const TextStyle(fontSize: 80)),
                  const SizedBox(height: 16),
                  if (concept.containsKey("image"))
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.deepOrange, width: 3),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.asset(
                          "images/${concept["image"]}",
                          height: 160,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  Text(concept["title"] ?? "", style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  Text(concept["content"] ?? "", style: const TextStyle(fontSize: 20), textAlign: TextAlign.center),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    onPressed: () => _speak(concept["content"] ?? ""),
                    icon: const Icon(Icons.volume_up),
                    label: const Text("Hear Explanation", style: TextStyle(fontSize: 18)),
                  ),
                  const SizedBox(height: 12),
                  if (concept.containsKey("real")) ...[
                    Container(
                      margin: const EdgeInsets.only(top: 20),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.deepOrange, width: 2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: AnimatedTextKit(
                        isRepeatingAnimation: false,
                        animatedTexts: [
                          TypewriterAnimatedText(
                            concept["real"] ?? "",
                            textStyle: const TextStyle(
                              fontSize: 16,
                              color: Colors.deepOrange,
                              fontWeight: FontWeight.w600,
                              shadows: [Shadow(offset: Offset(1.5, 1.5), blurRadius: 2.0, color: Colors.black26)],
                            ),
                            speed: const Duration(milliseconds: 40),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.deepOrange,
                        side: const BorderSide(color: Colors.deepOrange),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      onPressed: () => _speak(concept["real"] ?? ""),
                      icon: const Icon(Icons.tips_and_updates),
                      label: const Text("Hear Tip", style: TextStyle(fontSize: 16)),
                    ),
                  ]
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class GeometricBackground extends StatefulWidget {
  const GeometricBackground({super.key});
  @override
  State<GeometricBackground> createState() => _GeometricBackgroundState();
}

class _GeometricBackgroundState extends State<GeometricBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(seconds: 6), vsync: this)..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: GeometricPainter(_controller));
  }
}

class _Star {
  final Offset position;
  final double phase;
  _Star({required this.position, required this.phase});
}

class GeometricPainter extends CustomPainter {
  final Animation<double> animation;
  final List<_Star> _stars;

  GeometricPainter(this.animation)
      : _stars = List.generate(
          25,
          (i) => _Star(
            position: Offset(Random().nextDouble(), Random().nextDouble()),
            phase: Random().nextDouble() * 2 * pi,
          ),
        ),
        super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (final star in _stars) {
      final glow = (sin(animation.value * 2 * pi + star.phase) + 1) / 2;
      paint
        ..color = Colors.white.withOpacity(glow.clamp(0.2, 0.8))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      final position = Offset(star.position.dx * size.width, star.position.dy * size.height);
      canvas.drawCircle(position, 4, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
