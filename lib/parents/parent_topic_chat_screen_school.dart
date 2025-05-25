import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:confetti/confetti.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';

import 'locale_keys.dart';

class ParentTopicChatScreenSchool extends StatefulWidget {
  const ParentTopicChatScreenSchool({super.key});

  @override
  State<ParentTopicChatScreenSchool> createState() => _ParentTopicChatScreenSchoolState();
}

class _ParentTopicChatScreenSchoolState extends State<ParentTopicChatScreenSchool> {
  final List<Map<String, dynamic>> messages = [
    {
      'sender': 'parent',
      'textKey': LocaleKeys.schoolMessages['q1'],
      'animation': 'images/parent_image/parent_ask.json'
    },
    {
      'sender': 'expert',
      'textKey': LocaleKeys.schoolMessages['a1'],
      'animation': 'images/parent_image/expert_reply.json'
    },
    {
      'sender': 'parent',
      'textKey': LocaleKeys.schoolMessages['q2'],
      'animation': 'images/parent_image/parent_ask.json'
    },
    {
      'sender': 'expert',
      'textKey': LocaleKeys.schoolMessages['a2'],
      'animation': 'images/parent_image/expert_reply.json'
    },
    {
      'sender': 'parent',
      'textKey': LocaleKeys.schoolMessages['q3'],
      'animation': 'images/parent_image/parent_ask.json'
    },
    {
      'sender': 'expert',
      'textKey': LocaleKeys.schoolMessages['a3'],
      'animation': 'images/parent_image/expert_reply.json'
    },
    {
      'sender': 'expert',
      'textKey': LocaleKeys.schoolMessages['a4'],
      'animation': 'images/parent_image/expert_reply.json'
    },
  ];

  int visibleCount = 1;
  late ConfettiController _confettiController;
  final AudioPlayer _tapPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
  }

  void _handleNext() async {
    HapticFeedback.lightImpact();
    await _tapPlayer.play(AssetSource('sounds/voices-parent/screen_tap.mp3'));
    if (visibleCount + 1 == messages.length) {
      _confettiController.play();
    }
    if (visibleCount < messages.length) {
      setState(() {
        visibleCount++;
      });
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _tapPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isEnd = visibleCount == messages.length;
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFBCEB1),
        title: Text(LocaleKeys.schoolTitle.tr()),
      ),
      body: Column(
        children: [
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            colors: [Colors.brown.shade200, Colors.brown.shade100],
            numberOfParticles: 15,
            emissionFrequency: 0.03,
            gravity: 0.18,
            shouldLoop: false,
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: visibleCount,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isParent = msg['sender'] == 'parent';

                return Align(
                  alignment: isParent ? Alignment.centerRight : Alignment.centerLeft,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: isParent ? MainAxisAlignment.end : MainAxisAlignment.start,
                    children: [
                      if (!isParent)
                        Lottie.asset(msg['animation'], width: 50, height: 50),
                      Flexible(
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isParent ? Colors.orange.shade100 : const Color(0xFFFFF3E0),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            (msg['textKey'] as String).tr(),
                            style: const TextStyle(fontSize: 16, height: 1.6),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ),
                      if (isParent)
                        Lottie.asset(msg['animation'], width: 50, height: 50),
                    ],
                  ),
                );
              },
            ),
          ),
          if (!isEnd)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: ElevatedButton(
                onPressed: _handleNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: visibleCount + 1 == messages.length ? Colors.green : Colors.deepOrange,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(visibleCount + 1 == messages.length ? Icons.check : Icons.arrow_forward, color: Colors.white),
                    const SizedBox(width: 8),
                    Text('${LocaleKeys.nextButton.tr()} ($visibleCount / ${messages.length})',
                        style: const TextStyle(fontSize: 18, color: Colors.white)),
                  ],
                ),
              ),
            )
          else
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    LocaleKeys.schoolEndMessage.tr(),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                  label: Text(LocaleKeys.backToTopics.tr()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => setState(() => visibleCount = 1),
                  icon: const Icon(Icons.refresh),
                  label: Text(LocaleKeys.restartConversation.tr()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
        ],
      ),
    );
  }
}
