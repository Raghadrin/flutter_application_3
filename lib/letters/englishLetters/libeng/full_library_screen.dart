import 'package:flutter/material.dart';
import 'choose_word_game.dart';
import 'missing_letter_game.dart';
import 'match_word_game.dart';
import 'record_sentence_game.dart';
import 'karaoke_reading_game.dart';
import 'english_videos_tabbed_screen.dart'; // Make sure this screen exists

class EnglishLibrary1Screen extends StatelessWidget {
  const EnglishLibrary1Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          " Library",
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFFFA726),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFE0B2), Color(0xFFFFCC80)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            EnglishLibraryTile(
              title: "1. 🧩 Choose the Correct Word",
              screen: const ChooseWordGame(),
            ),
            EnglishLibraryTile(
              title: "2. 🔡 Missing Letter",
              screen: const MissingLetterGame(),
            ),
            EnglishLibraryTile(
              title: "3. 🔊 Match Word with Sound",
              screen: const MatchWordGame(),
            ),
            EnglishLibraryTile(
              title: "4. 🎤 Record the Sentence",
              screen: const RecordSentenceGame(),
            ),
            EnglishLibraryTile(
              title: "5. 🎙 Karaoke Reading",
              screen: const KaraokeReadingGame(),
            ),
          ],
        ),
      ),
    );
  }
}

class EnglishLibraryTile extends StatelessWidget {
  final String title;
  final Widget screen;

  const EnglishLibraryTile({
    super.key,
    required this.title,
    required this.screen,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: ListTile(
        tileColor: const Color(0xFFFFF3E0),
        title: Text(
          title,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.deepOrange),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
        },
      ),
    );
  }
}
