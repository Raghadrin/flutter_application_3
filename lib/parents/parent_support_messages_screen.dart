import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:lottie/lottie.dart';
import 'package:confetti/confetti.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';
import 'locale_keys.dart';

class ParentSupportMessagesScreen extends StatefulWidget {
  const ParentSupportMessagesScreen({super.key});

  @override
  State<ParentSupportMessagesScreen> createState() => _ParentSupportMessagesScreenState();
}

class _ParentSupportMessagesScreenState extends State<ParentSupportMessagesScreen> with TickerProviderStateMixin {
  final FlutterTts flutterTts = FlutterTts();
  final AudioPlayer _audioPlayer = AudioPlayer();
  late final ConfettiController _confettiController;
  late final TabController _tabController;
  late final PageController _pageController;

  int currentPage = 0;
  String favoriteId = '';

  final List<Map<String, dynamic>> arabicMessages = [
    {
      "id": "effort",
      "title": "وجودك يعني الكثير",
      "message": "تذكّر، أنت تبذل ما بوسعك،\nفمجرد وجودك إلى جانب طفلك يعني الكثير.",
      "audio": {"ar": "support_effort_ar.mp3", "en": "support_effort_en.mp3"},
      "animation": "parent_hug_child.json"
    },
    {
      "id": "path",
      "title": "طريقه الخاص",
      "message": "لا تقارن تقدم طفلك بأي طفل آخر،\nفهو يسير في طريقه الخاص، وأنت تسانده.",
      "audio": {"ar": "support_path_ar.mp3", "en": "support_path_en.mp3"},
      "animation": "walking_path.json"
    },
    {
      "id": "care",
      "title": "اهتمامك لا ضعف",
      "message": "شعورك بالإرهاق لا يعني أنك ضعيف،\nبل يعني أنك تهتم.",
      "audio": {"ar": "support_care_ar.mp3", "en": "support_care_en.mp3"},
      "animation": "heart_care.json"
    },
    {
      "id": "mistake",
      "title": "سامح نفسك",
      "message": "إذا أخطأت، سامح نفسك.\nفلا أحد يتعلّم الأبوة أو الأمومة في يومٍ وليلة.",
      "audio": {"ar": "support_mistake_ar.mp3", "en": "support_mistake_en.mp3"},
      "animation": "self_love.json"
    },
    {
      "id": "rest",
      "title": "خذ وقتًا لنفسك",
      "message": "الراحة ليست أنانية،\nبل ضرورة لتبقى قويًّا ومتماسكًا.",
      "audio": {"ar": "support_rest_ar.mp3", "en": "support_rest_en.mp3"},
      "animation": "relaxing_mom.json"
    },
    {
      "id": "love",
      "title": "حبك أهم من الكمال",
      "message": "ليس عليك معرفة كل الإجابات،\nطفلك يحتاج إلى حبك أكثر من مثاليتك.",
      "audio": {"ar": "support_love_ar.mp3", "en": "support_love_en.mp3"},
      "animation": "love_over_perfection.json"
    },
  ];

