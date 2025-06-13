import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class FinalFeedbackScreenAr extends StatefulWidget {
  final double averageScore;
  final int totalStars;
  final String level;

  const FinalFeedbackScreenAr({
    Key? key,
    required this.averageScore,
    required this.totalStars,
    required this.level,
  }) : super(key: key);

  @override
  _FinalFeedbackScreenArState createState() => _FinalFeedbackScreenArState();
}

class _FinalFeedbackScreenArState extends State<FinalFeedbackScreenAr> {
  List<double> last5Scores = [];
  String parentId = '';
  String childId = '';

  @override
  void initState() {
    super.initState();
    fetchPreviousAttempts();
  }

  Future<void> fetchPreviousAttempts() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    parentId = user.uid;

    final childrenSnapshot = await FirebaseFirestore.instance
        .collection('parents')
        .doc(parentId)
        .collection('children')
        .get();

    if (childrenSnapshot.docs.isEmpty) return;

    childId = childrenSnapshot.docs.first.id;

    final attemptsSnapshot = await FirebaseFirestore.instance
        .collection('parents')
        .doc(parentId)
        .collection('children')
        .doc(childId)
        .collection('karaoke')
        .doc('arKaraoke')
        .collection(widget.level)
        .orderBy('timestamp', descending: true)
        .limit(5)
        .get();

    setState(() {
      last5Scores = attemptsSnapshot.docs.reversed
          .map((doc) => (doc['score'] as num).toDouble())
          .toList();
    });
  }

  String getFeedback() {
    if (widget.averageScore >= 90) return "عمل رائع جداً!";
    if (widget.averageScore >= 75) return "أداء ممتاز! استمر.";
    if (widget.averageScore >= 60) return "جهد جيد. يمكنك التحسن.";
    return "استمر في المحاولة، ستحقق تقدماً!";
  }

  Widget buildChart() {
    if (last5Scores.isEmpty) {
      return const Text(
        "لا يوجد بيانات كافية للرسم البياني.",
        style: TextStyle(fontSize: 12),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          "📊 المحاولات الأخيرة:",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.deepPurple,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.deepPurple.shade50,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.15),
                spreadRadius: 1,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(12),
          child: AspectRatio(
            aspectRatio: 1.8,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 100,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: Colors.deepPurpleAccent.withOpacity(0.8),
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${rod.toY.toStringAsFixed(1)}%',
                        const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 20,
                      reservedSize: 32,
                      getTitlesWidget: (value, meta) => Text(
                        '${value.toInt()}%',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) => Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'محاولة ${value.toInt() + 1}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ),
                  rightTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.grey[300],
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(last5Scores.length, (index) {
                  final value = last5Scores[index];
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: value,
                        width: 20,
                        borderRadius: BorderRadius.circular(8),
                        gradient: const LinearGradient(
                          colors: [Colors.deepPurple, Colors.deepPurpleAccent],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(getFeedback(), style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🎉 الملاحظات النهائية')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  'متوسط نتيجتك: ${widget.averageScore.toStringAsFixed(1)}%',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    3,
                    (i) => Icon(
                      i < widget.totalStars ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                buildChart(),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('العودة إلى الصفحة الرئيسية'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
