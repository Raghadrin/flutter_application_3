import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:easy_localization/easy_localization.dart';
import 'parent_playlist_screen.dart';
import 'locale_keys.dart';

class AwarenessVideosScreen extends StatefulWidget {
  const AwarenessVideosScreen({super.key});

  @override
  State<AwarenessVideosScreen> createState() => _AwarenessVideosScreenState();
}

class _AwarenessVideosScreenState extends State<AwarenessVideosScreen> with SingleTickerProviderStateMixin {
  String selectedArabicCategory = 'الكل';
  String selectedEnglishCategory = 'All';
  String arabicKeyword = '';
  String englishKeyword = '';

  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

 final List<Map<String, String>> arabicVideos = [
    {
      'title': 'عسر القراءة ',
      'description': 'ما هو عسر القراءة؟',
      'videoUrl': 'https://youtu.be/r128A7Qpr8s',
      'category': 'مفهوم'
    },
    {
      'title': 'أعراض عسر القراءة عند الأطفال',
      'description': 'أبرز المؤشرات التي تظهر على الطفل المصاب.',
      'videoUrl': 'https://youtu.be/rQXBk1qPpbU',
      'category': 'مفهوم'
    },
    {
      'title': 'طرق عملية لدعم الأطفال الذين يعانون من عسر القراءة',
      'description': 'نصائح مباشرة للأهل والمعلمين.',
      'videoUrl': 'https://youtu.be/JA12EgTbDDQ',
      'category': 'إرشادات عملية'
    },
    {
      'title': 'حل مشكلة صعوبة القراءة عند الأطفال',
      'description': 'شرح مفصل لمظاهر عسر القراءة وطرق معالجتها.',
      'videoUrl': 'https://youtu.be/dzNPL4tGLa8',
      'category': 'مفهوم'
    },
    {
      'title': 'فيديو تعليمي شامل عن عسر القراءة',
      'description': 'مادة توعوية موجهة للأهل والمعلمين.',
      'videoUrl': 'https://youtu.be/o9D8rUla-pI',
      'category': 'توعوي'
    },
    {
      'title': 'عسر القراءة',
      'description': 'كيف يتعامل الآباء مع صعوبات التعلم.',
      'videoUrl': 'https://youtu.be/B_6MTHmc-3c',
      'category': 'دعم نفسي'
    },
    {
      'title': 'استراتيجيات دعم الطلاب',
      'description': 'طرق عملية لمساعدة الطلاب.',
      'videoUrl': 'https://youtu.be/zmOVacnQN5c',
      'category': 'استراتيجيات'
    },
    {
      'title': 'محاضرة السبع خطوات لعسر القراءة',
      'description': 'قائمة تشغيل كاملة لتدريب الأهل.',
      'videoUrl': 'playlist',
      'category': 'إرشادات عملية'
    },
    {
      'title': 'عسر الحساب - هذا الصباح',
      'description': 'عسر الحساب معضلة للأطفال.. فكيف نواجهها؟',
      'videoUrl': 'https://youtu.be/i9rs07XUlsE',
      'category': 'عسر الحساب'
    },
    {
      'title': 'قواعد لتجاوز عسر الحساب',
      'description': 'استراتيجيات عملية لتجاوز اضطراب عسر الحساب لدى الطلاب.',
      'videoUrl': 'https://youtu.be/z7ii7fAYJCY',
      'category': 'عسر الحساب'
    },
    {
      'title': 'ما هو عسر الحساب؟',
      'description': 'عسر الحساب أو الديسكالكوليا عند الأطفال... ما هو؟',
      'videoUrl': 'https://youtu.be/Mlh-I9nYnuo',
      'category': 'عسر الحساب'
    },
    {
      'title': 'عسر الرياضيات Dyscalculia',
      'description': 'نظرة عامة عن عسر الحساب عند الأطفال.',
      'videoUrl': 'https://youtu.be/rm4AhQB5nv8',
      'category': 'عسر الحساب'
    },
    {
      'title': 'صعوبات تعلم الحساب',
      'description': 'قائمة تشغيل تحتوي على عشرات المحاضرات حول عسر الحساب.',
      'videoUrl': 'playlist_math',
      'category': 'أنشطة تعليمية'
    },
  ];

