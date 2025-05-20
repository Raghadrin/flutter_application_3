import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class EnglishLevel1Screen extends StatefulWidget {
  final String sentence;
  const EnglishLevel1Screen({super.key, required this.sentence});

  @override
  State<EnglishLevel1Screen> createState() => _EnglishLevel1ScreenState();
}

class _EnglishLevel1ScreenState extends State<EnglishLevel1Screen> {
  late FlutterTts flutterTts;
  late stt.SpeechToText speech;
  String recognizedText = '';
  Color feedbackColor = Colors.transparent;

  final List<PhonologicalExercise> exercises = [
    PhonologicalExercise(
      title: "Identify the correct sound",
      target: 'B',
      options: ['D', 'B', 'P'],
      instructions: "Listen to the sound and choose the correct letter",
    ),
    PhonologicalExercise(
      title: "Similar sounds",
      target: 'T',
      options: ['T', 'D', 'K'],
      instructions: "Pay attention to the small differences",
    ),
    PhonologicalExercise(
      title: "Identify vowels",
      target: 'A',
      options: ['A', 'E', 'O'],
      instructions: "Listen carefully and choose the correct vowel",
    ),
  ];

  @override
  void initState() {
    super.initState();
    flutterTts = FlutterTts();
    flutterTts.setLanguage("en-US");
    flutterTts.setSpeechRate(0.4);
    speech = stt.SpeechToText();
  }

  Future<void> speak(String text) async {
    await flutterTts.stop();
    await flutterTts.speak(text);
  }

  Future<void> evaluateSentence() async {
    bool available = await speech.initialize();
    if (!available) return;

    setState(() {
      recognizedText = '';
      feedbackColor = Colors.transparent;
    });

    speech.listen(
      localeId: 'en_US',
      partialResults: false,
      onResult: (val) async {
        recognizedText = val.recognizedWords;
        final spoken = recognizedText.trim().toLowerCase();
        final expected = widget.sentence.trim().toLowerCase();

        final isCorrect = spoken == expected;
        final result = isCorrect ? '✅ Great!' : '❌ Try again';
        final color = isCorrect ? Colors.green : Colors.red;

        setState(() {
          feedbackColor = color;
        });

        await speak(result);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF6ED),
      appBar: AppBar(
        backgroundColor: Colors.orange,
        centerTitle: true,
        title: const Text("🎯 Sentence Practice", style: TextStyle(fontSize: 22)),
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const TabBar(
              indicatorColor: Colors.orange,
              tabs: [
                Tab(text: "Sentence"),
                Tab(text: "Phonics"),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  // Sentence Tab
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Text(
                          widget.sentence,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.brown,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () => speak(widget.sentence),
                          icon: const Icon(Icons.volume_up),
                          label: const Text("Listen", style: TextStyle(fontSize: 18)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: evaluateSentence,
                          icon: const Icon(Icons.record_voice_over),
                          label: const Text("Speak it", style: TextStyle(fontSize: 18)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepOrangeAccent,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (recognizedText.isNotEmpty)
                          Text(
                            'You said: $recognizedText',
                            style: TextStyle(
                              fontSize: 18,
                              color: feedbackColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Phonological Exercises Tab
                  ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: exercises.length,
                    itemBuilder: (context, index) {
                      final exercise = exercises[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 20),
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                exercise.title,
                                style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange),
                              ),
                              const SizedBox(height: 12),
                              Text(exercise.instructions,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 16)),
                              const SizedBox(height: 20),
                              ElevatedButton.icon(
                                onPressed: () => speak(exercise.target),
                                icon: const Icon(Icons.volume_up),
                                label: const Text("Play Sound"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange.shade300,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Wrap(
                                spacing: 10,
                                children: exercise.options.map((option) {
                                  return ElevatedButton(
                                    onPressed: () {
                                      final isCorrect = option == exercise.target;
                                      final feedbackText = isCorrect
                                          ? "✅ Correct!"
                                          : "❌ Try Again";
                                      final color = isCorrect ? Colors.green : Colors.red;

                                      showDialog(
                                        context: context,
                                        builder: (_) => AlertDialog(
                                          title: Text(
                                            feedbackText,
                                            style: TextStyle(
                                                color: color, fontWeight: FontWeight.bold),
                                          ),
                                          content: Text(
                                            isCorrect
                                                ? "Well done!"
                                                : "The correct answer is ${exercise.target}",
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context).pop(),
                                              child: const Text("OK"),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orange.shade50,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10)),
                                    ),
                                    child: Text(option,
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold)),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class PhonologicalExercise {
  final String title;
  final String target;
  final List<String> options;
  final String instructions;

  PhonologicalExercise({
    required this.title,
    required this.target,
    required this.options,
    required this.instructions,
  });
}
