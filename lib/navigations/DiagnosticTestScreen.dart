import 'package:flutter/material.dart';

class DiagnosticTestScreen extends StatelessWidget {
  const DiagnosticTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(
                context); // Don't return 'true' if they go back manually
          },
        ),
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Diagnostic Test",
            style: TextStyle(
              color: Colors.black,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: 'Arial',
            ),
          ),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset("images/subject_fox.jpg", height: 150),
          SizedBox(height: 30),
          Container(
            padding: EdgeInsets.all(20),
            margin: EdgeInsets.symmetric(horizontal: 40),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Color(0xFFFDD1B4),
            ),
            child: Column(
              children: [
                Text(
                  "Main Diagnostic Test",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Arial',
                  ),
                ),
                SizedBox(height: 15),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFEC5417),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  ),
                  onPressed: () {
                    // Simulate test complete
                    Navigator.pop(context, true); // ✅ Return true to MainScreen
                  },
                  child: Text(
                    "Start",
                    style: TextStyle(
                        fontSize: 18, color: Colors.white, fontFamily: 'Arial'),
                  ),
                ),
              ],
            ),
          ),
          Spacer(),
          Container(
              height: 8, width: double.infinity, color: Color(0xFFFAAE71)),
        ],
      ),
    );
  }
}
