import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

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
    final textColor = isDarkMode ? Colors.white : Colors.black87;

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
          'notifications'.tr(),
          style: TextStyle(
            color: isDarkMode ? Colors.white : const Color(0xFFEC5417),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'NotificationSettings'.tr(),
              style: TextStyle(
                color: textColor,
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            _buildNotificationTile(
              title: 'PracticeReminders'.tr(),
              subtitle: 'PracticeRemindersDesc'.tr(),
              value: practiceReminder,
              onChanged: (value) {
                setState(() {
                  practiceReminder = value;
                });
              },
              isDarkMode: isDarkMode,
            ),
            const SizedBox(height: 30),
            _buildNotificationTile(
              title: 'SmartScheduling'.tr(),
              subtitle: 'SmartSchedulingDesc'.tr(),
              value: smartScheduling,
              onChanged: (value) {
                setState(() {
                  smartScheduling = value;
                });
              },
              isDarkMode: isDarkMode,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required bool isDarkMode,
  }) {
    return SwitchListTile(
      title: Text(
        title,
        style: TextStyle(
          color: isDarkMode ? Colors.white : Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 23,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: isDarkMode ? Colors.white70 : Colors.black54,
          fontSize: 20,
        ),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: const Color(0xFFEC5417),
    );
  }
}
