import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_application_3/parents/ChildDifficultyAnalysisScreen.dart';
import 'package:flutter_application_3/parents/child_performance_screen.dart';

import 'awareness_videos_screen.dart';
import 'parent_support_messages_screen.dart';
import 'parent_topics_grid_screen.dart';
import 'locale_keys.dart';

class ParentDashboardScreen extends StatelessWidget {
  const ParentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      _DashboardItem(
        titleKey: LocaleKeys.supportMessages,
        imagePath: 'images/parent_image/heart.png',
        heroTag: 'support',
        screen: const ParentSupportMessagesScreen(),
      ),
      _DashboardItem(
        titleKey: LocaleKeys.awarenessVideos,
        imagePath: 'images/parent_image/video-icon.png',
        heroTag: 'awareness',
        screen: const AwarenessVideosScreen(),
      ),
      _DashboardItem(
        titleKey: LocaleKeys.childProgress,
        imagePath: 'images/parent_image/progress-icon.png',
        heroTag: 'progress',
        screen: const CombinedChildPerformanceScreen(),
      ),
      _DashboardItem(
        titleKey: 'Child Analysis'.tr(),
        imagePath: 'images/ana.png',
        heroTag: 'Difficulty Analysis',
        screen: ChildDifficultyAnalysisScreen(),
      ),
      _DashboardItem(
        titleKey: LocaleKeys.supportTopics,
        imagePath: 'images/parent_image/message_icon.jpg',
        heroTag: 'topics',
        screen: const ParentTopicsGridScreen(),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.dashboardTitle.tr(),
            style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: GridView.builder(
          itemCount: items.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
            childAspectRatio: 1,
          ),
          itemBuilder: (context, index) {
            final item = items[index];
            return Hero(
              tag: item.heroTag,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => item.screen),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3E9),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(item.imagePath, width: 48, height: 48),
                        const SizedBox(height: 10),
                        Text(
                          item.titleKey.tr(),
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _DashboardItem {
  final String titleKey;
  final String imagePath;
  final String heroTag;
  final Widget screen;

  _DashboardItem({
    required this.titleKey,
    required this.imagePath,
    required this.heroTag,
    required this.screen,
  });
}
