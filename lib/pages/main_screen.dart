import 'package:flutter/material.dart';
import 'package:flutter_application_3/navigations/ProfileManagementScreen.dart';
import 'package:flutter_application_3/pages/settings_screen.dart';
import 'package:flutter_application_3/pages/subjects_screen.dart';
import 'package:flutter_application_3/parents/parent_dashboard_screen.dart';
import 'package:easy_localization/easy_localization.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool isDarkMode = false;

  void toggleDarkMode() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  void openSettingsMenu() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsScreen(
          isDarkMode: isDarkMode,
        ),
      ),
    ).then((_) {
      // Force a rebuild when returning from settings to apply language change
      setState(() {});
    });
  }

  void onSubjectsButtonPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SubjectsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final Color buttonColor = isDarkMode
        ? const Color.fromARGB(255, 72, 213, 235)
        : const Color.fromARGB(255, 255, 193, 143);

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      body: Container(
        decoration: BoxDecoration(
          gradient: isDarkMode
              ? const LinearGradient(
                  colors: [
                    Color.fromARGB(255, 157, 88, 237),
                    Color(0xFF7E3FF2)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : const LinearGradient(
                  colors: [Color(0xFFD7FBE0), Color(0xFFAFFFD7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
        ),
        child: Builder(builder: (context) {
          return Column(
            children: [
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: openSettingsMenu,
                      child: Column(
                        children: [
                          Icon(
                            Icons.settings,
                            size: 28,
                            color: isDarkMode
                                ? Colors.white
                                : const Color(0xFFEC5417),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'settings'.tr(),
                            style: TextStyle(
                              color: isDarkMode ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                              //fontFamily: 'Arial',
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProfileManagementScreen(
                              isDarkMode: isDarkMode,
                            ),
                          ),
                        );
                      },
                      child: Column(
                        children: [
                          const SizedBox(height: 40),
                          const CircleAvatar(
                            radius: 40,
                            backgroundImage: AssetImage('images/logo.jpg'),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'profile'.tr(),
                            style: TextStyle(
                              color: isDarkMode ? Colors.white : Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              // fontFamily: 'Arial',
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: toggleDarkMode,
                      child: Column(
                        children: [
                          Icon(
                            isDarkMode
                                ? Icons.wb_sunny
                                : Icons.nightlight_round,
                            size: 28,
                            color: isDarkMode
                                ? const Color(0xFFFFDA38)
                                : const Color(0xFFEC5417),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isDarkMode ? 'lightMode'.tr() : 'darkMode'.tr(),
                            style: TextStyle(
                              color: isDarkMode ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                              // fontFamily: 'Arial',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 45),
              Image.asset('images/fox_main_screen2.png',
                  height: screenHeight * 0.34),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: GestureDetector(
                      onTap: onSubjectsButtonPressed,
                      child: Container(
                        margin: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.02),
                        padding: EdgeInsets.all(screenWidth * 0.027),
                        decoration: BoxDecoration(
                          color: buttonColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset('images/subject.png',
                                height: screenHeight * 0.18),
                            SizedBox(height: screenHeight * 0.01),
                            Text(
                              'subjects'.tr(),
                              style: TextStyle(
                                fontSize: screenHeight * 0.03,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode ? Colors.white : Colors.black,
                                // fontFamily: 'Arial',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ParentDashboardScreen(),
                          ),
                        );
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.02),
                        padding: EdgeInsets.all(screenWidth * 0.03),
                        decoration: BoxDecoration(
                          color: buttonColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset('images/parents.png',
                                height: screenHeight * 0.18),
                            SizedBox(height: screenHeight * 0.01),
                            Text(
                              'parent'.tr(),
                              style: TextStyle(
                                fontSize: screenHeight * 0.03,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode ? Colors.white : Colors.black,
                                //fontFamily: 'Arial',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              )

              //const Spacer(),
            ],
          );
        }),
      ),
    );
  }
}
