// 📋 Screening Test Screen
import 'package:flutter/material.dart';
import 'package:flutter_application_3/navigations/AnalyzingScreen.dart';

class ScreeningTestScreen extends StatefulWidget {
  final String childId; // Receive childId

  const ScreeningTestScreen({super.key, required this.childId});

  @override
  _ScreeningTestScreenState createState() => _ScreeningTestScreenState();
}

class _ScreeningTestScreenState extends State<ScreeningTestScreen> {
  final List<Map<String, dynamic>> questions = [
    {
      "category": "Reading and Writing Struggles",
      "question": "Does your child hesitate or struggle when reading aloud?"
    },
    {
      "category": "Reading and Writing Struggles",
      "question": "Does your child guess words instead of sounding them out?"
    },
    {
      "category": "Reading and Writing Struggles",
      "question": "Does your child mix up similar-looking letters?"
    },
    {
      "category": "Reading and Writing Struggles",
      "question": "Does your child reverse letters when writing?"
    },
    {
      "category": "Reading and Writing Struggles",
      "question":
          "Does your child avoid reading or say it’s 'too hard' or 'boring'?"
    },
    {
      "category": "Spelling and Phonological Awareness",
      "question":
          "Does your child have difficulty remembering how to spell simple words?"
    },
    {
      "category": "Spelling and Phonological Awareness",
      "question": "Does your child struggle to recognize rhyming words?"
    },
    {
      "category": "Spelling and Phonological Awareness",
      "question": "Does your child mispronounce longer words?"
    },
    {
      "category": "Memory and Attention",
      "question":
          "Does your child forget instructions easily, even right after hearing them?"
    },
    {
      "category": "Memory and Attention",
      "question":
          "Does your child struggle to recall sequences, like the days of the week?"
    },
    {
      "category": "Memory and Attention",
      "question":
          "Does your child take longer to complete homework compared to other children?"
    },
    {
      "category": "Memory and Attention",
      "question":
          "Does your child easily lose track of where they are when reading?"
    },
    {
      "category": "Memory and Attention",
      "question": "Does your child often mix up left and right?"
    },
    {
      "category": "Speaking and Listening",
      "question":
          "Does your child struggle to find the right words when speaking?"
    },
    {
      "category": "Speaking and Listening",
      "question":
          "Does your child pause often or use filler words ('um, uh') frequently?"
    },
    {
      "category": "Speaking and Listening",
      "question":
          "Does your child have trouble following long or complex instructions?"
    },
    {
      "category": "Emotional and Social Signs",
      "question":
          "Does your child get frustrated or anxious when reading or writing?"
    },
    {
      "category": "Emotional and Social Signs",
      "question": "Does your child lack confidence in their academic abilities?"
    },
    {
      "category": "Emotional and Social Signs",
      "question":
          "Does your child avoid participating in class or reading aloud?"
    },
    {
      "category": "Emotional and Social Signs",
      "question":
          "Does your child show signs of low self-esteem related to learning?"
    },
    {
      "category": "Number and Counting",
      "question":
          "Does your child struggle to recognize numbers or confuse similar-looking numbers?"
    },
    {
      "category": "Number and Counting",
      "question": "Does your child have difficulty understanding quantity?"
    },
    {
      "category": "Number and Counting",
      "question":
          "Does your child have difficulty counting forward or backward correctly?"
    },
    {
      "category": "Basic Math Operations",
      "question":
          "Does your child take a long time to solve simple addition or subtraction problems?"
    },
    {
      "category": "Basic Math Operations",
      "question": "Does your child confuse mathematical symbols (+, -, ×, ÷)?"
    },
    {
      "category": "Basic Math Operations",
      "question": "Does your child struggle to estimate quantities?"
    }
  ];

  int currentIndex = 0;
  int yesCount = 0;

  void nextQuestion(bool isYes) {
    if (isYes) yesCount++;

    if (currentIndex < questions.length - 1) {
      setState(() {
        currentIndex++;
      });
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => AnalyzingScreen(
                  yesCount: yesCount,
                  total: questions.length,
                  childId: widget.childId,
                )),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // White background
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                  radius: 50, backgroundImage: AssetImage('images/logo.jpg')),
              SizedBox(height: 20),
              Container(
                //width: 100,
                height: 300,
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFFFE9DA),
                      Color.fromARGB(255, 255, 236, 215)
                    ], // Gradient background
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      questions[currentIndex]['category'],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: const Color.fromARGB(255, 147, 146, 146)),
                    ),
                    SizedBox(height: 45),
                    Text(
                      questions[currentIndex]['question'],
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () => nextQuestion(true),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFEC5417)),
                    child: Text("Yes",
                        style: TextStyle(fontSize: 18, color: Colors.white)),
                  ),
                  SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () => nextQuestion(false),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFEC5417)),
                    child: Text("No",
                        style: TextStyle(fontSize: 18, color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
