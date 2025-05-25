import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import 'locale_keys.dart';
import 'parent_topic_chat_screen_dyslexia.dart';
import 'parent_topic_chat_screen_dyscalculia.dart';
import 'parent_topic_chat_screen_emotion.dart';
import 'parent_topic_chat_screen_school.dart';

class ParentTopicsGridScreen extends StatefulWidget {
  const ParentTopicsGridScreen({super.key});

  @override
  State<ParentTopicsGridScreen> createState() => _ParentTopicsGridScreenState();
}

class _ParentTopicsGridScreenState extends State<ParentTopicsGridScreen> with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<Animation<Offset>> _slideAnimations;
  late final List<Animation<double>> _fadeAnimations;

  final topics = [
    {
      'id': 'emotion',
      'titleKey': LocaleKeys.topicEmotion,
      'color': const Color(0xFFFFEDE5),
      'image': 'images/parent_image/emotion_behaviour.png',
      'screen': const ParentTopicChatScreenEmotion(),
    },
    {
      'id': 'dyslexia',
      'titleKey': LocaleKeys.topicDyslexia,
      'color': const Color(0xFFF0F7FF),
      'image': 'images/parent_image/dyslexia.png',
      'screen': const ParentTopicChatScreenDyslexia(),
    },
    {
      'id': 'dyscalculia',
      'titleKey': LocaleKeys.topicDyscalculia,
      'color': const Color(0xFFFFF8E1),
      'image': 'images/parent_image/discalculia.png',
      'screen': const ParentTopicChatScreenDyscalculia(),
    },
    {
      'id': 'school',
      'titleKey': LocaleKeys.topicSchool,
      'color': const Color(0xFFE9F8EF),
      'image': 'images/parent_image/School.png',
      'screen': const ParentTopicChatScreenSchool(),
    },
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1300),
      vsync: this,
    );

    _slideAnimations = [];
    _fadeAnimations = [];

    const intervalStep = 0.15;

    for (int i = 0; i < topics.length; i++) {
      final start = i * intervalStep;
      final end = (start + 0.6).clamp(0.0, 1.0);

      final curved = CurvedAnimation(
        parent: _controller,
        curve: Interval(start, end, curve: Curves.elasticOut),
      );

      _slideAnimations.add(
        Tween<Offset>(begin: const Offset(0.0, 0.4), end: Offset.zero).animate(curved),
      );

      _fadeAnimations.add(
        Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
          parent: _controller,
          curve: Interval(start, end, curve: Curves.easeIn),
        )),
      );
    }

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final screenWidth = constraints.maxWidth;
      final crossAxisCount = screenWidth < 600 ? 2 : 3;
      final isTablet = screenWidth > 800;
      final imageSize = isTablet ? 90.0 : 60.0;
      final fontSize = isTablet ? 20.0 : 16.0;

      return Scaffold(
        appBar: AppBar(
          title: Text(LocaleKeys.parentTopicsTitle.tr()),
          backgroundColor: const Color(0xFFFBCEB1),
        ),
        body: Stack(
          children: [
            CustomPaint(
              size: Size(screenWidth, double.infinity),
              painter: CurvedBackgroundPainter(),
            ),
            GridView.count(
              crossAxisCount: crossAxisCount,
              padding: const EdgeInsets.all(20),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: List.generate(topics.length, (index) {
                final topic = topics[index];

                return SlideTransition(
                  position: _slideAnimations[index],
                  child: FadeTransition(
                    opacity: _fadeAnimations[index],
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TopicScreenWithHero(
                              imagePath: topic['image'] as String,
                              screen: topic['screen'] as Widget,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: topic['color'] as Color,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade300,
                              blurRadius: 6,
                              offset: const Offset(2, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              topic['image'] as String,
                              height: imageSize,
                            ),
                            const SizedBox(height: 10),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                (topic['titleKey'] as String).tr(),
                                style: TextStyle(
                                  fontSize: fontSize,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                  height: 1.4,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      );
    });
  }
}

class TopicScreenWithHero extends StatelessWidget {
  final String imagePath;
  final Widget screen;

  const TopicScreenWithHero({
    super.key,
    required this.imagePath,
    required this.screen,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(""),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackButton(color: Colors.black),
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Image.asset(
              imagePath,
              height: 120,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(child: screen),
        ],
      ),
    );
  }
}

class CurvedBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final topPaint = Paint()
      ..color = const Color(0xFFFFF3E0)
      ..style = PaintingStyle.fill;

    final bottomPaint = Paint()
      ..color = const Color(0xFFFFE0B2)
      ..style = PaintingStyle.fill;

    final topPath = Path()
      ..lineTo(0, size.height * 0.15)
      ..quadraticBezierTo(size.width * 0.5, size.height * 0.28, size.width, size.height * 0.15)
      ..lineTo(size.width, 0)
      ..close();

    final bottomPath = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, size.height * 0.85)
      ..quadraticBezierTo(size.width * 0.5, size.height * 0.72, size.width, size.height * 0.85)
      ..lineTo(size.width, size.height)
      ..close();

    canvas.drawPath(topPath, topPaint);
    canvas.drawPath(bottomPath, bottomPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
