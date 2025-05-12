import 'package:flutter/material.dart';
import 'package:flutter_application_3/navigations/LanguageScreen.dart';
import 'package:flutter_application_3/navigations/NotificationsScreen.dart';
import 'package:flutter_application_3/navigations/ProfileManagementScreen.dart';
import 'package:flutter_application_3/navigations/ResetPasswordScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_3/auth/Login.dart';
import 'package:easy_localization/easy_localization.dart';

class SettingsScreen extends StatefulWidget {
  final bool isDarkMode;
  //final VoidCallback toggleDarkMode;

  const SettingsScreen({
    super.key,
    required this.isDarkMode,
    //required this.toggleDarkMode,
  });

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Future<void> _logOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } catch (e) {
      print("Error during log out: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = widget.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'settings'.tr(),
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 26,
            fontFamily: 'Arial',
            color: isDarkMode ? Colors.white : const Color(0xFFEC5417),
          ),
        ),
        backgroundColor:
            isDarkMode ? Color.fromARGB(255, 90, 36, 190) : Colors.white,
        iconTheme: IconThemeData(
          color: isDarkMode ? Colors.white : const Color(0xFFEC5417),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: isDarkMode
              ? const LinearGradient(
                  colors: [
                    Color.fromARGB(255, 134, 50, 230),
                    Color(0xFF7E3FF2)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : const LinearGradient(
                  colors: [
                    Color.fromARGB(255, 255, 254, 253),
                    Color.fromARGB(255, 255, 240, 228),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildTile(
                icon: Icons.person,
                title: 'profile'.tr(),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ProfileManagementScreen(isDarkMode: isDarkMode),
                  ),
                ),
              ),
              _buildTile(
                icon: Icons.notifications,
                title: 'notifications'.tr(),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        NotificationsScreen(isDarkMode: isDarkMode),
                  ),
                ),
              ),
              _buildTile(
                icon: Icons.language,
                title: 'language'.tr(),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        LanguageScreen(isDarkMode: isDarkMode),
                  ),
                ),
              ),
              _buildTile(
                icon: Icons.lock_reset,
                title: 'resetPassword'.tr(),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ResetPasswordScreen(isDarkMode: isDarkMode),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: Icon(Icons.exit_to_app, size: 26),
                label: Text(
                  'logout'.tr(),
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Arial',
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDarkMode
                      ? const Color.fromARGB(255, 143, 81, 250)
                      : const Color(0xFFEC5417),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 30,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _logOut,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
  }) {
    final isDarkMode = widget.isDarkMode;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDarkMode
              ? const Color.fromARGB(255, 245, 244, 247)
              : Colors.white,
          borderRadius: BorderRadius.circular(10), // more squared look
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDarkMode
                  ? const Color.fromARGB(255, 143, 81, 250)
                  : const Color(0xFFEC5417),
              size: 60,
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode
                      ? const Color.fromARGB(255, 143, 81, 250)
                      : Colors.black,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: isDarkMode ? Colors.white38 : Colors.grey,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
