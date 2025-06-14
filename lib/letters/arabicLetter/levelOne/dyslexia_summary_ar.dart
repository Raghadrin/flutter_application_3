import 'package:flutter/material.dart';

/// بيانات كرت الديسلكسيا بالعربي (العنوان، الإيموجي، الوصف، النقاط)
class _TypeCardAr {
  final String title, emoji, description;
  final List<String> symptoms;
  const _TypeCardAr({
    required this.title,
    required this.emoji,
    required this.description,
    required this.symptoms,
  });
}

/// الكروت (الأنواع + ماذا تفعل)
const List<_TypeCardAr> _cardsAr = [
  _TypeCardAr(
    title: 'عسر القراءة الصوتي',
    emoji: '🔤',
    description: 'صعوبة في تقسيم الكلمة لأصوات أو ربط الحرف بالصوت المناسب.',
    symptoms: [
      'ضعف في التهجئة',
      'بطء في نطق الكلمات الجديدة',
      'تجنب القراءة بصوت عالٍ',
      'صعوبة ربط الحروف بالأصوات',
      'تعثر في نطق كلمات غير مألوفة',
    ],
  ),
  _TypeCardAr(
    title: 'عسر التسمية السريع',
    emoji: '⏱️',
    description: 'بطء في تسمية الحروف أو الأرقام أو الألوان، ويؤثر على الطلاقة.',
    symptoms: [
      'تردد أو بطء في الإجابة',
      'يحذف أو يبدل كلمات أثناء القراءة',
      'بطء في القراءة بشكل عام',
      'يستخدم إشارات أو حركات بدل الكلام',
      'يأخذ وقت في الإجابة عن الأسئلة',
    ],
  ),
  _TypeCardAr(
    title: 'عسر القراءة المزدوج',
    emoji: '🔀',
    description: 'يجمع بين صعوبات الصوتيات وبطء التسمية.',
    symptoms: [
      'ضعف في الوعي الصوتي',
      'بطء في سرعة التسمية',
      'مشكلات في التهجئة والطلاقة',
    ],
  ),
  _TypeCardAr(
    title: 'عسر القراءة السطحي',
    emoji: '👁️',
    description: 'يجيد قراءة كلمات جديدة صوتيًا، لكن يصعب عليه الكلمات البصرية الشاذة.',
    symptoms: [
      'قراءة بطيئة عامة',
      'يلخبط بين كلمات مثل "كان" و"مكان"',
      'صعوبة في الكلمات غير المنتظمة',
      'يعكس الحروف مثل ب/د/ق',
      'مخزون كلمات بصري صغير',
    ],
  ),
  _TypeCardAr(
    title: 'عسر القراءة البصري',
    emoji: '👓',
    description: 'النص يبدو ضبابيًا أو يتحرك أو يتزحزح من مكانه.',
    symptoms: [
      'يفقد تتبع السطور',
      'يشعر أن الكلمات تهتز',
      'الحروف "تقفز" من مكانها',
      'إجهاد أو ألم في العينين أو صداع',
    ],
  ),
  _TypeCardAr(
    title: 'عسر القراءة التطوري',
    emoji: '👶',
    description: 'ينتشر في العائلات ويظهر في سن مبكرة.',
    symptoms: [
      'سبب وراثي غالبًا',
      'يظهر منذ الصفوف الأولى',
    ],
  ),
  _TypeCardAr(
    title: 'عسر القراءة المكتسب',
    emoji: '⚠️',
    description: 'يحدث بعد إصابة دماغية أو مرض مفاجئ.',
    symptoms: [
      'كان يقرأ طبيعيًا ثم ظهر الاضطراب',
      'اضطراب في اللغة بعد الإصابة أو المرض',
    ],
  ),
  _TypeCardAr(
    title: 'ماذا تفعل؟',
    emoji: '💡',
    description: 'خطوات لمساعدة طفلك وتحسين القراءة:',
    symptoms: [
      'استشارة مختص تربوي أو أخصائي',
      'استخدام برامج متعددة الحواس',
      'ممارسة التهجئة يومياً ولو قليلاً',
      'الاستفادة من الكتب الصوتية أو القارئ الآلي',
      'شجع طفلك واحتفل بالإنجازات 🎉',
    ],
  ),
];

class DyslexiaSummaryArScreen extends StatefulWidget {
  final List<String> mistakeCategories;

  const DyslexiaSummaryArScreen({Key? key, required this.mistakeCategories})
      : super(key: key);

  @override
  _DyslexiaSummaryArScreenState createState() =>
      _DyslexiaSummaryArScreenState();
}

class _DyslexiaSummaryArScreenState extends State<DyslexiaSummaryArScreen> {
  final PageController _controller = PageController(viewportFraction: 0.85);
  int _currentPage = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_cardsAr.length, (i) {
        final isActive = i == _currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 12 : 8,
          height: isActive ? 12 : 8,
          decoration: BoxDecoration(
            color: isActive ? Colors.orange.shade700 : Colors.orange.shade200,
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🧠 ملخص صعوبات القراءة'),
        backgroundColor: Colors.orange.shade700,
      ),
      body: Column(
        children: [
          if (widget.mistakeCategories.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'واجهت صعوبات في:\n${widget.mistakeCategories.join('، ')}',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[800]),
              ),
            ),

          Expanded(
            child: PageView.builder(
              controller: _controller,
              onPageChanged: (i) => setState(() => _currentPage = i),
              itemCount: _cardsAr.length,
              itemBuilder: (context, i) {
                final c = _cardsAr[i];
                final isActive = i == _currentPage;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  margin: EdgeInsets.symmetric(
                      vertical: isActive ? 16 : 32, horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.shade300
                            .withOpacity(isActive ? 0.6 : 0.3),
                        blurRadius: isActive ? 24 : 12,
                        spreadRadius: isActive ? 4 : 1,
                      ),
                    ],
                  ),
                  child: Transform.scale(
                    scale: isActive ? 1.0 : 0.9,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Hero(
                              tag: 'card_${c.title}',
                              child: Material(
                                color: Colors.transparent,
                                child: Text(
                                  '${c.emoji}  ${c.title}',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(c.description,
                              style: const TextStyle(fontSize: 16)),
                          const SizedBox(height: 16),

                          // كل عرض عرض الأعراض في صناديق صغيرة
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: c.symptoms.map((s) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(s,
                                    style: const TextStyle(fontSize: 14)),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(12),
            child: _buildIndicator(),
          ),

          if (_currentPage == _cardsAr.length - 1)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade400,
                  minimumSize: const Size.fromHeight(48),
                ),
                onPressed: () =>
                    Navigator.popUntil(context, (r) => r.isFirst),
                child: const Text('تم', style: TextStyle(fontSize: 18)),
              ),
            ),
        ],
      ),
    );
  }
}
