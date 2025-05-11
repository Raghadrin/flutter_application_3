import 'package:flutter/material.dart';
import 'package:flutter_application_3/math/library/youtube_player_screen.dart';
import 'package:flutter_application_3/pages/YoutubePlayerScreen.dart';

class EnglishVideosTabbedScreen extends StatelessWidget {
  const EnglishVideosTabbedScreen({super.key});

  final Map<String, List<Map<String, String>>> englishVideos = const {
    "Alphabet": [
      {
        "title": "Learn to Write Uppercase & Lowercase",
        "description": "Writing A-Z in uppercase and lowercase.",
        "url": "https://youtu.be/EOX784OXmPs",
        "thumbnail": "https://img.youtube.com/vi/EOX784OXmPs/0.jpg",
      },
      {
        "title": "ABC Song - Spacetoon",
        "description": "Catchy ABC alphabet song for kids.",
        "url": "https://youtu.be/Cmnx1EWjf9s",
        "thumbnail": "https://img.youtube.com/vi/Cmnx1EWjf9s/0.jpg",
      },
    ],
    "Phonics & Spelling": [
      {
        "title": "Learn 3-Letter Words",
        "description": "Phonics and word sounds for kids.",
        "url": "https://youtu.be/jiEv6VTDt5c",
        "thumbnail": "https://img.youtube.com/vi/jiEv6VTDt5c/0.jpg",
      },
      {
        "title": "Spelling Basic Words",
        "description": "Teaching spelling and reading skills.",
        "url": "https://youtu.be/r1uUwrQy_4g",
        "thumbnail": "https://img.youtube.com/vi/r1uUwrQy_4g/0.jpg",
      },
      {
        "title": "Counting Syllables",
        "description": "Phonemic awareness through syllables.",
        "url": "https://youtu.be/tOmgxpWb3Jk",
        "thumbnail": "https://img.youtube.com/vi/tOmgxpWb3Jk/0.jpg",
      },
    ],
    "Conversations": [
      {
        "title": "Basic English Conversation",
        "description": "Hello, How are you? Practice for kids.",
        "url":
            "https://youtu.be/by1QAoRcc-U?list=PL0HMo9RIVkowrkFRF4SFE8OQ3VDlt-wwt",
        "thumbnail": "https://img.youtube.com/vi/by1QAoRcc-U/0.jpg",
      },
    ],
    "Stories": [
      {
        "title": "The Fox and the Crow",
        "description": "Classic fable with English narration.",
        "url": "https://youtu.be/w6199XN1Gyk?t=11",
        "thumbnail": "https://img.youtube.com/vi/w6199XN1Gyk/0.jpg",
      },
      {
        "title": "The Oak Tree",
        "description": "A beautiful story for learners.",
        "url": "https://youtu.be/_6mlmRJHxNo",
        "thumbnail": "https://img.youtube.com/vi/_6mlmRJHxNo/0.jpg",
      },
      {
        "title": "The Perfect Thing",
        "description": "From The Storytellers series.",
        "url": "https://youtu.be/9zsKjnLyA9k",
        "thumbnail": "https://img.youtube.com/vi/9zsKjnLyA9k/0.jpg",
      },
      {
        "title": "The Best Job in the World",
        "description": "An inspiring story for children.",
        "url": "https://youtu.be/vx23RX_uc7Y",
        "thumbnail": "https://img.youtube.com/vi/vx23RX_uc7Y/0.jpg",
      },
    ],
  };

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: englishVideos.length,
      child: Scaffold(
        backgroundColor: const Color(0xFFFFF6ED),
        appBar: AppBar(
          backgroundColor: const Color(0xFFFFA726),
          title: const Text("📺 English Teaching Videos"),
          bottom: TabBar(
            isScrollable: true,
            labelStyle:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            indicatorColor: Colors.white,
            tabs: englishVideos.keys
                .map((category) => Tab(text: category))
                .toList(),
          ),
        ),
        body: TabBarView(
          children: englishVideos.keys.map((category) {
            final videos = englishVideos[category]!;
            return Padding(
              padding: const EdgeInsets.all(10),
              child: GridView.builder(
                itemCount: videos.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 10,
                  childAspectRatio: 0.5,
                ),
                itemBuilder: (context, index) {
                  final video = videos[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => YoutubePlayerScreen(
                            videoUrl: video['url']!,
                          ),
                          //builder: (_) => YoutubePlayerScreen(videoUrl: video['url']!),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                            color: const Color(0xFFFFA726), width: 2),
                        borderRadius: BorderRadius.circular(20),
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
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            video['description']!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[700],
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
