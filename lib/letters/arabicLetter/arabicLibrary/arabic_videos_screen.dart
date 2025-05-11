import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_application_3/pages/YoutubePlayerScreen.dart';
//import 'youtube_player_screen.dart'; // Make sure this screen exists in your project.
import '';

class ArabicVideosTabbedScreen extends StatelessWidget {
  const ArabicVideosTabbedScreen({super.key});

  final Map<String, List<Map<String, String>>> categorizedVideos = const {
    "الحروف": [
      {
        "title": "تعلم الحروف العربية",
        "description": "نطق وكتابة الحروف بطريقة ممتعة",
        "url": "https://youtu.be/aNNUdNhpSB8?si=gvVDNBslf1yhPrNY",
        "thumbnail": "https://img.youtube.com/vi/aNNUdNhpSB8/0.jpg",
      },
      {
        "title": "أغنية الحروف",
        "description": "أغنية تعليمية للحروف الأبجدية",
        "url": "https://youtu.be/5j_UCxIEgj4?si=u3vBusK7cdJ_MBn8",
        "thumbnail": "https://img.youtube.com/vi/5j_UCxIEgj4/0.jpg",
      },
    ],
    "الكلمات": [
      {
        "title": "الكلمات الثلاثية",
        "description": "قراءة كلمات من ثلاث حروف",
        "url": "https://youtu.be/mAUkVsY3vCk?si=aoY0ebGihhG2Y9qH",
        "thumbnail": "https://img.youtube.com/vi/mAUkVsY3vCk/0.jpg",
      },
      {
        "title": "تمارين الحروف داخل كلمات",
        "description": "أين توجد الحرف في الكلمة؟",
        "url": "https://youtu.be/slOmgaazMS4?si=RWjuho9WU6SoNG4h",
        "thumbnail": "https://img.youtube.com/vi/slOmgaazMS4/0.jpg",
      },
    ],
    "القراءة": [
      {
        "title": "قصص لتعلم القراءة",
        "description": "قصص مبسطة لتنمية مهارة القراءة.",
        "url": "https://youtu.be/rNNpgo2Ew1I?si=QUaVshyW36DS8exs",
        "thumbnail": "https://img.youtube.com/vi/rNNpgo2Ew1I/0.jpg",
      },
      {
        "title": "تعلم التشكيل",
        "description": "الفتحة والضمة والكسرة والسكون.",
        "url": "https://youtu.be/6wPtJw_u2-0?si=mXCPQr6VDrRFku8T",
        "thumbnail": "https://img.youtube.com/vi/6wPtJw_u2-0/0.jpg",
      },
    ],
    "الحركات": [
      {
        "title": "تعلم الحركات القصيرة",
        "description": "شرح الفتحة والضمة والكسرة والسكون بطريقة مبسطة",
        "url": "https://youtu.be/gEo2X3B_syI?si=COT_PjpYeJkCulrU",
        "thumbnail": "https://img.youtube.com/vi/gEo2X3B_syI/0.jpg",
      },
      {
        "title": "كلمات مشكولة للتدريب",
        "description": "أمثلة على كلمات تحتوي حركات لتسهيل القراءة",
        "url": "https://youtu.be/CENfrXmPUqw?si=2ukbJ1ioDg61LaiH",
        "thumbnail": "https://img.youtube.com/vi/CENfrXmPUqw/0.jpg",
      },
    ],
  };

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: categorizedVideos.length,
      child: Scaffold(
        backgroundColor: const Color(0xFFFFF6ED),
        appBar: AppBar(
          backgroundColor: const Color(0xFFFFA726),
          title: Text('فيديوهات تعليمية - العربية'.tr()),
          bottom: TabBar(
            isScrollable: true,
            labelStyle:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            indicatorColor: Colors.white,
            tabs: categorizedVideos.keys
                .map((category) => Tab(text: category))
                .toList(),
          ),
        ),
        body: TabBarView(
          children: categorizedVideos.keys.map((category) {
            final videos = categorizedVideos[category]!;
            return Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                itemCount: videos.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.8,
                ),
                itemBuilder: (context, index) {
                  final video = videos[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => YoutubePlayerScreen(
                            videoUrl: video['url']!,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                            color: const Color(0xFFFFA726), width: 2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              video['thumbnail']!,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            video['title']!.tr(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            video['description']!.tr(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[700],
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
