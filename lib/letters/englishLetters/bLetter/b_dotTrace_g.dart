import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_drawing_board/flutter_drawing_board.dart';

class LetterBTracingDotsScreen extends StatefulWidget {
  const LetterBTracingDotsScreen({super.key});

  @override
  _LetterBTracingDotsScreenState createState() =>
      _LetterBTracingDotsScreenState();
}

class _LetterBTracingDotsScreenState extends State<LetterBTracingDotsScreen> {
  final DrawingController _controller = DrawingController();
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _tracingComplete = false;

  // Play success sound
  void _playSuccessSound() async {
    await _audioPlayer.play(AssetSource('sounds/success.mp3'));
  }

  // Clear the drawing
  void _clearDrawing() {
    setState(() {
      _controller.clear();
      _tracingComplete = false;
    });
  }

  // Check if the tracing covers the dots
  void _checkTracing() {
    // Simulate checking if tracing is correct (You can refine this later)
    setState(() {
      _tracingComplete = true;
      _playSuccessSound();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFF7E7), // Light warm background
      appBar: AppBar(
        title: Text("Trace 'b' with Guide Dots"),
        backgroundColor: Colors.deepOrange,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Follow the dots to trace 'b'!",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),

          // Tracing Board with Guide Dots
          Container(
            height: 250,
            width: 250,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.deepOrange, width: 3),
              borderRadius: BorderRadius.circular(15),
              color: Colors.white,
            ),
            child: Stack(
              children: [
                Center(
                  child: Opacity(
                    opacity: 0.5, // Make the guide dots semi-transparent
                    child: Image.asset("images/dotted_b.png", height: 200),
                  ),
                ),
                DrawingBoard(
                  controller: _controller,
                  background: Container(color: Colors.transparent),
                  showDefaultActions: false,
                  onPointerUp: (_) =>
                      _checkTracing(), // Check tracing after drawing
                ),
              ],
            ),
          ),
          SizedBox(height: 20),

          // Control Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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

          // Success Message & Next Button
          if (_tracingComplete) ...[
            Text(
              "✅ Great Job! You traced 'b' correctly!",
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.green),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // TODO: Navigate to the next exercise
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 40),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
              child: Text("Next",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ],
        ],
      ),
    );
  }
}
