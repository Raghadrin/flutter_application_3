import 'package:flutter/material.dart';

class VerifyEmailScreen extends StatelessWidget {
  const VerifyEmailScreen({super.key});

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
        title: Text('Verify your email',
            style: TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            SizedBox(height: 30),
            Icon(Icons.email, size: 100, color: Color(0xFFEC5417)),
            SizedBox(height: 20),
            Text(
              "Enter the 4-digit code sent to user@email.com",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
            SizedBox(height: 30),
            _buildCodeInput(),
            SizedBox(height: 20),
            TextButton(
              onPressed: () {},
              child: Text("Resend code",
                  style: TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CreateNewPasswordScreen()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFEC5417),
                padding: EdgeInsets.symmetric(vertical: 14, horizontal: 40),
              ),
              child: Text("VERIFY",
                  style: TextStyle(fontSize: 18, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCodeInput() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        return Container(
          width: 50,
          height: 50,
          margin: EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.grey[200],
          ),
          alignment: Alignment.center,
          child: Text(
            "*",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        );
      }),
    );
  }
}

class CreateNewPasswordScreen extends StatelessWidget {
  const CreateNewPasswordScreen({super.key});

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
        title: Text('Create new password',
            style: TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            SizedBox(height: 30),
            Icon(Icons.lock, size: 100, color: Color(0xFFEC5417)),
            SizedBox(height: 20),
            Text("Your new password must be different from the previous one.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black87)),
            SizedBox(height: 30),
            _buildPasswordField("New password"),
            SizedBox(height: 20),
            _buildPasswordField("Confirm password"),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFEC5417),
                padding: EdgeInsets.symmetric(vertical: 14, horizontal: 40),
              ),
              child: Text("SAVE",
                  style: TextStyle(fontSize: 18, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField(String hint) {
    return TextField(
      obscureText: true,
      decoration: InputDecoration(
        hintText: hint,
        suffixIcon: Icon(Icons.visibility_off, color: Colors.grey),
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
