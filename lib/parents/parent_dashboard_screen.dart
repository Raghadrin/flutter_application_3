import 'package:flutter/material.dart';

class ParentDashboardScreen extends StatefulWidget {
  const ParentDashboardScreen({super.key});

  @override
  _ParentDashboardScreenState createState() => _ParentDashboardScreenState();
}

class _ParentDashboardScreenState extends State<ParentDashboardScreen> {
  bool isDarkMode = false;

  void toggleDarkMode() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Parent',
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'Arial',
                color: Colors.black)),
        actions: [
          IconButton(
            icon: Image.asset('images/fox_chatbot.png', height: 30),
            onPressed: () {
              // Navigate to ChatBot (to be implemented)
            },
          ),
          // IconButton(
          //   icon: Icon(Icons.nightlight_round, color: Colors.black),
          //   onPressed: toggleDarkMode,
          // ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              padding: EdgeInsets.all(20),
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              children: [
                _buildDashboardTile('Overview', 'images/overview_icon.png'),
                _buildDashboardTile(
                    'Performance', 'images/performance_icon.png'),
                _buildDashboardTile(
                    'Suggestions', 'images/suggestions_icon.png'),
                _buildDashboardTile('Chat Bot', 'images/chatbot_icon.png'),
              ],
            ),
          ),
          Container(height: 50, color: Color(0xFFFAAE71)),
        ],
      ),
    );
  }

  Widget _buildDashboardTile(String title, String imagePath) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFFFE9DA),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(imagePath, height: 50),
          SizedBox(height: 10),
          Text(title,
              style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'Arial',
                  fontWeight: FontWeight.bold,
                  color: Colors.black87)),
        ],
      ),
    );
  }
}
