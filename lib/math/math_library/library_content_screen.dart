import 'package:flutter/material.dart';
//import 'package:flutter_tts/flutter_tts.dart';
import 'concept_detail_screen.dart'; // NEW

class LibraryContentScreen extends StatefulWidget {
  final String title;
  final String text;
  final String imagePath;
  final bool isMathConcepts;

  const LibraryContentScreen({
    super.key,
    required this.title,
    required this.text,
    required this.imagePath,
    this.isMathConcepts = false,
  });

  @override
  State<LibraryContentScreen> createState() => _LibraryContentScreenState();
}

class _LibraryContentScreenState extends State<LibraryContentScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  final List<List<Map<String, String>>> _concepts = [
    [
      {
        "title": "Counting",
        "text": "Learn how to count objects.",
        "content":
            "Counting means assigning numbers to things in order. For example: 1 apple, 2 apples.",
        "emoji": "🍏🍎🍏🍎",
        "tip": "Tip: Try counting your fingers slowly from 1 to 10!"
      },
      {
        "title": "Addition",
        "text": "Learn to add numbers together.",
        "content": "Addition means putting numbers together. 🍎 + 🍎 = 🍏🍏",
        "emoji": "🍎 ➕ 🍎 = 🍏🍏",
        "tip": "Tip: Use blocks or fingers to visualize addition."
      },
    ],
    [
      {
        "title": "Multiplication",
        "text": "Learn to multiply numbers.",
        "content": "Multiplication is repeated addition. 🍎🍎🍎 = 3 🍎",
        "emoji": "🍎🍎🍎",
        "tip": "Tip: Try skip counting (2, 4, 6, 8...) to help you multiply!"
      },
      {
        "title": "Patterns",
        "text": "Learn to identify patterns.",
        "content": "Patterns repeat like 🔴🟢🔴🟢. What comes next?",
        "emoji": "🔴🟢🔴🟢",
        "tip": "Tip: Draw your own color patterns using crayons."
      },
    ],
    [
      {
        "title": "Fractions",
        "text": "Learn fractions and their parts.",
        "content": "Fractions are parts of a whole. 1/2 🍕 is half a pizza.",
        "emoji": "1/2 🍕",
        "tip": "Tip: Slice a real fruit or paper to visualize fractions."
      },
      {
        "title": "Word Problems",
        "text": "Solve word problems.",
        "content":
            "Sam has 3 🍏 and buys 2 more 🍏. How many does he have in total?",
        "emoji": "3 🍏 + 2 🍏",
        "tip": "Tip: Draw a picture to help understand the story!"
      },
    ]
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFA726),
        title: Text(widget.title),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.orange,
          labelStyle: const TextStyle(fontSize: 22),
          tabs: const [
            Tab(text: 'Level 1'),
            Tab(text: 'Level 2'),
            Tab(text: 'Level 3'),
          ],
        ),
      ),
      backgroundColor: const Color(0xFFFFF6ED),
      body: TabBarView(
        controller: _tabController,
        children: List.generate(3, (levelIndex) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.0,
              ),
              itemCount: _concepts[levelIndex].length,
              itemBuilder: (context, index) {
                final concept = _concepts[levelIndex][index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ConceptDetailScreen(concept: concept),
                      ),
                    );
                  },
                  child: Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: const BorderSide(color: Colors.orange, width: 3),
                    ),
                    elevation: 6,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          concept["emoji"]!,
                          style: const TextStyle(fontSize: 50),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          concept["title"]!,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          concept["text"]!,
                          style: const TextStyle(fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        }),
      ),
    );
  }
}
