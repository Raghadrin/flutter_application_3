import 'package:flutter_tts/flutter_tts.dart';
import 'package:audioplayers/audioplayers.dart';

class GameAudioHelper {
  static final FlutterTts _tts = FlutterTts();
  static final AudioPlayer _audioPlayer = AudioPlayer();

  static Future<void> _setupVoice() async {
    await _tts.setLanguage("en-US");
    await _tts.setPitch(1.2);
    await _tts.setSpeechRate(0.45);
  }

  static Future<void> speak(String text) async {
    await _setupVoice();
    await _tts.speak(text);
  }

  static Future<void> sayNumber(String number) async {
    await speak(number);
  }

  static Future<void> sayCorrectAnswer() async => speak("Good job!");
  static Future<void> sayExcellent() async => speak("Excellent!");
  static Future<void> sayWrongAnswer() async => speak("Try again!");
  static Future<void> sayLevelComplete() async => speak("You did great! Let's move to the next level!");
  static Future<void> sayStartGame() async => speak("Let's get started!");
  static Future<void> sayStartQuiz() async => speak("Now let's test what you learned.");
  static Future<void> sayQuizComplete() async => speak("Quiz complete! Awesome work!");

  // ✅ For Arrange Equation Game
  static Future<void> sayArrangeTheEquation() async {
    await speak("Arrange the equation correctly.");
  }

  static Future<void> saySymbol(String symbol) async {
    switch (symbol) {
      case '+':
        await speak("plus");
        break;
      case '-':
        await speak("minus");
        break;
      case '=':
        await speak("equals");
        break;
      default:
        await speak(symbol);
        break;
    }
  }

  // ✅ Play a simple pop sound (used for emoji animations)
  static Future<void> playPopSound() async {
    try {
      await _audioPlayer.play(AssetSource('audio/pop.mp3'));
    } catch (e) {
      print("Pop sound failed: $e");
    }
  }
}
