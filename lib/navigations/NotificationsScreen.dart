import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart'; // Import easy_localization

class NotificationsScreen extends StatefulWidget {
  final bool isDarkMode;

  const NotificationsScreen({
    super.key,
    required this.isDarkMode,
  });

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool practiceReminder = false;
  bool smartScheduling = false;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  void _initializeNotifications() {
    // Placeholder for initializing notification logic
    // Will be updated once a new notification library is chosen
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = widget.isDarkMode;

    return Scaffold(
      backgroundColor:
          isDarkMode ? const Color.fromARGB(255, 110, 44, 185) : Colors.white,
      appBar: AppBar(
        backgroundColor:
            isDarkMode ? const Color.fromARGB(255, 110, 44, 185) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: isDarkMode ? Colors.white : const Color(0xFFEC5417)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'notifications'.tr(), // Use easy_localization for the title
          style: TextStyle(
            color: isDarkMode ? Colors.white : const Color(0xFFEC5417),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: Text(
          'notificationsComingSoon'.tr(), // Use easy_localization for the text
          style: TextStyle(
            color: isDarkMode ? Colors.white70 : Colors.black87,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
