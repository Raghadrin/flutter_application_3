// import 'dart:async';
// //import 'package:athkary/pages/home_page.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_application_3/pages/main_screen.dart';
// import 'package:rive/rive.dart'; // Import Rive package

// class SplashScreen extends StatefulWidget {
//   @override
//   _SplashScreenState createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> {
//   @override
//   void initState() {
//     super.initState();
//     // Delay for 3 seconds before switching to HomePage
//     Timer(Duration(seconds: 3), () {
//       Navigator.pushReplacement(
//         context,
//         PageRouteBuilder(
//           pageBuilder: (_, __, ___) => MainScreen(),
//           transitionsBuilder: (_, anim, __, child) {
//             return FadeTransition(opacity: anim, child: child);
//           },
//           transitionDuration: Duration(seconds: 1),
//         ),
//       );
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Get the current theme brightness
//     bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

//     // Choose the animation based on the theme
//     String animationFile = isDarkMode
//         ? 'assets/rive/riv2_green.riv' // Dark mode animation
//         : 'assets/rive/rive_pur.riv'; // Light mode animation

//     return Scaffold(
//       backgroundColor: Colors.white, // Set a background color
//       body: Center(
//         child: RiveAnimation.asset(
//           animationFile, // Your Rive file
//           fit: BoxFit.cover,
//         ),
//       ),
//     );
//   }
// }
