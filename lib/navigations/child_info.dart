import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_3/navigations/startScreen.dart';
import 'package:flutter_application_3/pages/main_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChildInfoScreen extends StatefulWidget {
  const ChildInfoScreen({super.key});

  @override
  _ChildInfoScreenState createState() => _ChildInfoScreenState();
}

class _ChildInfoScreenState extends State<ChildInfoScreen> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  String? _selectedGender;

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    setState(() {
      _dateController.text =
          picked != null ? "${picked.year}-${picked.month}-${picked.day}" : "";
    });
  }

// ✅ Function to save childId in local storage
  Future<void> saveChildId(String childId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('child_id', childId);
  }

  Future<void> _saveChildInfo() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        DocumentReference childRef = await FirebaseFirestore.instance
            .collection('parents')
            .doc(user.uid)
            .collection('children')
            .add({
          'name': _nameController.text.trim(),
          'gender': _selectedGender,
          'birthdate': _dateController.text.trim(),
          'timestamp': FieldValue.serverTimestamp(),
        });

        // ✅ Save the child ID locally
        await saveChildId(childRef.id);

        // ✅ Show confirmation message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Child information saved successfully!")),
        );

        // ✅ Navigate to StartScreen after a short delay
        Future.delayed(Duration(seconds: 1), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => StartScreen()),
          );
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error saving data: ${e.toString()}")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("User not logged in!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          CustomPaint(
            painter: CirclePainter(),
            child: Container(),
          ),
          Center(
              child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(20),
              margin: EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Color(0xFFFFE9DA),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 40,
                      backgroundImage: AssetImage('images/logo.jpg'),
                    ),
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: Text(
                      "What is your child name?",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 63, 23, 3)),
                    ),
                  ),
                  SizedBox(height: 5),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFEB5317)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(
                            color: Colors.deepOrange,
                            width: 1.5), // Enabled border color
                      ),
                      hintText: "Child name",
                      hintStyle: const TextStyle(
                          color: Color.fromARGB(179, 255, 68, 22)),
                    ),
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: Text(
                      "Select your child gender?",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 88, 28, 11)),
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () =>
                            setState(() => _selectedGender = 'Girl'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _selectedGender == 'Girl'
                              ? Colors.orange
                              : Colors.white,
                          foregroundColor: Colors.black,
                        ),
                        child: Text(
                          "Girl",
                          style:
                              TextStyle(fontSize: 16, color: Color(0xFFEB5317)),
                        ),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () =>
                            setState(() => _selectedGender = 'Boy'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _selectedGender == 'Boy'
                              ? Colors.orange
                              : Colors.white,
                          foregroundColor: Colors.black,
                        ),
                        child: Text(
                          "Boy",
                          style:
                              TextStyle(fontSize: 16, color: Color(0xFFEB5317)),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: Text(
                      "Your child's birth date",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 84, 29, 2)),
                    ),
                  ),
                  SizedBox(height: 5),
                  TextField(
                    controller: _dateController,
                    readOnly: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFEB5317)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(
                            color: Colors.deepOrange,
                            width: 1.5), // Enabled border color
                      ),
                      hintText: "YYYY-MM-DD",
                      hintStyle: const TextStyle(
                          color: Color.fromARGB(179, 255, 91, 32)),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.calendar_today),
                        color: const Color.fromARGB(255, 210, 65, 7),
                        onPressed: () => _selectDate(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Padding(
              padding: const EdgeInsets.all(100.0),
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      if (_nameController.text.trim().isEmpty ||
                          _selectedGender == null ||
                          _dateController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Please fill all fields!")),
                        );
                        return;
                      }

                      await _saveChildInfo(); // Save child info first
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFEB5317),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      "Next",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(
                    height: 25,
                    width: 10,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MainScreen()));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFEB5317),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      "cancel",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Color(0xFFFEDAC1)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(size.width - 50, 50), 80, paint);
    canvas.drawCircle(Offset(50, size.height - 50), 80, paint);

    paint.color = Color(0xFFFBBC89);
    canvas.drawCircle(Offset(size.width - 70, 70), 100, paint);
    canvas.drawCircle(Offset(70, size.height - 70), 100, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false; // Return true if the painter needs to be redrawn
  }
}
