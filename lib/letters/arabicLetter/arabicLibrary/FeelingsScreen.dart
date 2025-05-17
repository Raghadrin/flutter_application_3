import 'package:flutter/material.dart';
import 'karaoke_words_screen.dart';
import 'image_word_match_screen.dart';
import 'story_complete_screen.dart';
import 'arabic_riddle_screen.dart';

class ArabicMotivationHomeScreen extends StatelessWidget {
  const ArabicMotivationHomeScreen({super.key});

  final List<Map<String, dynamic>> activities = const [
    {
      "title": "وين الكلمة؟",
      "icon": Icons.image_search,
      "color": Color(0xFFA5D6A7),
      "route": "image"
    },
    
    {
      "title": "احكِلي وأنا أكمل",
      "icon": Icons.auto_stories,
      "color": Color(0xFF81D4FA),
      "route": "story"
    },
    {
      "title": "كلمة السر",
      "icon": Icons.lock_open,
      "color": Color(0xFFE6EE9C),
      "route": "puzzle"
    },
    {
      "title": "الكلمة الصحيحة ✅",
      "icon": Icons.spellcheck,
      "color": Color(0xFFD1C4E9),
      "route": "correctWord"
    },
  ];

  void _navigateTo(BuildContext context, String route) {
    Widget page;

    switch (route) {
      case "image":
        page = const AdvancedImageWordMatchScreen();
        break;
      
      case "story":
        page = const AdvancedStoryCompleteScreen();
        break;
      case "puzzle":
        page = const ArabicRiddleScreen();
        break;
      case "correctWord":
        page = const FindCorrectWordScreen();
        break;
      default:
       
        page = const Scaffold(
          body: Center(child: Text("الشاشة غير متوفرة")),
        );
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF6ED),
      appBar: AppBar(
        title: const Text("مرحبًا بك في عالم العربية!", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: const Color(0xFFFFA726),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: GridView.builder(
          itemCount: activities.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1,
          ),
          itemBuilder: (context, index) {
            final activity = activities[index];
            return GestureDetector(
              onTap: () => _navigateTo(context, activity["route"]),
              child: Container(
                decoration: BoxDecoration(
                  color: activity["color"],
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(2, 2))
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(activity["icon"], size: 50, color: Colors.white),
                    const SizedBox(height: 10),
                    Text(
                      activity["title"],
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
