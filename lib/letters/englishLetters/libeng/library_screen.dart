import 'package:flutter/material.dart';
import 'package:flutter_application_3/letters/englishLetters/libeng/english_videos_tabbed_screen.dart';
import 'c.dart';
import 'full_library_screen.dart';

import 'FeelingsScreen.dart';

class EnglishLibraryScreen extends StatelessWidget {
  const EnglishLibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF6ED),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFA726),
        title: const Text(
          "English Library",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.5,
          children: [
            _buildTile(
              context,
              title: "Language Exercises",
              description: "Practice grammar and vocabulary.",
              imagePath: "images/one.png",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const EnglishLibrary1Screen(
                  
                  ),
                ),
              ),
            ),
            _buildTile(
              context,
              title: "Educational Videos",
              description: "Watch videos to improve your English.",
              imagePath: "images/two.png",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const EnglishVideosTabbedScreen(),
                ),
              ),
            ),
            _buildTile(
              context,
              title: "Challenges & Riddles",
              description: "Play and challenge your mind.",
              imagePath: "images/feelings_icon.png",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const EnglishMotivationHomeScreen(),
                ),
              ),
            ),
            _buildTile(
              context,
              title: "Emotions & Feelings",
              description: "Explore feelings with fun games.",
              imagePath: "images/feelings_icon.png",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const HelloWordScreen(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTile(
    BuildContext context, {
    required String title,
    required String description,
    required String imagePath,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFFFA726), width: 2),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(imagePath, width: 48, height: 48),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(height: 12),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}