  final List<Map<String, dynamic>> englishMessages = [
    {
      "id": "effort",
      "title": "Your Presence Matters",
      "message": "Remember, you’re doing your best.\nJust being by your child’s side means so much.",
      "audio": {"ar": "support_effort_ar.mp3", "en": "support_effort_en.mp3"},
      "animation": "parent_hug_child.json"
    },
    {
      "id": "path",
      "title": "Their Own Path",
      "message": "Don’t compare your child to others.\nThey are walking their own path—and you are supporting them.",
      "audio": {"ar": "support_path_ar.mp3", "en": "support_path_en.mp3"},
      "animation": "walking_path.json"
    },
    {
      "id": "care",
      "title": "Caring Isn’t Weakness",
      "message": "Feeling tired doesn’t mean you’re weak.\nIt means you care and you’re trying your best.",
      "audio": {"ar": "support_care_ar.mp3", "en": "support_care_en.mp3"},
      "animation": "heart_care.json"
    },
    {
      "id": "mistake",
      "title": "Forgive Yourself",
      "message": "If you make a mistake, forgive yourself.\nNo one learns parenting in a single day.",
      "audio": {"ar": "support_mistake_ar.mp3", "en": "support_mistake_en.mp3"},
      "animation": "self_love.json"
    },
    {
      "id": "rest",
      "title": "Take Time for Yourself",
      "message": "Rest is not selfish.\nIt’s necessary so you can stay strong and steady.",
      "audio": {"ar": "support_rest_ar.mp3", "en": "support_rest_en.mp3"},
      "animation": "relaxing_mom.json"
    },
    {
      "id": "love",
      "title": "Love Is More Important Than Perfection",
      "message": "You don’t have to know all the answers.\nYour child needs your love more than your perfection.",
      "audio": {"ar": "support_love_ar.mp3", "en": "support_love_en.mp3"},
      "animation": "love_over_perfection.json"
    },
  ];

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    _tabController = TabController(length: 2, vsync: this);
    _pageController = PageController(viewportFraction: 0.88);
    _loadFavorite();
  }

  Future<void> _loadFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    favoriteId = prefs.getString('favorite_message') ?? '';
    setState(() {});
  }

  Future<void> _saveFavorite(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('favorite_message', id);
    setState(() => favoriteId = id);
  }

  Future<void> _playVoice(String fileName) async {
    await _audioPlayer.stop();
    await _audioPlayer.play(AssetSource('sounds/voices-parent/$fileName'));
  }

  Future<void> _showCompletionDialog() async {
    _confettiController.play();
    showDialog(
      context: context,
      builder: (_) => Stack(
        alignment: Alignment.center,
        children: [
          Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Lottie.asset('images/parent_image/thank_you.json', height: 120),
                  const SizedBox(height: 16),
                  Text(
                    LocaleKeys.supportFinish.tr(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFF8E1),
                      foregroundColor: Colors.deepOrange,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: Colors.deepOrange),
                      ),
                    ),
                    child: Text(LocaleKeys.supportClose.tr()),
                  ),
                ],
              ),
            ),
          ),
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: [Colors.orange, Colors.amber, Colors.yellow, Colors.deepOrangeAccent],
          ),
        ],
      ),
    );
  }

  Widget _buildCard(Map<String, dynamic> msg, String language) {
    final isFavorite = msg['id'] == favoriteId;
    final screenHeight = MediaQuery.of(context).size.height;
    final isShortScreen = screenHeight < 650;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 6, offset: const Offset(0, 4)),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      mainAxisAlignment:
                          isShortScreen ? MainAxisAlignment.start : MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Lottie.asset('images/parent_image/${msg["animation"]}', height: 140),
                        const SizedBox(height: 12),
                        Text(
                          msg['title'],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepOrange),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          msg['message'],
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 20),
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 12,
                          runSpacing: 8,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () => _playVoice(msg['audio'][language]),
                              icon: const Icon(Icons.volume_up),
                              label: Text(LocaleKeys.supportListen.tr()),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFFF8E1),
                                foregroundColor: Colors.deepOrange,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: const BorderSide(color: Colors.deepOrange),
                                ),
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: () => _saveFavorite(msg['id']),
                              icon: Icon(Icons.star,
                                  color: isFavorite ? Colors.amber : Colors.deepOrange),
                              label: Text(isFavorite
                                  ? LocaleKeys.supportFavorite.tr()
                                  : LocaleKeys.supportMarkFavorite.tr()),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFFF8E1),
                                foregroundColor: Colors.deepOrange,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: const BorderSide(color: Colors.deepOrange),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(LocaleKeys.supportTitle.tr()),
          backgroundColor: const Color(0xFFFBCEB1),
          foregroundColor: Colors.black,
          elevation: 0,
          bottom: TabBar(
            indicatorColor: Colors.deepOrange,
            labelColor: Colors.black,
            unselectedLabelColor: Colors.black54,
            tabs: [
              Tab(text: LocaleKeys.supportTabArabic.tr()),
              Tab(text: LocaleKeys.supportTabEnglish.tr()),
            ],
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFFF4E5), Color(0xFFFFE0B2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: TabBarView(
                  children: [arabicMessages, englishMessages].map((msgList) {
                    return Column(
                      children: [
                        Expanded(
                          child: PageView.builder(
                            controller: _pageController,
                            itemCount: msgList.length,
                            onPageChanged: (index) => setState(() => currentPage = index),
                            itemBuilder: (_, index) => _buildCard(
                                msgList[index], msgList == arabicMessages ? 'ar' : 'en'),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(msgList.length, (dotIndex) {
                            final isActive = dotIndex == currentPage;
                            return GestureDetector(
                              onTap: () => _pageController.animateToPage(
                                dotIndex,
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeInOut,
                              ),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                width: isActive ? 14 : 10,
                                height: isActive ? 14 : 10,
                                decoration: BoxDecoration(
                                  color: isActive ? Colors.deepOrange : Colors.orange.shade200,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: ElevatedButton(
                  onPressed: _showCompletionDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFF8E1),
                    foregroundColor: Colors.deepOrange,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: Colors.deepOrange),
                    ),
                  ),
                  child: Text(LocaleKeys.supportDone.tr()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
