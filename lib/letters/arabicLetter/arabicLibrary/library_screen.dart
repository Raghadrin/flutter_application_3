import 'package:flutter/material.dart';
import 'package:flutter_application_3/letters/arabicLetter/arabicLibrary/n.dart';
import 'full_library_screen.dart';
import 'arabic_videos_screen.dart';
import 'FeelingsScreen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'locale_keys.dart';

class ArabicLibraryScreen extends StatelessWidget {
  const ArabicLibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF6ED),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFA726),
        title: Text(
          LocaleKeys.library_arabic_title.tr(),
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
              title: LocaleKeys.library_language_exercises_title.tr(),
              description: LocaleKeys.library_language_exercises_desc.tr(),
              imagePath: "images/one.png",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const FullLibraryScreen(
                    title: "تمارين لغوية",
                  ),
                ),
              ),
            ),
            _buildTile(
              context,
              title: LocaleKeys.library_educational_videos_title.tr(),
              description: LocaleKeys.library_educational_videos_desc.tr(),
              imagePath: "images/two.png",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ArabicVideosTabbedScreen(),
                ),
              ),
            ),
            _buildTile(
              context,
              title: LocaleKeys.library_challenges_title.tr(),
              description: LocaleKeys.library_challenges_desc.tr(),
              imagePath: "images/feelings_icon.png",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ArabicMotivationHomeScreen(),
                ),
              ),
            ),
            _buildTile(
              context,
              title: LocaleKeys.library_sunduq_title.tr(),
              description: LocaleKeys.library_sunduq_desc.tr(),
              imagePath: "images/4.png",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SunduqAlDadGame(),
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
