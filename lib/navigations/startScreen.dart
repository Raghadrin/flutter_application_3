import 'package:flutter/material.dart';
import 'package:flutter_application_3/navigations/ScreeningTestScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Function to get childId from SharedPreferences
Future<String?> getChildId() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('child_id');
}

// 🎬 Start Screen
class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  _StartScreenState createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  String? childId; // Nullable child ID

  @override
  void initState() {
    super.initState();
    _loadChildId();
  }

  Future<void> _loadChildId() async {
    String? storedChildId = await getChildId();
    setState(() {
      childId = storedChildId; // Update UI when childId is retrieved
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFE9DA), // Light Orange Background
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 255, 154, 82),
              Color.fromARGB(255, 255, 198, 155)
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 160,
                  width: 180,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50), // Adjust as needed
                    image: DecorationImage(
                      image: AssetImage('images/logo.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  "Dyslexia And Dyscalculia Screening Test",
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(255, 255, 255, 255)),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: childId == null
                      ? null // Disable button if childId is not loaded yet
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ScreeningTestScreen(
                                childId: childId!, // Pass the correct childId
                              ),
                            ),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        childId == null ? Colors.grey : Color(0xFFEC5417),
                    foregroundColor: Colors.white,
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Text("Start Test", style: TextStyle(fontSize: 18)),
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
