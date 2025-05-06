// import 'package:flutter/material.dart';

// // ---------------- Subjects Screen ----------------
// class SubjectsScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back, color: Colors.black),
//           onPressed: () {},
//         ),
//         title: Align(
//           alignment: Alignment.centerLeft,
//           child: Text("Subjects",
//               style: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Arial')),
//         ),
//       ),
//       body: Column(
//         children: [
//           SizedBox(height: 20),
//           Image.asset("images/subject_fox.jpg", height: 150),
//           SizedBox(height: 20),
//           Text("Choose a subject", style: TextStyle(color: Colors.grey, fontSize: 16, fontFamily: 'Arial')),
//           SizedBox(height: 20),
//           _buildSubjectButton(context, "Arabic", "images/arabicsubject.png"),
//           _buildSubjectButton(context, "English", "images/englishsubject.png"),
//           _buildSubjectButton(context, "Mathematics", "images/mathsubject.png"),
//           Spacer(),
//           Container(height: 8, width: double.infinity, color: Color(0xFFFAAE71)),
//         ],
//       ),
//     );
//   }

//   Widget _buildSubjectButton(BuildContext context, String text, String iconPath) {
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 30.0),
//       child: GestureDetector(
//         onTap: () {
//           Navigator.push(context, MaterialPageRoute(builder: (context) => DiagnosticTestScreen(subject: text)));
//         },
//         child: Container(
//           height: 70,
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(15),
//             gradient: LinearGradient(
//               colors: [Color(0xFFFBD1B2), Color(0xFFFEE5D3)],
//             ),
//           ),
//           child: ListTile(
//             leading: Image.asset(iconPath, height: 40),
//             title: Text(text, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Arial')),
//           ),
//         ),
//       ),
//     );
//   }
// }

// // ---------------- Diagnostic Test Screen ----------------
// class DiagnosticTestScreen extends StatelessWidget {
//   final String subject;
//   DiagnosticTestScreen({required this.subject});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back, color: Colors.black),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//         title: Align(
//           alignment: Alignment.centerLeft,
//           child: Text(subject,
//               style: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Arial')),
//         ),
//       ),
//       body: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Image.asset("images/subject_fox.jpg", height: 150),
//           SizedBox(height: 30),
//           Container(
//             padding: EdgeInsets.all(20),
//             margin: EdgeInsets.symmetric(horizontal: 40),
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(15),
//               color: Color(0xFFFDD1B4),
//             ),
//             child: Column(
//               children: [
//                 Text("Main Diagnostic Test",
//                     style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Arial')),
//                 SizedBox(height: 15),
//                 ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Color(0xFFEC5417),
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//                     padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
//                   ),
//                   onPressed: () {
//                     Navigator.push(context,
//                         MaterialPageRoute(builder: (context) => PracticeLevelsScreen(subject: subject)));
//                   },
//                   child: Text("Start", style: TextStyle(fontSize: 18, color: Colors.white, fontFamily: 'Arial')),
//                 ),
//               ],
//             ),
//           ),
//           Spacer(),
//           Container(height: 8, width: double.infinity, color: Color(0xFFFAAE71)),
//         ],
//       ),
//     );
//   }
// }

// // ---------------- Practice Levels Screen ----------------
// class PracticeLevelsScreen extends StatelessWidget {
//   final String subject;
//   PracticeLevelsScreen({required this.subject});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back, color: Colors.black),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//         title: Align(
//           alignment: Alignment.centerLeft,
//           child: Text(subject,
//               style: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Arial')),
//         ),
//       ),
//       body: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Image.asset("images/subject_fox.jpg", height: 150),
//           SizedBox(height: 20),
//           _buildLevelButton(context, "Practice", subject),
//           _buildLevelButton(context, "Quiz", subject),
//           _buildLevelButton(context, "Library", subject),
//           Spacer(),
//           Container(height: 8, width: double.infinity, color: Color(0xFFFAAE71)),
//         ],
//       ),
//     );
//   }

//   Widget _buildLevelButton(BuildContext context, String text, String subject) {
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 50.0),
//       child: GestureDetector(
//         onTap: () {
//           if (text == "Practice") {
//             Navigator.push(context, MaterialPageRoute(builder: (context) => LevelsScreen(subject: subject)));
//           }
//         },
//         child: Container(
//           height: 55,
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(15),
//             color: Color(0xFFFED2B5),
//           ),
//           child: Center(
//             child: Text(
//               text,
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//                 fontFamily: 'Arial',
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// // ---------------- Levels Screen for Practice ----------------
// class LevelsScreen extends StatelessWidget {
//   final String subject;
//   LevelsScreen({required this.subject});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back, color: Colors.black),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//         title: Align(
//           alignment: Alignment.centerLeft,
//           child: Text(subject,
//               style: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Arial')),
//         ),
//       ),
//       body: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Image.asset("images/subject_fox.PNG", height: 150),
//           SizedBox(height: 20),
//           _buildLevelOption(context, "Level 1"),
//           _buildLevelOption(context, "Level 2"),
//           _buildLevelOption(context, "Level 3"),
//           Spacer(),
//           Container(height: 8, width: double.infinity, color: Color(0xFFFAAE71)),
//         ],
//       ),
//     );
//   }

//   Widget _buildLevelOption(BuildContext context, String level) {
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 50.0),
//       child: Container(
//         height: 55,
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(15),
//           color: Color(0xFFFED2B5),
//         ),
//         child: Center(
//           child: Text(
//             level,
//             style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Arial'),
//           ),
//         ),
//       ),
//     );
//   }
// }
