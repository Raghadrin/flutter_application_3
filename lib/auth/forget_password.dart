import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController emailController = TextEditingController();
  bool isLoading = false;

  /// Send Password Reset Email
  void sendPasswordResetEmail() async {
    // Show progress indicator
    showDialog(
      context: context,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    if (emailController.text.isEmpty) {
      displayMessageToUser("Email field cannot be empty".tr(), context);
      return;
    }

    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(emailController.text)) {
      displayMessageToUser("Invalid email format".tr(), context);
      return;
    }

    try {
      // Send password reset email
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: emailController.text.trim(),
      );

      // Show success dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Password Reset Email Sent").tr(),
          content: Text(
            "A password reset link has been sent to ${emailController.text}. Please check your email."
                .tr(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                Navigator.pop(context); // Go back to the login page
              },
              child: const Text("OK").tr(),
            ),
          ],
        ),
      );
    } on FirebaseAuthException catch (e) {
      displayMessageToUser(
          e.message ?? "An error occurred. Please try again.".tr(), context);
    } finally {
      // Dismiss progress indicator
      if (context.mounted) Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Theme.of(context).colorScheme.primary,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color.fromARGB(255, 255, 133, 51), Color(0xFFFAB98A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 90),

                Text(
                  "Reset Your Password".tr(),
                  style: GoogleFonts.nanumMyeongjo(
                    color: Colors.white,
                    textStyle: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 50),

                // Email TextField
                MyTextfield(
                  hintText: "Enter your email".tr(),
                  obscuretext: false,
                  controller: emailController,
                ),
                const SizedBox(height: 25),

                // Send Button
                isLoading
                    ? const CircularProgressIndicator()
                    : MyButton(
                        buttonText: "Send Reset Link".tr(),
                        onTap: sendPasswordResetEmail,
                      ),
                const SizedBox(height: 10),

                // Back to Login Link
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Go back to the login page
                  },
                  child: Text(
                    "Back to Login".tr(),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
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

displayMessageToUser(String message, BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(message),
    ),
  );
}

class MyButton extends StatelessWidget {
  const MyButton({super.key, required this.buttonText, required this.onTap});

  final Function()? onTap;
  final String buttonText;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(12)),
        ),
        padding: const EdgeInsets.all(25),
        child: Center(
            child: Text(
          buttonText,
          style: const TextStyle(
            fontSize: 16,
          ),
        )),
      ),
    );
  }
}

class MyTextfield extends StatelessWidget {
  const MyTextfield(
      {super.key,
      required this.hintText,
      required this.obscuretext,
      required this.controller});

  final String hintText;
  final bool obscuretext;
  final TextEditingController controller;
  @override
  Widget build(BuildContext context) {
    return TextField(
      enableInteractiveSelection: true,
      style: GoogleFonts.roboto(fontWeight: FontWeight.w300),
      controller: controller,
      decoration: InputDecoration(
        border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12))),
        hintText: hintText,
      ),
      obscureText: obscuretext,
    );
  }
}
