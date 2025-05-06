import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_3/navigations/child_info.dart';
import 'package:easy_localization/easy_localization.dart';

class ProfileManagementScreen extends StatefulWidget {
  final bool isDarkMode;

  const ProfileManagementScreen({
    super.key,
    required this.isDarkMode,
  });

  @override
  _ProfileManagementScreenState createState() =>
      _ProfileManagementScreenState();
}

class _ProfileManagementScreenState extends State<ProfileManagementScreen> {
  List<Map<String, dynamic>> children = [];
  Map<String, dynamic>? selectedChild;

  @override
  void initState() {
    super.initState();
    fetchChildren();
  }

  Future<void> fetchChildren() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('parents')
          .doc(user.uid)
          .collection('children')
          .orderBy('timestamp', descending: true)
          .get();

      setState(() {
        children = snapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
        if (children.isNotEmpty) {
          selectedChild = children[0];
        }
      });
    }
  }

  void _navigateToAddChild() async {
    bool? childAdded = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ChildInfoScreen()),
    );

    if (childAdded == true) {
      fetchChildren();
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = widget.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'profileManagement'.tr(),
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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 20),
              children.isNotEmpty
                  ? Expanded(
                      child: ListView.builder(
                        itemCount: children.length,
                        itemBuilder: (context, index) {
                          final child = children[index];
                          final isSelected = selectedChild == child;

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedChild = child;
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? (isDarkMode
                                        ? Colors.deepPurple[600]
                                        : Colors.orange[100])
                                    : (isDarkMode
                                        ? Colors.deepPurple[800]
                                        : Colors.white),
                                borderRadius: BorderRadius.circular(12),
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
                                  CircleAvatar(
                                    radius: 48,
                                    backgroundColor: isSelected
                                        ? const Color(0xFFEC5417)
                                        : Colors.grey,
                                    child: const Icon(Icons.person,
                                        size: 50, color: Colors.white),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: Text(
                                      child['name'],
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w600,
                                        color: isDarkMode
                                            ? Colors.white
                                            : Colors.black87,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.check_circle,
                                    color: isSelected
                                        ? Colors.green
                                        : Colors.transparent,
                                    size: 28,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  : Center(
                      child: Text(
                        'noChildrenAdded'.tr(),
                        style: TextStyle(
                          fontSize: 18,
                          color: isDarkMode ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _navigateToAddChild,
                icon: const Icon(Icons.add),
                label: Text(
                  'addChild'.tr(),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEC5417),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
