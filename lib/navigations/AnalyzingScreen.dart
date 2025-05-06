import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_3/auth/Set_Account.dart';

class AnalyzingScreen extends StatelessWidget {
  final int yesCount;
  final int total;
  final String childId; // Get child ID from previous screen

  AnalyzingScreen(
      {super.key,
      required this.yesCount,
      required this.total,
      required this.childId}) {
    _saveTestResults();
  }

  void _saveTestResults() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    String testId = DateTime.now().millisecondsSinceEpoch.toString();
    String result = (yesCount / total) * 100 > 50 ? "At Risk" : "Not At Risk";

    await firestore.collection("DyslexiaTests").doc(testId).set({
      "test_id": testId,
      "child_id": childId, // Store childId
      "questions": {"yesCount": yesCount, "total": total},
      "score": ((yesCount / total) * 100).round(),
      "result": result,
      "completed_at": FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    double percentage = (yesCount / total) * 100;
    String riskStatus = percentage > 50 ? "At Risk" : "Not At Risk";

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 241, 178, 116),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 255, 193, 145),
              Color.fromARGB(255, 255, 219, 192)
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Container(
            //constraints:BoxBorder() , BoxConstraints(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "📊 Analysis Result",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFEB5317), // Orange-red
                  ),
                ),
                SizedBox(height: 25),

                // ✅ Yes Answers
                Text(
                  "✔️ Yes Answers: $yesCount / $total",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Colors.blueAccent,
                  ),
                ),
                SizedBox(height: 10),

                // ✅ Percentage
                Text(
                  "📉 Percentage: ${percentage.toStringAsFixed(1)}%",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Colors.deepPurple,
                  ),
                ),
                SizedBox(height: 10),

                // ✅ Risk Status
                Text(
                  "⚠️ Risk Status: $riskStatus",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: percentage > 50 ? Colors.red : Colors.green,
                  ),
                ),
                SizedBox(height: 30),

                // ✅ Go Back Button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFEB5317), // Orange-red
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => SetAccountPage()),
                      (route) => false, // Clears all previous screens
                    );
                  },
                  child: Text(
                    "Back",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
