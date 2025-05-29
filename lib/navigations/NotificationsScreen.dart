import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

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

  void _initializeNotifications() async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }
  }

  //

  void _scheduleNotificationAt(DateTime dateTime) {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 2,
        channelKey: 'basic_channel',
        title: '🕒 Scheduled Reminder',
        body: 'Lets Have Fun !',
        notificationLayout: NotificationLayout.Default,
      ),
      schedule: NotificationCalendar(
        year: dateTime.year,
        month: dateTime.month,
        day: dateTime.day,
        hour: dateTime.hour,
        minute: dateTime.minute,
        second: 0,
        millisecond: 0,
        repeats: false,
      ),
    );
  }

  void _scheduleDailyReminder() {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 3,
        channelKey: 'basic_channel',
        title: '📆 Daily Practice Reminder',
        body: 'Time to practice today!',
        notificationLayout: NotificationLayout.Default,
      ),
      schedule: NotificationCalendar(
        hour: 8,
        minute: 0,
        second: 0,
        millisecond: 0,
        repeats: true,
      ),
    );
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
                if (value) {
                  _scheduleDailyReminder();
                }
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
                if (value) {
                  DateTime scheduledTime = DateTime.now()
                      .add(Duration(minutes: 1)); // or use a DatePicker
                  _scheduleNotificationAt(scheduledTime);
                }
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
