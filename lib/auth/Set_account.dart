import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter_application_3/pages/main_screen.dart'; // Import Timer

class SetAccountPage extends StatefulWidget {
  const SetAccountPage({super.key});

  @override
  _SetAccountPageState createState() => _SetAccountPageState();
}

class _SetAccountPageState extends State<SetAccountPage> {
  List<TextEditingController> passwordControllers =
      List.generate(4, (_) => TextEditingController());
  List<TextEditingController> confirmControllers =
      List.generate(4, (_) => TextEditingController());
  List<FocusNode> passwordNodes = List.generate(4, (_) => FocusNode());
  List<FocusNode> confirmNodes = List.generate(4, (_) => FocusNode());
  List<String> passwordValues = List.generate(4, (_) => "");
  List<bool> showRealNumber = List.generate(4, (_) => false);

  void _validatePasswords() {
    String password = passwordValues.join();
    String confirmPassword = confirmControllers.map((c) => c.text).join();

    if (password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Please enter all digits!"),
            backgroundColor: Colors.red),
      );

      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Passwords do not match!"),
            backgroundColor: Colors.red),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Account Set Successfully!"),
            backgroundColor: Colors.green),
      );
    }
  }

  Widget _buildPasswordField(
      String labelText,
      List<TextEditingController> controllers,
      List<FocusNode> focusNodes,
      List<String> values,
      bool isConfirm) {
    return Column(
      children: [
        Text(
          labelText,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(
                0xFFEE662C), // Ensure "Set Account" and "Confirm Password" are the same color
          ),
        ),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            4,
            (index) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Color(0xFFFEEBDD),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Color(0xFFEE662C), width: 2),
                ),
                child: Center(
                  child: TextField(
                    controller: controllers[index],
                    focusNode: focusNodes[index],
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    obscureText: false,
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        values[index] = value;
                        setState(() {
                          showRealNumber[index] = true;
                        });

                        Timer(Duration(milliseconds: 600), () {
                          setState(() {
                            showRealNumber[index] = false;
                          });
                        });

                        if (index < 3) {
                          FocusScope.of(context)
                              .requestFocus(focusNodes[index + 1]);
                        } else {
                          FocusScope.of(context).unfocus();
                        }
                      }
                    },
                    decoration: InputDecoration(
                      counterText: "",
                      border: InputBorder.none,
                    ),
                    style: TextStyle(fontSize: 20, color: Colors.black),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFEE8D9),
      body: Stack(
        children: [
          _buildBackgroundCircles(),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Set Account",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(
                          0xFFEE662C), // Matches "Confirm password" text color
                    ),
                  ),
                  SizedBox(height: 20),
                  _buildPasswordField(
                      "Enter parental dash password",
                      passwordControllers,
                      passwordNodes,
                      passwordValues,
                      false),
                  SizedBox(height: 10),
                  _buildPasswordField("Confirm password", confirmControllers,
                      confirmNodes, passwordValues, true),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      _validatePasswords;
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MainScreen(),
                          ));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFEE662C),
                      foregroundColor: Colors.white,
                      padding:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                    ),
                    child: Text("Submit"),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundCircles() {
    return Positioned(
      left: -50,
      bottom: -50,
      child: CustomPaint(
        size: Size(200, 200),
        painter: CirclePainter(),
      ),
    );
  }
}

class CirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint1 = Paint()
      ..color = Color(0xFFFCD3B4)
      ..style = PaintingStyle.fill;

    final Paint paint2 = Paint()
      ..color = Color(0xFFFAAC6E)
      ..style = PaintingStyle.fill;

    final Paint paint3 = Paint()
      ..color = Color(0xFFFABE91)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.5), 100, paint1);
    canvas.drawCircle(Offset(size.width * 0.3, size.height * 0.3), 80, paint2);
    canvas.drawCircle(Offset(size.width * 0.7, size.height * 0.7), 60, paint3);
  }

  @override
  bool shouldRepaint(CirclePainter oldDelegate) => false;
}
