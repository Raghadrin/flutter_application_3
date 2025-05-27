import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class NumberTracingGame extends StatefulWidget {
  const NumberTracingGame({super.key});

  @override
  State<NumberTracingGame> createState() => _NumberTracingGameState();
}

class _NumberTracingGameState extends State<NumberTracingGame> {
  final FlutterTts tts = FlutterTts();
  int currentIndex = 0;
  List<Offset> points = [];
  bool showStars = false;
  int stars = 0;

  List<double> drawingScoreHistory = [];
  double averageDrawingScore = 0;

  final List<Map<String, dynamic>> _items = List.generate(6, (index) {
    return {
      "number": "${index + 1}",
      "image": "trace_${index + 1}.png",
    };
  });

  @override
  void initState() {
    super.initState();
    _speakCurrent();
  }

  Future<void> _speak(String text) async {
    await tts.setLanguage("en-US");
    await tts.setSpeechRate(0.4);
    await tts.speak(text);
  }

  void _speakCurrent() {
    final number = _items[currentIndex]["number"];
    _speak("Can you trace number $number?");
  }

  void _evaluateDrawing() {
    int length = points.length;
    double drawingScore = (length.clamp(10, 100)) / 100.0;
    drawingScoreHistory.add(drawingScore);

    if (length > 60) {
      stars = 3;
    } else if (length > 30) {
      stars = 2;
    } else {
      stars = 1;
    }

    averageDrawingScore = drawingScoreHistory.reduce((a, b) => a + b) / drawingScoreHistory.length;

    _speak(_getDrawingComment(averageDrawingScore));

    setState(() {
      showStars = true;
    });
  }

  void _next() {
    if (currentIndex < _items.length - 1) {
      setState(() {
        currentIndex++;
        points.clear();
        showStars = false;
        stars = 0;
      });
      _speakCurrent();
    } else {
      _showFinalScoreScreen();
    }
  }

  void _resetGame() {
    setState(() {
      currentIndex = 0;
      points.clear();
      showStars = false;
      stars = 0;
      drawingScoreHistory.clear();
      averageDrawingScore = 0;
    });
    _speakCurrent();
  }

  String _getDrawingComment(double avg) {
    double percent = avg * 100;
    if (percent >= 90) {
      return "Excellent tracing!";
    } else if (percent >= 70) {
      return "Good job, keep improving!";
    } else if (percent >= 50) {
      return "You're getting there!";
    } else {
      return "💡 Let's try again and trace carefully!";
    }
  }

  int _getStarCountFromSkill(double score) {
    if (score >= 0.9) return 3;
    if (score >= 0.7) return 2;
    if (score >= 0.5) return 1;
    return 1;
  }

  void _showFinalScoreScreen() {
    String comment = _getDrawingComment(averageDrawingScore);
    int finalStars = _getStarCountFromSkill(averageDrawingScore);

    _speak("Well done! You earned $finalStars stars. $comment");

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("🎉 Final Score", textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("You traced ${_items.length} numbers",
                style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(finalStars, (index) {
                return TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: Duration(milliseconds: 400 + index * 150),
                  builder: (context, scale, child) => Transform.scale(
                    scale: scale,
                    child: child,
                  ),
                  child: const Icon(Icons.star, color: Colors.orange, size: 36),
                );
              }),
            ),
            const SizedBox(height: 12),
            Text(
              "Average Tracing Skill: ${(averageDrawingScore * 100).toStringAsFixed(1)}%",
              style: const TextStyle(fontSize: 16, color: Colors.deepOrange),
            ),
            const SizedBox(height: 6),
            Text(comment,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _resetGame();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
              child: const Text("🔁 Start Again",
                  style: TextStyle(fontSize: 18, color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = _items[currentIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFFFF6ED),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFA726),
        title: const Text("Trace the Number"),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Text("Trace number ${item['number']}",
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrange)),
          const SizedBox(height: 10),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.deepOrange, width: 3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Opacity(
                      opacity: 0.2,
                      child: Image.asset(
                        "images/new_images/${item['image']}",
                        fit: BoxFit.contain,
                      ),
                    ),
                    GestureDetector(
                      onPanUpdate: (details) {
                        setState(() => points.add(details.localPosition));
                      },
                      onPanEnd: (_) => _evaluateDrawing(),
                      child: CustomPaint(
                        painter: TracingPainter(points),
                        size: Size.infinite,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => setState(() => points.clear()),
                style:
                    ElevatedButton.styleFrom(backgroundColor: Colors.grey[300]),
                child: const Text("🧽 Clear",
                    style: TextStyle(fontSize: 18, color: Colors.black)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (showStars) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(stars, (index) {
                return TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: Duration(milliseconds: 500 + index * 200),
                  builder: (context, scale, child) => Transform.scale(
                    scale: scale,
                    child: child,
                  ),
                  child: const Icon(Icons.star, color: Colors.orange, size: 40),
                );
              }),
            ),
            const SizedBox(height: 8),
            Text(
              "Tracing Skill: ${(drawingScoreHistory.last * 100).toStringAsFixed(1)}%",
              style: const TextStyle(fontSize: 18, color: Colors.deepOrange),
            ),
            Text(
              _getDrawingComment(averageDrawingScore),
              style: const TextStyle(fontSize: 18, color: Colors.blueGrey),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _next,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
              child: const Text("Next", style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 20),
          ]
        ],
      ),
    );
  }
}

class TracingPainter extends CustomPainter {
  final List<Offset> points;

  TracingPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.orange
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 8.0;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != Offset.zero && points[i + 1] != Offset.zero) {
        canvas.drawLine(points[i], points[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
