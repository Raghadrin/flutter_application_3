import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class ResetPasswordScreen extends StatefulWidget {
  final bool isDarkMode;

  const ResetPasswordScreen({
    super.key,
    required this.isDarkMode,
  });

  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isPasswordHidden = true;

  void _resetPassword() {
    if (_newPasswordController.text.isNotEmpty &&
        _newPasswordController.text == _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('passwordChangedSuccessfully'.tr()),
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('passwordsDoNotMatch'.tr()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = widget.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: isDarkMode ? Color(0xFF6E2CB9) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: isDarkMode ? Colors.white : const Color(0xFFEC5417)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'resetPassword'.tr(),
          style: TextStyle(
            color: isDarkMode ? Colors.white : const Color(0xFFEC5417),
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'Arial',
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: isDarkMode
              ? const LinearGradient(
                  colors: [Color(0xFF571E99), Color(0xFF7E3FF2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : const LinearGradient(
                  colors: [
                    Color(0xFFFFFEFD),
                    Color.fromARGB(255, 255, 255, 255)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - kToolbarHeight,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    Icon(Icons.lock,
                        size: 100,
                        color: isDarkMode
                            ? Colors.white70
                            : const Color(0xFFEC5417)),
                    const SizedBox(height: 20),
                    Text(
                      'enterNewPassword'.tr(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Arial',
                        color: isDarkMode ? Colors.white70 : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 30),
                    _buildPasswordField(
                      'newPassword'.tr(),
                      _newPasswordController,
                      isDarkMode,
                    ),
                    const SizedBox(height: 20),
                    _buildPasswordField(
                      'confirmPassword'.tr(),
                      _confirmPasswordController,
                      isDarkMode,
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _resetPassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEC5417),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 40,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        'save'.tr(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontFamily: 'Arial',
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField(
      String hint, TextEditingController controller, bool isDarkMode) {
    return TextField(
      controller: controller,
      obscureText: _isPasswordHidden,
      style: TextStyle(
        color: isDarkMode ? Colors.black : Colors.black,
        fontFamily: 'Arial',
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: isDarkMode ? Colors.grey[600] : Colors.black54,
          fontFamily: 'Arial',
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordHidden ? Icons.visibility_off : Icons.visibility,
            color: isDarkMode ? Colors.grey[600] : Colors.grey,
          ),
          onPressed: () {
            setState(() {
              _isPasswordHidden = !_isPasswordHidden;
            });
          },
        ),
        filled: true,
        fillColor: isDarkMode
            ? const Color.fromARGB(255, 252, 249, 255)
            : Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
