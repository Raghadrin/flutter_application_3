import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'concept_detail_screen.dart';

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

class _LibraryContentScreenState extends State<LibraryContentScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final FlutterTts _flutterTts = FlutterTts();

  final List<List<Map<String, String>>> _concepts = [
    [
      {
        "title": "Counting",
        "text": "Learn to count objects.",
        "content": "Counting helps us know how many items there are.",
        "emoji": "🖐️",
        "tip": "Use your fingers to count slowly.",
        "real": "Try counting on your fingers 1, 2 , 3 , 4 , 5 !.",
        "image": "Fingers_counting_to_5.jpg"
      },
      {
        "title": "Addition",
        "text": "Combine numbers together.",
        "content": "Addition helps us find the total amount.",
        "emoji": "➕",
        "tip": "Group items to add more easily.",
        "real": "3 coins plus 2 coins equals 5 coins.",
        "image": "3+2_fingers.PNG"
      },
      {
        "title": "Sorting",
        "text": "Put things in groups.",
        "content": "Sorting helps us organize and compare items.",
        "emoji": "🧺",
        "tip": "Sort by color, size, or shape.",
        "real": "Put all apples and toys in the basket.",
        "image": "adding_apples_or_toys_to_basket.PNG"
      },
    ],
    [
      {
          "title": "Making Choices",
  "text": "We use math to choose what to buy.",
  "content": "The girl uses shapes to pick a snack.",
  "emoji": "🛍️",
  "tip": "Use shapes or prices to help you decide.",
  "real": "She compares snack boxes by shape.",
        "image": "child_buying_sncacks.PNG"
      },
    
    {
"title": "Grocery Prices",
"text": "Use math to add prices.",
"content": "The cart shows how much each item costs.",
"emoji": "🛒",
"tip": "Add the prices to find the total.",
"real": "Milk is \\\$3, bread is \\\$2, and an apple is \\\$1. Total = \\\$6.",
      "image": "Grocery_Cart.PNG"
    },
      {
        "title": "Patterns",
        "text": "Find what repeats.",
        "content": "Patterns help us predict what comes next.",
        "emoji": "🔴🟢",
        "tip": "Look for repeating colors or shapes.",
        "real": "Orange, Blue, Orange, Red... What comes next?",
        "image": "Patterns.PNG"
      },
      {
        "title": "Weekdays Patterns",
  "text": "Understand repeating patterns like weekdays.",
  "content": "Patterns help us recognize regular sequences, such as weekdays in a schedule.",
  "emoji": "📅",
  "tip": "Practice recognizing and filling in weekday patterns, like M, T, W.",
  "real": "The pattern shows the sequence of weekdays for a month, with Monday (M), Tuesday (T), and Wednesday (W).",
        "image": "Reapating_Symbol.PNG"
      },
    ],
    [
      {
        "title": "Fractions",
        "text": "Parts of a whole.",
        "content": "Fractions show how we split things.",
        "emoji": "🍕",
        "tip": "Use pizza or pie slices to learn halves and quarters.",
        "real": "Half a pizza means 1 out of 2 equal parts.",
        "image": "Pizza_Fractions.jpg"
      },
      {
        "title": "Grouping",
        "text": "Put items into equal sets.",
        "content": "Grouping helps us count quickly and learn multiplication.",
        "emoji": "🥚",
        "tip": "Use rows and columns for easier counting.",
        "real": "3 rows of 4 eggs equals 12 eggs.",
        "image": "Rows_EGGS_CUPCAKE_DESKS.PNG"
      },
      {
        "title": "Chocolate Math",
        "text": "Break items into smaller parts.",
        "content": "We can divide chocolates to share with friends.",
        "emoji": "🍫",
        "tip": "Share chocolates equally.",
        "real": "6 chocolates for 3 kids = 2 chocolates each.",
        "image": "Dividing_Choclates.PNG"
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
    _flutterTts.stop();
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
                childAspectRatio: 0.8,
              ),
              itemCount: _concepts[levelIndex].length,
              itemBuilder: (context, index) {
                final concept = _concepts[levelIndex][index];
                return GestureDetector(
                  onTap: () {
                    _flutterTts.stop();
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
                        Text(concept["emoji"] ?? "", style: const TextStyle(fontSize: 50)),
                        const SizedBox(height: 10),
                        Text(
                          concept["title"] ?? "",
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          concept["text"] ?? "",
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
