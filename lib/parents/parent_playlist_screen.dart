
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:easy_localization/easy_localization.dart';
import 'locale_keys.dart';

class ParentPlaylistScreen extends StatelessWidget {
  final String playlistType; // 'reading' or 'math'
  const ParentPlaylistScreen({super.key, this.playlistType = 'reading'});

  List<Map<String, String>> get playlistVideos {
    if (playlistType == 'math') {
      return [
        {'title': 'فيديو 1: تنمية المهارات الحسابية', 'url': 'https://www.youtube.com/watch?v=Qrf3JbbAleY'},
        {'title': 'فيديو 2: تعليم الأعداد بطريقة ممتعة', 'url': 'https://www.youtube.com/watch?v=fpEdBjkm27c'},
        {'title': 'فيديو 3: استخدام الأصابع في العد', 'url': 'https://www.youtube.com/watch?v=61_x7H-6kos'},
        {'title': 'فيديو 4: أنشطة لتنمية الذكاء العددي', 'url': 'https://www.youtube.com/watch?v=Mq8bMs0Dlrg'},
        {'title': 'فيديو 5: مفاهيم الجمع والطرح للأطفال', 'url': 'https://www.youtube.com/watch?v=vuCzFvyPN0M'},
        {'title': 'فيديو 6: العد التصاعدي والتنازلي', 'url': 'https://www.youtube.com/watch?v=fY1ooE8dH5E'},
        {'title': 'فيديو 7: ترتيب الأرقام بشكل تفاعلي', 'url': 'https://www.youtube.com/watch?v=mn_HQHB1A9o'},
        {'title': 'فيديو 8: ألعاب رقمية تعليمية', 'url': 'https://www.youtube.com/watch?v=Yk1YUoBb618'},
        {'title': 'فيديو 9: مقارنة الأعداد بشكل بصري', 'url': 'https://www.youtube.com/watch?v=rlPIBKPOieo'},
        {'title': 'فيديو 10: تمارين على العد بالعشرات', 'url': 'https://www.youtube.com/watch?v=NYn-E8Y7yzg'},
        {'title': 'فيديو 11: العمليات الأساسية في الرياضيات', 'url': 'https://www.youtube.com/watch?v=3LBsa4D0EXo'},
        {'title': 'فيديو 12: إدراك العلاقة بين الأرقام', 'url': 'https://www.youtube.com/watch?v=HZZSPZ7Ras4'},
        {'title': 'فيديو 13: الحساب في الحياة اليومية', 'url': 'https://www.youtube.com/watch?v=gbTggiDhfSc'},
        {'title': 'فيديو 14: تعليم الطرح للأطفال', 'url': 'https://www.youtube.com/watch?v=kgrK8ZA5AYs'},
        {'title': 'فيديو 15: العد باستخدام الألعاب', 'url': 'https://www.youtube.com/watch?v=DwP5zIMmQQU'},
        {'title': 'فيديو 16: التعرف على الأنماط العددية', 'url': 'https://www.youtube.com/watch?v=nwvawbmzqTA'},
        {'title': 'فيديو 17: العد حتى 100', 'url': 'https://www.youtube.com/watch?v=Qao-VhrEM4w'},
        {'title': 'فيديو 18: قراءة وكتابة الأعداد', 'url': 'https://www.youtube.com/watch?v=QV0aSqkji_Q'},
        {'title': 'فيديو 19: استخدام الصور في تعلم الأرقام', 'url': 'https://www.youtube.com/watch?v=XHSm4sdBolM'},
        {'title': 'فيديو 20: العد على مراحل', 'url': 'https://www.youtube.com/watch?v=6k2PUWSiTS0'},
        {'title': 'فيديو 21: مقدمة في الضرب', 'url': 'https://www.youtube.com/watch?v=yxMM4J2CrWU'},
        {'title': 'فيديو 22: العد الزوجي والفردي', 'url': 'https://www.youtube.com/watch?v=A7sQtknbHzs'},
        {'title': 'فيديو 23: التعرف على القيم المكانية', 'url': 'https://www.youtube.com/watch?v=MzWhinyFKvU'},
        {'title': 'فيديو 24: أدوات العد للأطفال', 'url': 'https://www.youtube.com/watch?v=YgmlZVtSRrQ'},
        {'title': 'فيديو 25: تقوية الذاكرة العددية', 'url': 'https://www.youtube.com/watch?v=lsVW99ooAvY'},
        {'title': 'فيديو 26: طرح الأعداد باستخدام الصور', 'url': 'https://www.youtube.com/watch?v=kzKfyOVQJac'},
        {'title': 'فيديو 27: تعليم الكسور للأطفال', 'url': 'https://www.youtube.com/watch?v=JDu3THsVZco'},
        {'title': 'فيديو 28: مهارات حل المسائل', 'url': 'https://www.youtube.com/watch?v=FWFUgnfG0yM'},
        {'title': 'فيديو 29: التفكير المنطقي العددي', 'url': 'https://www.youtube.com/watch?v=Tbkyluq7JOE'},
        {'title': 'فيديو 30: أنشطة تفاعلية في الرياضيات', 'url': 'https://www.youtube.com/watch?v=1w5aANEcDmY'},
        {'title': 'فيديو 31: العد من خلال القصص', 'url': 'https://www.youtube.com/watch?v=G8QI4bv56Fs'},
        {'title': 'فيديو 32: تعليم الجداول الحسابية', 'url': 'https://www.youtube.com/watch?v=zQ_y4Rh9BK8'},
        {'title': 'فيديو 33: تحديد الأنماط في العد', 'url': 'https://www.youtube.com/watch?v=YxdW9FvwTms'},
        {'title': 'فيديو 34: تعلم العد من خلال الحركة', 'url': 'https://www.youtube.com/watch?v=PLb2yLo5UEo'},
        {'title': 'فيديو 35: استخدام الأشكال الهندسية في العد', 'url': 'https://www.youtube.com/watch?v=njfxN40tYKg'},
        {'title': 'فيديو 36: مراجعة المفاهيم الحسابية الأساسية', 'url': 'https://www.youtube.com/watch?v=iOtJZNxJo6M'},
      ];
    } else {
      return [
        {'title': 'الخطوة 1', 'url': 'https://youtu.be/ZPrDUUFeTIw'},
        {'title': 'الخطوة 2', 'url': 'https://youtu.be/abgj9p-hQXM'},
        {'title': 'الخطوة 3', 'url': 'https://youtu.be/l6AHbgzi5Sg'},
        {'title': 'الخطوة 4', 'url': 'https://youtu.be/gFtAQH2kGlY'},
        {'title': 'الخطوة 5', 'url': 'https://youtu.be/W_MKKMi8c2o'},
        {'title': 'الخطوة 6', 'url': 'https://youtu.be/of3Ygx9WKHI'},
        {'title': 'الخطوة 7', 'url': 'https://youtu.be/IhwtcvMUQcE'},
        {'title': 'نقاش وتطبيق عملي', 'url': 'https://youtu.be/ix9u50RR4tE'},
        {'title': 'خاتمة وتلخيص المحاضرة', 'url': 'https://youtu.be/N8CISRx0Unk'},
      ];
    }
  }