  final List<Map<String, String>> englishVideos = [
    {
      'title': 'Why the dyslexic brain is misunderstood',
      'description': 'Understanding how the brain functions differently in dyslexia.',
      'videoUrl': 'https://youtu.be/yH5Ds4_0lO8',
      'category': 'Concept'
    },
    {
      'title': 'What is Dyslexia | Child Mind Institute',
      'description': 'A clinical explanation of dyslexia for parents.',
      'videoUrl': 'https://youtu.be/leFyIX4e3Xk',
      'category': 'Concept'
    },
    {
      'title': 'Signs of Dyslexia | Child Mind Institute',
      'description': 'Common indicators to recognize dyslexia early.',
      'videoUrl': 'https://youtu.be/kPp3MQbdjn0',
      'category': 'Awareness'
    },
    {
      'title': 'Advice for Parents of Children with Dyslexia',
      'description': 'Supportive guidance for dealing with dyslexia.',
      'videoUrl': 'https://youtu.be/vSMBqdqCqQk',
      'category': 'Support'
    },
    {
      'title': 'How to Teach Kids With Dyslexia to Read',
      'description': 'Practical strategies from experts at CMI.',
      'videoUrl': 'https://youtu.be/7DdrfCj_POE',
      'category': 'Strategies'
    },
    {
      'title': 'Things Parents of Children With Dyslexia Want Others to Know',
      'description': 'Empathy and understanding of parenting dyslexic kids.',
      'videoUrl': 'https://youtu.be/6Q6T8m1KQHY',
      'category': 'Awareness'
    },
    {
      'title': 'Dyscalculia — A Parent\'s Guide',
      'description': 'Comprehensive guide for parents on dyscalculia.',
      'videoUrl': 'https://youtu.be/GstqJ5sEEoo',
      'category': 'Dyscalculia'
    },
    {
      'title': 'What can parents do for their child if dyscalculia is detected at a later stage?',
      'description': 'Steps and support for late diagnosis.',
      'videoUrl': 'https://youtu.be/06VCBF9oQWU',
      'category': 'Dyscalculia'
    },
    {
      'title': 'What is the ideal therapy for dyscalculia?',
      'description': 'Evidence-based therapeutic suggestions.',
      'videoUrl': 'https://youtu.be/4mI0M29CSaI',
      'category': 'Dyscalculia'
    },
    {
      'title': 'Can a learning game help with dyscalculia?',
      'description': 'The power of gamification in learning math.',
      'videoUrl': 'https://youtu.be/ettD9oasIB0',
      'category': 'Dyscalculia'
    },
    {
      'title': 'Understanding Dyslexia',
      'description': 'A guide for parents.',
      'videoUrl': 'https://youtu.be/RaDDggsetoI',
      'category': 'Concept'
    },
    {
      'title': 'Helping Kids with Dyslexia',
      'description': 'Tips from a therapist.',
      'videoUrl': 'https://youtu.be/4Y2Cl4luv14',
      'category': 'Strategies'
    },
    {
      'title': 'Facts and Myths about Dyscalculia',
      'description': 'Separating truth from misconceptions.',
      'videoUrl': 'https://youtu.be/02MB3zI5iNI',
      'category': 'Awareness'
    },
    {
      'title': 'Understanding Dyscalculia',
      'description': 'Symptoms explained in detail.',
      'videoUrl': 'https://youtu.be/GRJS-jeZ7Is',
      'category': 'Concept'
    },
    {
      'title': 'Living with Dyscalculia',
      'description': 'It’s not just number dyslexia!',
      'videoUrl': 'https://youtu.be/_djdPIZrFno',
      'category': 'Awareness'
    },
    {
      'title': '20 Signs of Dyscalculia',
      'description': 'Could you have dyscalculia?',
      'videoUrl': 'https://youtu.be/uw9HHOM44tA',
      'category': 'Awareness'
    },
    {
      'title': 'How To Help Kids with Dyscalculia',
      'description': 'Support from Child Mind Institute.',
      'videoUrl': 'https://youtu.be/c3iCLLh_Cs4',
      'category': 'Support'
    },
  ];
  
