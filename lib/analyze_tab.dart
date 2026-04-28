import 'package:flutter/material.dart';
import 'data_manager.dart';
import 'local_data_service.dart';
import 'dart:math' as math;

class AnalyzeTab extends StatefulWidget {
  const AnalyzeTab({super.key});

  @override
  State<AnalyzeTab> createState() => _AnalyzeTabState();
}

class _AnalyzeTabState extends State<AnalyzeTab> {
  int _selectedPeriod = 0;
  final List<String> _periods = ['Week', 'Month', 'Year'];
  Map<String, double> _trainingBests = {};

  @override
  void initState() {
    super.initState();
    _loadTrainingData();
    // Listen to changes in DataManager to refresh UI
    DataManager.sessionsChangedCounter.addListener(_refresh);
  }

  Future<void> _loadTrainingData() async {
    final bests = await LocalDataService.getPersonalBests();
    if (mounted) {
      setState(() {
        _trainingBests = bests;
      });
    }
  }

  @override
  void dispose() {
    DataManager.sessionsChangedCounter.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) {
      setState(() {});
      _loadTrainingData();
    }
  }

  Future<void> _resetBests() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset High Scores?'),
        content: const Text('This will clear all your training personal bests.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await LocalDataService.resetPersonalBests();
      await _loadTrainingData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = Theme.of(context).scaffoldBackgroundColor;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1A3A3A);
    final subTextColor = isDark ? Colors.white70 : const Color(0xFF5A7A7A);

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(textColor, subTextColor),
              const SizedBox(height: 20),
              _buildPeriodSelector(cardColor, subTextColor),
              const SizedBox(height: 20),
              _buildChartCard(cardColor, textColor, subTextColor),
              const SizedBox(height: 16),
              _buildInsightsGrid(cardColor, textColor, subTextColor),
              const SizedBox(height: 16),
              _buildTrainingStats(cardColor, textColor, subTextColor),
              const SizedBox(height: 16),
              _buildSessionHistory(cardColor, textColor, subTextColor), 
              const SizedBox(height: 16),
              _buildProgressSummary(cardColor, textColor, subTextColor),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Color textColor, Color subTextColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Analyze',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Understand your focus patterns',
          style: TextStyle(fontSize: 13, color: subTextColor),
        ),
      ],
    );
  }

  Widget _buildPeriodSelector(Color cardColor, Color subTextColor) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: List.generate(_periods.length, (index) {
          final isSelected = _selectedPeriod == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedPeriod = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF2A7C7C)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _periods[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : subTextColor,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildChartCard(Color cardColor, Color textColor, Color subTextColor) {
    List<Map<String, dynamic>> chartData = [];
    String subTitle = "";

    if (_selectedPeriod == 0) {
      // Week
      chartData = [
        {'label': 'M', 'value': 15},
        {'label': 'T', 'value': 30},
        {'label': 'W', 'value': 20},
        {'label': 'T', 'value': 45},
        {'label': 'F', 'value': 10},
        {'label': 'S', 'value': 35},
        {'label': 'S', 'value': (DataManager.getTotalSecondsToday() / 60).round()},
      ];
      subTitle = "Last 7 days (minutes)";
    } else if (_selectedPeriod == 1) {
      // Month
      chartData = [
        {'label': 'W1', 'value': 120},
        {'label': 'W2', 'value': 150},
        {'label': 'W3', 'value': 90},
        {'label': 'W4', 'value': (DataManager.getTotalSecondsMonth() / 60 / 4).round()},
      ];
      subTitle = "This month (avg weekly minutes)";
    } else {
      // Year
      chartData = [
        {'label': 'Q1', 'value': 400},
        {'label': 'Q2', 'value': 550},
        {'label': 'Q3', 'value': 300},
        {'label': 'Q4', 'value': (DataManager.getTotalSecondsYear() / 60 / 4).round()},
      ];
      subTitle = "This year (quarterly minutes)";
    }

    final maxValue = chartData.map((e) => (e['value'] as num).toDouble()).fold(1.0, (a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Focus ${_periods[_selectedPeriod]}',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
          ),
          const SizedBox(height: 4),
          Text(subTitle, style: TextStyle(fontSize: 12, color: subTextColor)),
          const SizedBox(height: 20),
          SizedBox(
            height: 140,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: chartData.map((data) {
                final heightFraction = (data['value'] as num).toDouble() / maxValue;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('${data['value']}', style: TextStyle(fontSize: 10, color: subTextColor)),
                    const SizedBox(height: 4),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 600),
                      width: _selectedPeriod == 0 ? 28 : 40,
                      height: 100 * heightFraction,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A7C7C),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(data['label'] as String, style: TextStyle(fontSize: 11, color: subTextColor)),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsGrid(Color cardColor, Color textColor, Color subTextColor) {
    String periodTime = "0 m";
    if (_selectedPeriod == 0) periodTime = "${(DataManager.getTotalSecondsPeriod(7) / 60).toStringAsFixed(0)} m";
    if (_selectedPeriod == 1) periodTime = "${(DataManager.getTotalSecondsMonth() / 60).toStringAsFixed(0)} m";
    if (_selectedPeriod == 2) periodTime = "${(DataManager.getTotalSecondsYear() / 60).toStringAsFixed(0)} m";

    final List<Map<String, dynamic>> insights = [
      {'title': 'Total Sessions', 'value': '${DataManager.sessions.length}', 'icon': Icons.history},
      {'title': 'Avg Session', 'value': _calculateAvgSession(), 'icon': Icons.timer_outlined},
      {'title': '${_periods[_selectedPeriod]} Focus', 'value': periodTime, 'icon': Icons.today},
      {'title': 'Focus Score', 'value': '82%', 'icon': Icons.trending_up},
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: insights.map((insight) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A7C7C).withOpacity(0.1), 
                  borderRadius: BorderRadius.circular(10)
                ),
                child: Icon(insight['icon'] as IconData, color: const Color(0xFF2A7C7C), size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(insight['title'] as String, style: TextStyle(fontSize: 10, color: subTextColor)),
                    Text(insight['value'] as String, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textColor)),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTrainingStats(Color cardColor, Color textColor, Color subTextColor) {
    if (_trainingBests.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Training Bests', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
              IconButton(
                icon: Icon(Icons.refresh, size: 20, color: subTextColor),
                onPressed: _resetBests,
                tooltip: 'Reset Bests',
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            children: _trainingBests.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(entry.key.replaceAll('_', ' ').toUpperCase(), style: TextStyle(fontSize: 12, color: subTextColor)),
                    Text(entry.value.toInt().toString(), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF2A7C7C))),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  String _calculateAvgSession() {
    if (DataManager.sessions.isEmpty) return '0 m';
    double totalSeconds = DataManager.sessions.fold(0, (sum, item) => sum + item.durationSeconds);
    double avg = totalSeconds / DataManager.sessions.length / 60;
    return '${avg.toStringAsFixed(1)} m';
  }

  Widget _buildSessionHistory(Color cardColor, Color textColor, Color subTextColor) {
    if (DataManager.sessions.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text('Recent Focus Sessions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: math.min(DataManager.sessions.length, 5),
          itemBuilder: (context, index) {
            final session = DataManager.sessions[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(12)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.timer, size: 16, color: Color(0xFF2A7C7C)),
                      const SizedBox(width: 8),
                      Text(
                        '${(session.durationSeconds / 60).floor()}m ${session.durationSeconds % 60}s', 
                        style: TextStyle(fontWeight: FontWeight.bold, color: textColor)
                      ),
                    ],
                  ),
                  Text(
                    '${session.timestamp.day}/${session.timestamp.month} ${session.timestamp.hour}:${session.timestamp.minute.toString().padLeft(2, '0')}', 
                    style: TextStyle(color: subTextColor, fontSize: 12)
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildProgressSummary(Color cardColor, Color textColor, Color subTextColor) {
    double totalMins = DataManager.getTotalSecondsToday() / 60;
    double goal = 60.0; // Daily goal instead of weekly for better UI feedback
    double progress = (totalMins / goal).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Daily Goal Progress', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${totalMins.toStringAsFixed(0)} min', style: TextStyle(fontSize: 13, color: subTextColor)),
              Text('Goal: ${goal.toInt()} min', style: TextStyle(fontSize: 13, color: subTextColor)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: const Color(0xFF2A7C7C).withOpacity(0.1),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2A7C7C)),
            ),
          ),
          const SizedBox(height: 8),
          Text('${(progress * 100).toInt()}% of daily focus goal reached', style: const TextStyle(fontSize: 12, color: Color(0xFF2A7C7C), fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
