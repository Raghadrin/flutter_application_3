// concept_detail_screen.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class ConceptDetailScreen extends StatefulWidget {
  final Map<String, String> concept;

  const ConceptDetailScreen({super.key, required this.concept});

  @override
  State<ConceptDetailScreen> createState() => _ConceptDetailScreenState();
}

class _ConceptDetailScreenState extends State<ConceptDetailScreen>
    with SingleTickerProviderStateMixin {
  final FlutterTts _flutterTts = FlutterTts();
  late AnimationController _tipController;
  late Animation<Offset> _cloudOffset;

  @override
  void initState() {
    super.initState();
    _tipController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);

    _cloudOffset = Tween<Offset>(
      begin: const Offset(-1.2, -0.6),
      end: const Offset(1.2, -0.6),
    ).animate(CurvedAnimation(
      parent: _tipController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _tipController.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  void _speak(String text) async {
    await _flutterTts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    final concept = widget.concept;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFA726),
        title: Text(concept["title"]!),
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
                    style: const TextStyle(
                      fontSize: 18,
                      fontStyle: FontStyle.italic,
                      color: Colors.black87,
                    ),
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
                  Text(
                    concept["emoji"]!,
                    style: const TextStyle(fontSize: 80),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    concept["title"]!,
                    style:
                        const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    concept["content"]!,
                    style: const TextStyle(fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                    ),
                    onPressed: () => _speak(concept["content"]!),
                    icon: const Icon(Icons.volume_up),
                    label: const Text("Hear Explanation",
                        style: TextStyle(fontSize: 18)),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class GeometricBackground extends StatelessWidget {
  const GeometricBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: GeometricPainter(),
    );
  }
}

class GeometricPainter extends CustomPainter {
  final Random _random = Random();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final colors = [
      Colors.redAccent,
      Colors.blueAccent,
      Colors.greenAccent,
      Colors.orangeAccent,
      Colors.purpleAccent,
      Colors.yellowAccent
    ];

    for (int i = 0; i < 30; i++) {
      paint.color = colors[_random.nextInt(colors.length)].withOpacity(0.3);
      final x = _random.nextDouble() * size.width;
      final y = _random.nextDouble() * size.height;
      final sizeFactor = _random.nextDouble() * 40 + 10;
      final shape = _random.nextInt(3);

      switch (shape) {
        case 0:
          canvas.drawCircle(Offset(x, y), sizeFactor / 2, paint);
          break;
        case 1:
          canvas.drawRect(
            Rect.fromCenter(
              center: Offset(x, y),
              width: sizeFactor,
              height: sizeFactor,
            ),
            paint,
          );
          break;
        case 2:
          final path = Path();
          path.moveTo(x, y - sizeFactor / 2);
          path.lineTo(x - sizeFactor / 2, y + sizeFactor / 2);
          path.lineTo(x + sizeFactor / 2, y + sizeFactor / 2);
          path.close();
          canvas.drawPath(path, paint);
          break;
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
