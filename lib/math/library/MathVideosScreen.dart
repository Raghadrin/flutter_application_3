import 'package:flutter/material.dart';
import 'package:flutter_application_3/pages/YoutubePlayerScreen.dart';
import 'youtube_player_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class MathVideosScreen extends StatefulWidget {
  const MathVideosScreen({super.key});

  @override
  State<MathVideosScreen> createState() => _MathVideosScreenState();
}

class _MathVideosScreenState extends State<MathVideosScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, String>> englishVideos = const [
    {
      "title": "Video on Addition",
      "description": "Learn how to add numbers.",
      "url": "https://www.youtube.com/watch?v=tVHOBVAFjUw",
      "thumbnail": "https://img.youtube.com/vi/tVHOBVAFjUw/0.jpg",
    },
    {
      "title": "Dino Math Video",
      "description": "Fun dinosaur math video.",
      "url": "https://www.youtube.com/watch?v=gf97tXwTDe0",
      "thumbnail": "https://img.youtube.com/vi/gf97tXwTDe0/0.jpg",
    },
    {
      "title": "Understanding Equations",
      "description": "Learn about equations.",
      "url": "https://www.youtube.com/watch?v=dtnvT4CtJAc",
      "thumbnail": "https://img.youtube.com/vi/dtnvT4CtJAc/0.jpg",
    },
    {
      "title": "Fractions Made Easy",
      "description": "Learning fractions.",
      "url": "https://www.youtube.com/watch?v=n0FZhQ_GkKw",
      "thumbnail": "https://img.youtube.com/vi/n0FZhQ_GkKw/0.jpg",
    },
    {
      "title": "Multiplication Tricks",
      "description": "Master multiplication.",
      "url": "https://www.youtube.com/watch?v=dPksJHBZs4Q",
      "thumbnail": "https://img.youtube.com/vi/dPksJHBZs4Q/0.jpg",
    },
    {
      "title": "Division Explained",
      "description": "Learn division easily.",
      "url": "https://www.youtube.com/watch?v=wAxEdmutf98",
      "thumbnail": "https://img.youtube.com/vi/wAxEdmutf98/0.jpg",
    },
  ];

  final List<Map<String, String>> arabicVideos = const [
    {
      "title": "Haseeb's Math Adventures",
      "description": "Haseeb's fun journey to learn numbers.",
      "url":
          "https://youtu.be/iRIzMDwez7M?list=PLjtwKLjnWi7FfBT2Du6Wwg6-en6A0QMOa",
      "thumbnail": "images/Haseeb.PNG"
    },
    {
      "title": "What Are Equations?",
      "description": "Simplified explanations of equations.",
      "url": "https://youtu.be/pMlNgiXQoNg",
      "thumbnail": "https://img.youtube.com/vi/pMlNgiXQoNg/0.jpg"
    },
    {
      "title": "Learning Addition",
      "description": "Fun and easy way to learn addition.",
      "url": "https://youtu.be/LlbHDsN7DSM?t=86",
      "thumbnail": "https://img.youtube.com/vi/LlbHDsN7DSM/0.jpg"
    },
    {
      "title": "Introducing Fractions",
      "description": "Fun fraction learning for kids.",
      "url": "https://youtu.be/0kUrvN8ObvM",
      "thumbnail": "https://img.youtube.com/vi/0kUrvN8ObvM/0.jpg"
    },
    {
      "title": "How To Divide",
      "description": "Simple ways to learn division.",
      "url": "https://youtu.be/TkroAwtL9hY?t=78",
      "thumbnail": "https://img.youtube.com/vi/TkroAwtL9hY/0.jpg"
    },
    {
      "title": "Learning Times Tables with Zakaria",
      "description": "Complete times table with Zakaria.",
      "url":
          "https://youtu.be/aT_SXpWHV84?list=PLEaGEZnOHpUPgAhXALGsesepwdzXEmDvY",
      "thumbnail": "images/Learn_with_Zakria.PNG"
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _openVideo(BuildContext context, String url) {
    if (url.contains("playlist")) {
      launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => YoutubePlayerScreen(videoUrl: url),
        ),
      );
    }
  }

  Widget _buildVideoTile(Map<String, String> video, BuildContext context) {
    final bool isAsset = video['thumbnail']!.startsWith("images/");
    final imageWidget = isAsset
        ? Image.asset(video['thumbnail']!,
            width: 80, height: 80, fit: BoxFit.cover)
        : Image.network(video['thumbnail']!,
            width: 80, height: 80, fit: BoxFit.cover);

    return GestureDetector(
      onTap: () => _openVideo(context, video['url']!),
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
                borderRadius: BorderRadius.circular(12), child: imageWidget),
            const SizedBox(height: 10),
            Text(video['title']!,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 6),
            Text(video['description']!,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14, color: Colors.grey[700], height: 1.3)),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoGrid(
      List<Map<String, String>> videos, BuildContext context) {
    return GridView.count(
      padding: const EdgeInsets.all(16),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 0.6,
      children: videos.map((video) => _buildVideoTile(video, context)).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFFFF6ED),
        appBar: AppBar(
          title: const Text("Skill Videos"),
          backgroundColor: const Color(0xFFFFA726),
          bottom: const TabBar(
            tabs: [
              Tab(text: "English"),
              Tab(text: "Arabic"),
            ],
            labelStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            indicatorColor: Colors.white,
          ),
        ),
        body: TabBarView(
          children: [
            _buildVideoGrid(englishVideos, context),
            _buildVideoGrid(arabicVideos, context),
          ],
        ),
      ),
    );
  }
}
