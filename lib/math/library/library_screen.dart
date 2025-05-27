import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import 'library_content_screen.dart';
import 'MathVideosScreen.dart';
import 'FeelingsScreen.dart';
import 'ConfidenceMessagesScreen.dart';
import 'locale_keys.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF6ED),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFA726),
        title: Text(
          tr(LocaleKeys.library_title),
          style: const TextStyle(fontWeight: FontWeight.bold),
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
              title: tr(LocaleKeys.math_concepts_title),
              description: tr(LocaleKeys.math_concepts_description),
              imagePath: "images/concepts.png",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => LibraryContentScreen(
                    title: tr(LocaleKeys.math_concepts_title),
                    text: tr(LocaleKeys.math_concepts_description),
                    imagePath: "images/concepts.png",
                    isMathConcepts: true,
                  ),
                ),
              ),
            ),
            _buildTile(
              context,
              title: tr(LocaleKeys.skill_videos_title),
              description: tr(LocaleKeys.skill_videos_description),
              imagePath: "images/video_icon.png",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MathVideosScreen()),
              ),
            ),
            _buildTile(
              context,
              title: tr(LocaleKeys.feelings_title),
              description: tr(LocaleKeys.feelings_description),
              imagePath: "images/feelings_icon.png",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FeelingsScreen()),
              ),
            ),
            _buildTile(
              context,
              title: tr(LocaleKeys.confidence_title),
              description: tr(LocaleKeys.confidence_description),
              imagePath: "images/confidence_icon.png",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ConfidenceMessagesScreen()),
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
