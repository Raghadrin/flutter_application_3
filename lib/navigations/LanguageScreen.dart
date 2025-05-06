import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDarkMode ? const Color.fromARGB(255, 110, 44, 185) : Colors.white,
      appBar: AppBar(
        title: Text(
          'language'.tr(),
          style: TextStyle(fontSize: 32),
        ), // Translation for the title
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: isDarkMode
            ? const Color.fromARGB(255, 110, 44, 185)
            : const Color.fromARGB(255, 255, 114, 26),
      ),
      body: Center(
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
    );
  }

  Widget _buildLanguageTile({
    required BuildContext context,
    required String label,
    required Locale locale,
    required bool isSelected,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        context
            .setLocale(locale); // Use easy_localization's method to set locale
        Navigator.pop(context); // Close the language screen after changing
      },
      child: Container(
        width: 250,
        height: 90,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDarkMode ? Colors.deepPurple : const Color(0xFFEC5417))
              : (isDarkMode ? Colors.deepPurple[800] : Colors.white),
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
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 32,
            color: isSelected
                ? Colors.white
                : (isDarkMode ? Colors.white : const Color(0xFFEC5417)),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
