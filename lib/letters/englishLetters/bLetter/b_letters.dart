import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_application_3/letters/englishLetters/bLetter/b_recog_g.dart';

class LetterBTracingScreen extends StatefulWidget {
  const LetterBTracingScreen({super.key});

  @override
  _LetterBTracingScreenState createState() => _LetterBTracingScreenState();
}

class _LetterBTracingScreenState extends State<LetterBTracingScreen> {
  final List<Offset?> _points = [];
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Play letter sound
  void _playSound() async {
    await _audioPlayer.play(AssetSource('sounds/buh.mp3'));
  }

  // Clear the drawing
  void _clearDrawing() {
    setState(() {
      _points.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFF7E7),
      appBar: AppBar(
        title: Text("Trace Letter 'b'"),
        backgroundColor: Colors.deepOrange,
      ),
      body: Column(
        children: [
          //SizedBox(height: 10),

          // Large Letter 'b' Guide
          Center(
            child: Text(
              "b",
              style: TextStyle(
                fontSize: 150,
                fontWeight: FontWeight.bold,
                color: Colors.orangeAccent,
                fontFamily: 'OpenDyslexic',
              ),
            ),
          ),
          //SizedBox(height: 10),

          // Tracing Box
          Container(
            height: 230,
            width:
                MediaQuery.of(context).size.width * 0.9, // 90% of screen width
            decoration: BoxDecoration(
              border: Border.all(color: Colors.deepOrange, width: 3),
              borderRadius: BorderRadius.circular(15),
              color: Colors.white,
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return GestureDetector(
                  onPanUpdate: (details) {
                    setState(() {
                      RenderBox renderBox =
                          context.findRenderObject() as RenderBox;
                      Offset localPosition =
                          renderBox.globalToLocal(details.globalPosition);

                      // Keep drawing inside the box boundaries
                      if (localPosition.dx >= 0 &&
                          localPosition.dx <= constraints.maxWidth &&
                          localPosition.dy >= 0 &&
                          localPosition.dy <= constraints.maxHeight) {
                        _points.add(localPosition);
                      }
                    });
                  },
                  onPanEnd: (details) {
                    _points.add(null); // Marks end of stroke
                  },
                  child: CustomPaint(
                    painter: TracingPainter(_points),
                    size: Size(constraints.maxWidth, constraints.maxHeight),
                  ),
                );
              },
            ),
          ),

          SizedBox(height: 10),

          // Word Association (Ball & Bat)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  Image.asset("images/ball.png", height: 80),
                  Text("Ball",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              SizedBox(width: 40),
              Column(
                children: [
                  Image.asset("images/bat.png", height: 80),
                  Text("Bat",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),

          SizedBox(height: 20),

          // Control Buttons (Sound & Retry)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Play Sound
              ElevatedButton(
                onPressed: _playSound,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.volume_up, color: Colors.orange),
                    SizedBox(width: 5),
                    Text("Hear 'b'",
                        style: TextStyle(fontSize: 18, color: Colors.orange)),
                  ],
                ),
              ),
              SizedBox(width: 20),

              // Retry (Clear)
              ElevatedButton(
                onPressed: _clearDrawing,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.refresh),
                    SizedBox(width: 5),
                    Text("Retry", style: TextStyle(fontSize: 18)),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 20),

          // Next Button
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => LetterBRecognitionScreen()));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 40),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
            ),
            child: Text(
              "Next",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Painter for Drawing
class TracingPainter extends CustomPainter {
  final List<Offset?> points;

  TracingPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(TracingPainter oldDelegate) => true;
}
