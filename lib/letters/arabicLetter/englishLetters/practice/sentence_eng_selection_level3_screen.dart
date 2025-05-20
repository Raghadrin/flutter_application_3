import 'package:flutter/material.dart';
import 'english_level3_screen.dart';

class EnglishSentenceSelectionLevel3Screen extends StatelessWidget {
  final List<Map<String, dynamic>> stories = [
    {
      'emoji': '🌳',
      'title': 'A Day in the Park',
      'paragraph':
          'On a sunny morning, Sami went to the park with his father. He played with his friends a lot, then they sat together to eat and watch birds flying in the sky.',
      'questions': [
        "What is the title of the story?",
        "Who went to the park?",
        "What did Sami do with his friends?",
        "What did they see in the sky?"
      ],
      'answers': [
        "A Day in the Park",
        "Sami and his father",
        "Played a lot",
        "Birds"
      ]
    },
    {
      'emoji': '🌧️',
      'title': 'Rainy Games',
      'paragraph':
          'In the winter, it rains and the ground gets wet. Children love wearing coats and boots, playing in water and making small boats.',
      'questions': [
        "In which season did the story happen?",
        "What happens to the ground?",
        "What do the children play with?",
        "What do they wear?"
      ],
      'answers': [
        "Winter",
        "It gets wet",
        "Small boats",
        "Coats and boots"
      ]
    },
    {
      'emoji': '📖',
      'title': 'Bedtime Story',
      'paragraph':
          'Sarah loves reading stories before bedtime. Every night, she chooses a fun story to read with her mom, then closes her eyes and dreams of beautiful places.',
      'questions': [
        "Who loves reading stories?",
        "When does she read the story?",
        "Who reads with her?",
        "What does she dream of?"
      ],
      'answers': [
        "Sarah",
        "Before bedtime",
        "Her mom",
        "Beautiful places"
      ]
    },
    {
      'emoji': '🏫',
      'title': 'At School',
      'paragraph':
          'At school, students learn reading, writing, and math. They love the teacher because he helps them understand and always encourages them to work hard.',
      'questions': [
        "Where does the story happen?",
        "What do students learn?",
        "Who do they love?",
        "Why do they love him?"
      ],
      'answers': [
        "At school",
        "Reading, writing, and math",
        "The teacher",
        "Because he encourages them"
      ]
    },
    {
      'emoji': '🏖️',
      'title': 'Beach Vacation',
      'paragraph':
          'The family went to the beach on vacation. They built sandcastles, swam in the water, and ate delicious food under the warm sun.',
      'questions': [
        "Where did the family go?",
        "What did they build?",
        "Where did they swim?",
        "What did they eat?"
      ],
      'answers': [
        "To the beach",
        "Sandcastles",
        "In the water",
        "Delicious food"
      ]
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF7E4),
      appBar: AppBar(
        backgroundColor: Colors.orange,
        centerTitle: true,
        title: const Text("📚 Choose a Story",
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: GridView.builder(
          itemCount: stories.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 24,
            crossAxisSpacing: 24,
            childAspectRatio: 1,
          ),
          itemBuilder: (context, index) {
            final story = stories[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EnglishLevel3Screen(
                      title: story['title'],
                      storyText: story['paragraph'],
                      questions: List<String>.from(story['questions']),
                      correctAnswers: List<String>.from(story['answers']),
                    ),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.orange.shade300),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                ),
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FittedBox(
                      child: Text(
                        story['emoji'],
                        style: const TextStyle(fontSize: 30),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Text(
                      story['title'],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4E342E),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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