  List<String> getCategories(List<Map<String, String>> videos, String lang) {
    if (lang == 'ar') {
      final cats = videos.map((v) => v['category']!).toSet().toList()..sort();
      return ['الكل', ...cats];
    } else {
      const manualOrder = ['Concept', 'Strategies', 'Support', 'Awareness', 'Dyscalculia'];
      final foundCats = videos.map((v) => v['category']!).toSet();
      final ordered = manualOrder.where((c) => foundCats.contains(c)).toList();
      final others = foundCats.where((c) => !manualOrder.contains(c)).toList()..sort();
      return ['All', ...ordered, ...others];
    }
  }

  List<Map<String, String>> filterVideos(List<Map<String, String>> videos, String category) {
    if (category == 'الكل' || category == 'All') return videos;
    return videos.where((v) => v['category']?.toLowerCase() == category.toLowerCase()).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFBCEB1),
        title: Text(LocaleKeys.awarenessTitle.tr()),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: LocaleKeys.tabArabic.tr()),
            Tab(text: LocaleKeys.tabEnglish.tr()),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSection(
            arabicVideos,
            getCategories(arabicVideos, 'ar'),
            selectedArabicCategory,
            arabicKeyword,
            true,
            (cat) => setState(() => selectedArabicCategory = cat),
            (kw) => setState(() => arabicKeyword = kw),
          ),
          _buildSection(
            englishVideos,
            getCategories(englishVideos, 'en'),
            selectedEnglishCategory,
            englishKeyword,
            false,
            (cat) => setState(() => selectedEnglishCategory = cat),
            (kw) => setState(() => englishKeyword = kw),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    List<Map<String, String>> videos,
    List<String> categories,
    String selectedCat,
    String keyword,
    bool isArabic,
    void Function(String) onCategoryChange,
    void Function(String) onKeywordChange,
  ) {
    final filtered = filterVideos(videos, selectedCat).where((v) =>
      v['title']!.toLowerCase().contains(keyword.toLowerCase()) ||
      v['description']!.toLowerCase().contains(keyword.toLowerCase())).toList();

    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: categories.map<Widget>((category) {
              final isSelected = selectedCat == category;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (_) => onCategoryChange(category),
                  selectedColor: Colors.deepOrange,
                  backgroundColor: Colors.grey.shade200,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextField(
            onChanged: (value) => onKeywordChange(value),
            decoration: InputDecoration(
              hintText: LocaleKeys.searchHint.tr(),
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        Expanded(child: _buildVideoGrid(filtered)),
      ],
    );
  }

  Widget _buildVideoGrid(List<Map<String, String>> videos) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: videos.length,
      itemBuilder: (context, index) {
        final video = videos[index];
        final videoId = YoutubePlayer.convertUrlToId(video['videoUrl']!) ?? '';
        final thumbnail = video['videoUrl'] == 'playlist'
            ? 'https://img.youtube.com/vi/ZPrDUUFeTIw/0.jpg'
            : video['videoUrl'] == 'playlist_math'
                ? 'https://img.youtube.com/vi/Qrf3JbbAleY/0.jpg'
                : 'https://img.youtube.com/vi/$videoId/0.jpg';

        return GestureDetector(
          onTap: () {
            if (video['videoUrl'] == 'playlist') {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ParentPlaylistScreen(playlistType: 'reading')));
            } else if (video['videoUrl'] == 'playlist_math') {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ParentPlaylistScreen(playlistType: 'math')));
            } else {
              Navigator.push(context, MaterialPageRoute(
                builder: (_) => YoutubePlayerScreen(videoUrl: video['videoUrl']!),
              ));
            }
          },
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Text(
                    video['category'] ?? '',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.deepOrange,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(thumbnail),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(video['title']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(
                        video['description']!,
                        style: const TextStyle(fontSize: 12),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}