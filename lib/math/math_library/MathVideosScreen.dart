import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MathVideosScreen extends StatelessWidget {
  const MathVideosScreen({super.key});

  final List<Map<String, String>> videos = const [
    {
      "title": "Learn Addition up to 10",
      "description": "Learn How to Add from 1 to 10.",
      "url": "https://www.youtube.com/watch?v=tVHOBVAFjUw",
      "thumbnail": "https://img.youtube.com/vi/tVHOBVAFjUw/0.jpg",
    },
    {
      "title": "Learn to add with Dino",
      "description": "Addition Exercises for Kids.",
      "url": "https://www.youtube.com/watch?v=gf97tXwTDe0",
      "thumbnail": "https://img.youtube.com/vi/gf97tXwTDe0/0.jpg",
    },
    {
      "title": "Equations for Kids",
      "description": "Solving Equations with Addition and Subtraction.",
      "url": "https://youtu.be/dtnvT4CtJAc",
      "thumbnail": "https://img.youtube.com/vi/dtnvT4CtJAc/0.jpg",
    },
    {
      "title": "Let's Learn Fractions",
      "description": "Understaing Fractions.",
      "url": "https://www.youtube.com/watch?v=n0FZhQ_GkKw",
      "thumbnail": "https://img.youtube.com/vi/n0FZhQ_GkKw/0.jpg",
    },
    {
      "title": "What is Multiplication?",
      "description": "Introduction to Multiplication Concepts for Kids.",
      "url": "https://youtu.be/dPksJHBZs4Q",
      "thumbnail": "https://img.youtube.com/vi/dPksJHBZs4Q/0.jpg",
    },
    {
      "title": "Long Division",
      "description": "Learn How to Do Long Division.",
      "url": "https://youtu.be/wAxEdmutf98?t=5",
      "thumbnail": "https://img.youtube.com/vi/wAxEdmutf98/0.jpg",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF6ED),
      appBar: AppBar(
        title: const Text("Skill Videos"),
        backgroundColor: const Color(0xFFFFA726),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.8,
          ),
          itemCount: videos.length,
          itemBuilder: (context, index) {
            final video = videos[index];
            return GestureDetector(
              onTap: () => launchUrl(Uri.parse(video['url']!)),
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
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        video['thumbnail']!,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      video['title']!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      video['description']!,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.3),
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
