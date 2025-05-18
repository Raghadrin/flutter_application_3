import 'package:flutter/material.dart';
import 'full_library_screen.dart';
import 'arabic_videos_screen.dart';
import 'FeelingsScreen.dart';

class ArabicLibraryScreen extends StatelessWidget {
  const ArabicLibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF6ED),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFA726),
        title: const Text("مكتبة اللغة العربية",
            style: TextStyle(fontWeight: FontWeight.bold)),
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
              title: "تمارين لغوية",
              description: "تمرن على القضايا اللغوية.",
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
              title: "فيديوهات تعليمية",
              description: "شاهد فيديوهات تشرح العربية.",
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
              title: "تحديات والغاز",
              description: "العب وتحدى نفسك",
              imagePath: "images/feelings_icon.png",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ArabicMotivationHomeScreen(),
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
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFFFA726), width: 2),
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(imagePath, width: 68, height: 80),
            //const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(height: 5),
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
