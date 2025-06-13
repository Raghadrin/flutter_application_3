// ignore_for_file: unused_local_variable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChildDifficultyAnalysisScreen extends StatefulWidget {
  const ChildDifficultyAnalysisScreen({Key? key}) : super(key: key);

  @override
  State<ChildDifficultyAnalysisScreen> createState() =>
      _ChildDifficultyAnalysisScreenState();
}

class _ChildDifficultyAnalysisScreenState
    extends State<ChildDifficultyAnalysisScreen> {
  List<Map<String, dynamic>> quizAttempts = [];
  Map<String, dynamic>? childData;
  bool _isLoading = true;
  Map<String, String> _difficultyAnalysis = {};

  /// Parent notes per subject-level, keyed by 'subject_level' string
  Map<String, TextEditingController> _notesControllers = {};
  final Map<String, Map<String, String>> levelGoals = {
    'Arabic': {
      '1':
          'يهدف هذا المستوى إلى تعريف الطفل بالحروف الأبجدية وأصواتها الأساسية.',
      '2': 'يبدأ الطفل في دمج الحروف وتكوين مقاطع صوتية بسيطة.',
      '3': 'الطفل يقرأ كلمات وجمل قصيرة مع تعزيز الفهم القرائي.',
    },
    'English': {
      '1': 'This level focuses on recognizing letters and beginning phonics.',
      '2': 'Students blend sounds to form simple syllables and words.',
      '3': 'The child reads short sentences and begins understanding context.',
    },
    'Math': {
      '1':
          'This level identifies basic number recognition and simple counting.',
      '2': 'Focus on basic operations like addition and subtraction.',
      '3':
          'The child starts solving multi-step problems and understanding concepts.',
    },
  };
  @override
  void initState() {
    super.initState();
    _loadChildAttemptsAndAnalyze();
  }

  @override
  void dispose() {
    // Dispose all TextEditingControllers for notes
    for (var controller in _notesControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadChildAttemptsAndAnalyze() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final parentId = user.uid;

      // Get selected child ID from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final selectedChildId = prefs.getString('selected_child_id');

      if (selectedChildId == null) {
        print('No selected child ID found.');
        setState(() => _isLoading = false);
        return;
      }

      // Fetch child document by the selectedChildId
      final childDoc = await FirebaseFirestore.instance
          .collection('parents')
          .doc(parentId)
          .collection('children')
          .doc(selectedChildId)
          .get();

      if (!childDoc.exists) {
        print('Selected child document does not exist.');
        setState(() => _isLoading = false);
        return;
      }
      final childId = selectedChildId;
      final childDataLocal = childDoc.data();

      final Map<String, List<String>> subjectLevels = {
        'arabic': ['arabic1', 'arabic2', 'arabic3'],
        'math': ['math1', 'math2'],
        'english': ['english1', 'english2'],
      };

      Map<String, int> totalAttempts = {
        'arabic': 0,
        'math': 0,
        'english': 0,
      };

      Map<String, int> lowScoreAttempts = {
        'arabic': 0,
        'math': 0,
        'english': 0,
      };

      List<Map<String, dynamic>> allAttempts = [];

      // For loading existing notes from Firestore
      Map<String, String> existingNotes = {};

      // make sure this is assigned before use

// Now use childId safely in your loops
      for (var subject in subjectLevels.keys) {
        for (var level in subjectLevels[subject]!) {
          final attemptsSnapshot = await FirebaseFirestore.instance
              .collection('parents')
              .doc(parentId)
              .collection('children')
              .doc(childId)
              .collection(subject)
              .doc(level)
              .collection('attempts')
              .get();

          for (var doc in attemptsSnapshot.docs) {
            final data = doc.data();
            final score = data['score'];
            if (score != null && score is num) {
              totalAttempts[subject] = totalAttempts[subject]! + 1;
              if (score < 50) {
                lowScoreAttempts[subject] = lowScoreAttempts[subject]! + 1;
              }
            }
            data['subject'] = subject;
            data['level'] = level;
            allAttempts.add(data);
          }

          // Load parent notes per subject-level
        }
      }

      Map<String, String> analysis = {};
      totalAttempts.forEach((subject, total) {
        final low = lowScoreAttempts[subject] ?? 0;
        final percentage = total > 0 ? (low / total) * 100 : 0;

        if (percentage == 0) {
          analysis[subject] = tr('no_issue');
        } else if (percentage < 30) {
          analysis[subject] = tr('mild_difficulty');
        } else {
          analysis[subject] = tr('severe_difficulty');
        }
      });

      // Initialize TextEditingControllers for notes
      for (var key in existingNotes.keys) {
        _notesControllers[key] =
            TextEditingController(text: existingNotes[key]);
      }

      setState(() {
        _difficultyAnalysis = analysis;
        quizAttempts = allAttempts;
        childData = childDataLocal;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching attempts: $e');
      setState(() => _isLoading = false);
    }
  }

  String getRecommendations(double score) {
    if (score >= 85) {
      return tr('keep_up_the_good_work');
    } else if (score >= 70) {
      return tr('consistent_review_and_support_recommended');
    } else if (score >= 50) {
      return tr('additional_practice_and_guidance_needed');
    } else {
      return tr('intensive_support_and_repetition_needed');
    }
  }

  Future<void> _saveNote(String subject, String level) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final parentId = user.uid;

    // Fetch children snapshot asynchronously
    final childrenSnapshot = await FirebaseFirestore.instance
        .collection('parents')
        .doc(parentId)
        .collection('children')
        .get();

    if (childrenSnapshot.docs.isEmpty) {
      // No children found, handle accordingly
      print('No child found for this parent.');
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final selectedChildId = prefs.getString('lastSelectedChildId');

    if (selectedChildId == null) {
      print('No selected child ID found in SharedPreferences.');
      return;
    }

    final key = '$subject-$level';
  }

  // Severity helpers
  String getSeverity(double avgScore) {
    if (avgScore >= 80) return tr('no_issue');
    if (avgScore >= 50) return tr('mild_difficulty');
    return tr('severe_difficulty');
  }

  Color getSeverityColor(double avgScore) {
    if (avgScore >= 80) return Colors.green.shade600;
    if (avgScore >= 50) return Colors.orange.shade700;
    return Colors.red.shade700;
  }

  IconData getSeverityIcon(double avgScore) {
    if (avgScore >= 80) return Icons.sentiment_very_satisfied;
    if (avgScore >= 50) return Icons.sentiment_neutral;
    return Icons.sentiment_very_dissatisfied;
  }

  String getSuggestion(String severity) {
    // Add smart recommendation samples
    switch (severity.toLowerCase()) {
      case 'no issue':
        return tr('keep_up_the_good_work');
      case 'mild difficulty':
        return tr('practice_more_on_this_level') +
            '\nTry these activities: Activity 1, Activity 2';
      case 'severe difficulty':
        return tr('consider_extra_tutoring') +
            '\nRecommended exercises: Exercise A, Exercise B';
      default:
        return '';
    }
  }

  /// Calculate overall average score for summary cards
  double _calculateAverageScore(String subject) {
    final scores = quizAttempts
        .where((attempt) => attempt['subject'] == subject)
        .map<double>((a) => (a['score'] as num).toDouble())
        .toList();
    if (scores.isEmpty) return 0;
    return scores.reduce((a, b) => a + b) / scores.length;
  }

  /// Pie chart data for subject showing correct vs incorrect attempts
  List<PieChartSectionData> _buildPieChartData(String subject) {
    final subjectAttempts = quizAttempts.where((a) => a['subject'] == subject);
    int correct = 0;
    int incorrect = 0;

    for (var attempt in subjectAttempts) {
      double score = (attempt['score'] as num).toDouble();
      if (score >= 50) {
        correct++;
      } else {
        incorrect++;
      }
    }

    final total = correct + incorrect;
    if (total == 0) {
      // To avoid division by zero, show empty chart
      return [
        PieChartSectionData(
            value: 1,
            color: Colors.grey[300]!,
            title: tr('no_data'),
            radius: 50),
      ];
    }

    return [
      PieChartSectionData(
        color: Colors.green.shade400,
        value: correct.toDouble(),
        title: '${(correct / total * 100).toStringAsFixed(1)}%',
        radius: 50,
        titleStyle: const TextStyle(
            fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      PieChartSectionData(
        color: Colors.red.shade400,
        value: incorrect.toDouble(),
        title: '${(incorrect / total * 100).toStringAsFixed(1)}%',
        radius: 50,
        titleStyle: const TextStyle(
            fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    ];
  }

  // To show history of scores in tooltip/dialog
  void _showScoreHistoryDialog(
      BuildContext context, String subject, List<double> scores) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('${tr('score_history')} - ${subject.toUpperCase()}'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: scores.length,
              itemBuilder: (_, i) {
                return ListTile(
                  title: Text('${tr('attempt')} ${i + 1}'),
                  trailing: Text('${scores[i].toStringAsFixed(1)}%'),
                );
              },
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(tr('close')))
          ],
        );
      },
    );
  }

  String getLevelDescription({
    required int level,
    required bool isReading,
    required BuildContext context,
  }) {
    if (isReading) {
      switch (level) {
        case 1:
          return ('level_1_reading'.tr());
        case 2:
          return ('level_2_reading'.tr());
        case 3:
          return ('level_3_reading'.tr());
        default:
          return '';
      }
    } else {
      // Math
      switch (level) {
        case 1:
          return ('level_1_math'.tr());
        case 2:
          return ('level_2_math'.tr());
        case 3:
          return ('level_3_math'.tr());
        default:
          return '';
      }
    }
  }

  @override
  @override
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : Colors.grey[100]!;

    Map<String, Map<String, List<double>>> scoresBySubjectAndLevel = {};
    for (var attempt in quizAttempts) {
      String subject = attempt['subject'] ?? 'unknown';
      String level = attempt['level'] ?? 'unknown';
      double score = (attempt['score'] as num?)?.toDouble() ?? 0;

      scoresBySubjectAndLevel.putIfAbsent(subject, () => {});
      scoresBySubjectAndLevel[subject]!.putIfAbsent(level, () => []);
      scoresBySubjectAndLevel[subject]![level]!.add(score);
    }

    List<String> subjects = ['arabic', 'math', 'english'];

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(tr('difficulty_analysis')),
        centerTitle: true,
        backgroundColor:
            isDark ? Colors.deepPurple[700] : Colors.deepPurpleAccent,
        foregroundColor: Colors.white,
        elevation: 6,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(tr('summary'),
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                SizedBox(
                  height: 200,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: subjects.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 16),
                    itemBuilder: (ctx, index) {
                      final subject = subjects[index];
                      double avgScore = _calculateAverageScore(subject);
                      return _buildSummaryCard(context, subject, avgScore,
                          isDark, scoresBySubjectAndLevel);
                    },
                  ),
                ),
                const SizedBox(height: 24),
                ...subjects
                    .map((subject) => _buildSubjectAnalysisCard(
                        context, subject, scoresBySubjectAndLevel, isDark))
                    .toList(),
                // const SizedBox(height: 24),
                // _buildParentNotesSection(context, isDark),
              ],
            ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String subject,
    double avgScore,
    bool isDark,
    Map<String, Map<String, List<double>>> scoresMap,
  ) {
    final severity = getSeverity(avgScore);
    final color = getSeverityColor(avgScore);
    final icon = getSeverityIcon(avgScore);
    final scores = scoresMap[subject]?.values.expand((e) => e).toList() ?? [];

    return GestureDetector(
      onTap: () {
        if (scores.isNotEmpty) {
          _showScoreHistoryDialog(context, subject, scores);
        }
      },
      child: Container(
        width: 180,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark
              ? color.withOpacity(0.08) // subtle light fill in dark mode
              : color
                  .withOpacity(0.15), // gentle pastel-style light in light mode
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.3), // much softer border
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.transparent, // remove strong shadow
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              subject.toUpperCase(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Row(
              children: [
                Icon(icon, size: 28, color: color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    severity,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
            Text(
              tr('tap_for_score_history'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: color.withOpacity(0.75),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectAnalysisCard(
    BuildContext context,
    String subject,
    Map<String, Map<String, List<double>>> scoresMap,
    bool isDark,
  ) {
    final ScrollController scrollController = ScrollController();
    final levels = scoresMap[subject]?.keys.toList() ?? [];
    const double cardWidth = 280;
    const double separatorWidth = 18;

    void scrollLeft() {
      final newPosition =
          (scrollController.offset - (cardWidth + separatorWidth))
              .clamp(0, scrollController.position.maxScrollExtent);
      scrollController.animateTo(
        newPosition.roundToDouble(),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }

    void scrollRight() {
      final newPosition =
          (scrollController.offset + (cardWidth + separatorWidth))
              .clamp(0, scrollController.position.maxScrollExtent);
      scrollController.animateTo(
        newPosition.toDouble(),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }

    if (levels.isEmpty) {
      return Text(
        tr('no_data_available'),
        style: TextStyle(
          fontStyle: FontStyle.italic,
          color: isDark ? Colors.grey[400] : Colors.grey[600],
          fontSize: 16,
        ),
      );
    }

    return SizedBox(
      height: 940, // add some extra height for subject title
      child: Stack(
        children: [
          Positioned(
            left: 22,
            top: 10,
            child: Text(
              subject.toUpperCase(),
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
          ListView.separated(
            controller: scrollController,
            scrollDirection: Axis.horizontal,
            itemCount: levels.length,
            padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 22),
            separatorBuilder: (_, __) => const SizedBox(width: separatorWidth),
            itemBuilder: (context, index) {
              final level = levels[index];
              final scoresList =
                  (scoresMap[subject]?[level] ?? []).cast<double>();
              final avgLevelScore = scoresList.isEmpty
                  ? 0
                  : scoresList.reduce((a, b) => a + b) / scoresList.length;

              final cleanLevelKey =
                  'level${level.replaceAll(RegExp(r'[a-z]'), '')}';
              final levelGoalText = levelGoals[subject]?[cleanLevelKey] ?? '';

              return Container(
                width: cardWidth,
                padding:
                    const EdgeInsets.symmetric(vertical: 40, horizontal: 22),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[900] : Colors.grey[100],
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.black54
                          : Colors.grey.withOpacity(0.2),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${tr('level')} ${level.replaceAll(RegExp(r'[a-z]'), '')}',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Pie chart and legend
                    Center(
                      child: Column(
                        children: [
                          SizedBox(
                            height: 160,
                            width: 110,
                            child: PieChart(
                              PieChartData(
                                sections: _buildPieChartData(subject),
                                centerSpaceRadius: 35,
                                sectionsSpace: 6,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              _buildLegendItem(Colors.green, tr('excellent')),
                              const SizedBox(height: 8),
                              _buildLegendItem(
                                  Colors.red, tr('needs_improvement')),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Severity
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            getSeverityIcon(avgLevelScore.toDouble()),
                            color: getSeverityColor(avgLevelScore.toDouble()),
                            size: 32,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            getSeverity(avgLevelScore.toDouble()),
                            style: TextStyle(
                              color: getSeverityColor(avgLevelScore.toDouble()),
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Recommendations heading
                    Text(
                      tr('suggestions_and_recommendations'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),

                    if (levelGoalText.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          levelGoalText,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.white70 : Colors.black87,
                            fontStyle: FontStyle.italic,
                            height: 1.4,
                          ),
                        ),
                      ),

                    // Recommendations scrollable
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              getRecommendations(avgLevelScore.toDouble()),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                height: 1.5,
                                color: isDark ? Colors.white60 : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 18),
                            Container(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 8),
                              padding: const EdgeInsets.all(16),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.grey[850]
                                    : Colors.grey[200],
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  if (!isDark)
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 6,
                                      offset: Offset(0, 3),
                                    ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.help_outline,
                                        color: isDark
                                            ? Colors.white
                                            : Colors.black87,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 6),
                                      Flexible(
                                        child: Text(
                                          tr('how_this_level_helps'),
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15,
                                            color: isDark
                                                ? Colors.white
                                                : Colors.black87,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    getLearningSupportExplanation(subject),
                                    softWrap: true,
                                    style: TextStyle(
                                      fontSize: 13,
                                      height: 1.5,
                                      color: isDark
                                          ? Colors.white70
                                          : Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              );
            },
          ),

          // Left arrow
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Center(
              child: Material(
                color: Colors.transparent,
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_new,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                  onPressed: scrollLeft,
                  tooltip: 'Scroll Left',
                ),
              ),
            ),
          ),

          // Right arrow
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: Center(
              child: Material(
                color: Colors.transparent,
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_forward_ios,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                  onPressed: scrollRight,
                  tooltip: 'Scroll Right',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String getLearningSupportExplanation(String subject) {
    switch (subject.toLowerCase()) {
      case 'arabic':
        return "Helps children with dyslexia by reinforcing letter recognition, phoneme awareness, and reading fluency in Arabic, using structured repetition and multisensory activities.";
      case 'english':
        return "Supports children with dyslexia by improving decoding skills, phonics, and spelling patterns in English through gradual complexity and clear visual cues.";
      case 'math':
        return "Assists children with dyscalculia by building number sense, pattern recognition, and problem-solving strategies using visual aids and step-by-step guidance.";
      default:
        return "This level is designed to support foundational cognitive and learning skills tailored to each subject.";
    }
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          margin: const EdgeInsets.only(right: 6),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
        Text(
          textAlign: TextAlign.center,
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}
