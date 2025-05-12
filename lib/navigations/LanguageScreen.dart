import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class LanguageScreen extends StatelessWidget {
  final bool isDarkMode;

  const LanguageScreen({
    super.key,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'language'.tr(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 26,
            color: isDarkMode ? Colors.white : const Color(0xFFEC5417),
          ),
        ),
        backgroundColor: isDarkMode ? const Color(0xFF6E2CB9) : Colors.white,
        iconTheme: IconThemeData(
          color: isDarkMode ? Colors.white : const Color(0xFFEC5417),
        ),
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: isDarkMode
              ? const LinearGradient(
                  colors: [Color(0xFF571E99), Color(0xFF7E3FF2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : const LinearGradient(
                  colors: [Color(0xFFFFFEFD), Color(0xFFFFF0E4)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLanguageTile(
                context: context,
                label: "English",
                locale: const Locale('en'),
                isSelected: context.locale.languageCode == 'en',
              ),
              const SizedBox(height: 20),
              _buildLanguageTile(
                context: context,
                label: "العربية",
                locale: const Locale('ar'),
                isSelected: context.locale.languageCode == 'ar',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageTile({
    required BuildContext context,
    required String label,
    required Locale locale,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        context.setLocale(locale);
        Navigator.pop(context);
      },
      child: Container(
        width: 250,
        height: 90,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDarkMode
                  ? const Color.fromARGB(255, 204, 177, 255)
                  : const Color(0xFFEC5417))
              : (isDarkMode
                  ? const Color.fromARGB(255, 242, 242, 242)
                  : const Color.fromARGB(255, 255, 255, 255)),
          border: Border.all(
            color: isDarkMode ? Colors.white70 : const Color(0xFFEC5417),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: isSelected
                  ? (isDarkMode ? const Color(0xFF7E3FF2) : Colors.white)
                  : (isDarkMode
                      ? const Color(0xFF7E3FF2)
                      : const Color(0xFFEC5417)),
            ),
          ),
        ),
      ),
    );
  }
}
