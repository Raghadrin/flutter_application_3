import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_3/navigations/child_info.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'login.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool rememberMe = false;
  final TextEditingController nameController = TextEditingController();

  Future<void> signUp() async {
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match!")),
      );
      return;
    }

    try {
      // Register user in Firebase Authentication
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      String userId = userCredential.user!.uid;

      // Store user data in Firestore
      await _firestore.collection('Users').doc(userId).set({
        'user_id': userId,
        'email': emailController.text.trim(),
        'role': "parent", // Assuming parent by default
        'created_at': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Account Created Successfully!")),
      );

      // Navigate to login screen
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => LoginScreen()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return; // User canceled sign-in

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      String userId = userCredential.user!.uid;

      // Check if user already exists in Firestore
      DocumentSnapshot userDoc =
          await _firestore.collection('Users').doc(userId).get();
      if (!userDoc.exists) {
        // If new user, save data in Firestore
        await _firestore.collection('Users').doc(userId).set({
          'user_id': userId,
          'email': userCredential.user!.email,
          'role': "parent",
          'created_at': FieldValue.serverTimestamp(),
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Signed in successfully!")),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ChildInfoScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Google Sign-In failed: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 255, 151, 76),
              Color.fromARGB(255, 255, 193, 145)
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Text('Register',
                        style: GoogleFonts.lato(
                            fontSize: 52,
                            fontWeight: FontWeight.normal,
                            color: Colors.white)),
                  ),
                  const SizedBox(height: 30),
                  _buildLabel("Enter Full Name"),
                  _buildInputField(nameController, Icons.person, "Your name"),
                  _buildLabel("Enter Email"),
                  _buildInputField(
                      emailController, Icons.email, "User@email.com"),
                  _buildLabel("Enter Password"),
                  _buildInputField(
                      passwordController, Icons.lock, "Your password"),
                  _buildLabel("Confirm Password"),
                  _buildInputField(confirmPasswordController, Icons.lock,
                      "Rewrite password"),
                  const SizedBox(height: 30),
                  Center(
                    child: ElevatedButton(
                      onPressed: signUp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(
                            255, 254, 251, 251), // Transparent background
                        foregroundColor: Colors.deepOrange, // Text color
                        side: BorderSide(
                            color: Colors.deepOrange, width: 1), // Border color
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(30), // Rounded border
                        ),
                      ),
                      child: const Text('Sign Up'),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => LoginScreen()));
                    },
                    child: Center(
                      child: const Text(
                        "You already have an account? log in",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: const Text(
                      "or continue with",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 10),
                  InkWell(
                    onTap: () {
                      // Call Google sign-in function
                    },
                    child: Center(
                        child: InkWell(
                      onTap: signInWithGoogle,
                      child: Image.asset(
                        "images/google_icon.png", // Make sure you have the Google icon in assets
                        width: 50,
                        height: 50,
                      ),
                    )),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Widget _buildLabel(String text) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 5),
    child: Text(text,
        style: const TextStyle(
            fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
  );
}

Widget _buildInputField(
    TextEditingController controller, IconData icon, String hintText) {
  return TextField(
    controller: controller,
    decoration: InputDecoration(
      prefixIcon: Icon(icon, color: Colors.white),
      hintText: hintText,
      hintStyle: const TextStyle(color: Color.fromARGB(179, 255, 91, 32)),
      filled: true,
      fillColor: Colors.white.withOpacity(0.5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide:
            BorderSide(color: Colors.deepOrange, width: 1.4), // Border color
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide(
            color: Colors.deepOrange, width: 1.4), // Enabled border color
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide(
            color: Colors.deepOrange,
            width: 2), // Highlighted border when focused
      ),
    ),
  );
}