  String get playlistTitle {
    return playlistType == 'math'
        ? LocaleKeys.playlistMath
        : LocaleKeys.playlistReading;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(playlistTitle.tr()),
        backgroundColor: const Color(0xFFFBCEB1),
        foregroundColor: Colors.black87,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: playlistVideos.length,
        itemBuilder: (context, index) {
          final video = playlistVideos[index];
          final videoId = YoutubePlayer.convertUrlToId(video['url']!) ?? '';
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 4,
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  'https://img.youtube.com/vi/$videoId/0.jpg',
                  width: 100,
                  height: 60,
                  fit: BoxFit.cover,
                ),
              ),
              title: Text(
                video['title']!,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => YoutubePlayerScreen(videoUrl: video['url']!),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class YoutubePlayerScreen extends StatefulWidget {
  final String videoUrl;
  const YoutubePlayerScreen({super.key, required this.videoUrl});

  @override
  State<YoutubePlayerScreen> createState() => _YoutubePlayerScreenState();
}

class _YoutubePlayerScreenState extends State<YoutubePlayerScreen> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    final videoId = YoutubePlayer.convertUrlToId(widget.videoUrl)!;
    _controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(autoPlay: true, mute: false),
    );
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      player: YoutubePlayer(controller: _controller),
      builder: (context, player) => Scaffold(
        appBar: AppBar(
          title: Text(LocaleKeys.watchVideo.tr()),
          backgroundColor: Colors.orange,
        ),
        body: Center(child: player),
      ),
    );
  }
}
