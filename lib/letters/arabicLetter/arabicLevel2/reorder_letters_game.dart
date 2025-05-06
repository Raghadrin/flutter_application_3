import 'package:flutter/material.dart';

class ReorderLettersGame extends StatefulWidget {
  const ReorderLettersGame({super.key});

  @override
  _ReorderLettersGameState createState() => _ReorderLettersGameState();
}

class _ReorderLettersGameState extends State<ReorderLettersGame> {
  final List<Map<String, dynamic>> words = [
    {
      "category": "🍎 فواكه",
      "word": "تفاحة",
      "image": "images/apple.png",
    },
    {
      "category": "📚 أشياء",
      "word": "كتاب",
      "image": "images/book.png",
    },
    {
      "category": "🐟 حيوانات",
      "word": "سمكة",
      "image": "images/fish.png",
    },
  ];

  int currentIndex = 0;
  late List<String> userOrder;
  String? feedbackMessage;
  Color feedbackColor = Colors.transparent;
  int? draggingIndex;

  @override
  void initState() {
    super.initState();
    _loadWord();
  }

  void _loadWord() {
    userOrder = List<String>.from(currentWord.split('')..shuffle());
    feedbackMessage = null;
    feedbackColor = Colors.transparent;
  }

  String get currentWord => words[currentIndex]['word'];
  String get currentImage => words[currentIndex]['image'];
  String get currentCategory => words[currentIndex]['category'];

  void _checkAnswer() {
    final isCorrect = userOrder.reversed.join() == currentWord;
    setState(() {
      feedbackMessage = isCorrect ? "إجابة صحيحة ✅" : "إجابة خاطئة ❌";
      feedbackColor = isCorrect ? Colors.green : Colors.red;
    });
  }

  void _nextWord() {
    if (currentIndex < words.length - 1) {
      setState(() {
        currentIndex++;
        _loadWord();
      });
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text("أحسنت!"),
          content: Text("أنهيت جميع الكلمات 🎉"),
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
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7ED),
      appBar: AppBar(
        backgroundColor: Colors.orangeAccent,
        title: const Text("رتب الحروف"),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                currentCategory,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Image.asset(currentImage, height: 140),
              SizedBox(height: 20),
              Center(
                child: Text(
                  "قم بترتيب الحروف لتكوين الكلمة",
                  style: TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 10),
              Text(
                currentWord,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 15),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 10,
                runSpacing: 10,
                children: List.generate(userOrder.length, (index) {
                  return DragTarget<String>(
                    builder: (context, candidateData, rejectedData) =>
                        Draggable<String>(
                      data: userOrder[index],
                      feedback: Material(
                        color: Colors.transparent,
                        child: _buildLetterBox(userOrder[index]),
                      ),
                      childWhenDragging: Opacity(
                        opacity: 0.3,
                        child: _buildLetterBox(userOrder[index]),
                      ),
                      onDragStarted: () => draggingIndex = index,
                      child: _buildLetterBox(userOrder[index]),
                    ),
                    onAcceptWithDetails: (draggedLetter) {
                      setState(() {
                        final letter = userOrder.removeAt(draggingIndex!);
                        userOrder.insert(index, letter);
                        draggingIndex = null;
                      });
                    },
                  );
                }),
              ),
              SizedBox(height: 25),
              ElevatedButton(
                onPressed: _checkAnswer,
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 190, 240, 192),
                    padding:
                        EdgeInsets.symmetric(horizontal: 32, vertical: 12)),
                child: Text("تحقق"),
              ),
              if (feedbackMessage != null)
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: feedbackColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      feedbackMessage!,
                      style: TextStyle(color: Colors.white, fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              if (feedbackMessage != null && feedbackColor == Colors.green)
                ElevatedButton(
                  onPressed: _nextWord,
                  style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color.fromARGB(255, 249, 200, 121)),
                  child: Text("التالي"),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLetterBox(String letter) {
    return Container(
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.orange.shade100,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.deepOrange),
      ),
      child: Text(
        letter,
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }
}
