import 'package:flutter/material.dart';

class AnalyzeTab extends StatefulWidget {
  const AnalyzeTab({super.key});

  @override
  State<AnalyzeTab> createState() => _AnalyzeTabState();
}

class _AnalyzeTabState extends State<AnalyzeTab> {
  int _selectedPeriod = 0;
  final List<String> _periods = ['Week', 'Month', 'Year'];

  // Mock weekly data (minutes)
  final List<Map<String, dynamic>> _weekData = [
    {'day': 'Mon', 'minutes': 15, 'color': Color(0xFF2A7C7C)},
    {'day': 'Tue', 'minutes': 30, 'color': Color(0xFF2A7C7C)},
    {'day': 'Wed', 'minutes': 20, 'color': Color(0xFF2A7C7C)},
    {'day': 'Thu', 'minutes': 45, 'color': Color(0xFF2A7C7C)},
    {'day': 'Fri', 'minutes': 10, 'color': Color(0xFF2A7C7C)},
    {'day': 'Sat', 'minutes': 35, 'color': Color(0xFF2A7C7C)},
    {'day': 'Sun', 'minutes': 12, 'color': Color(0xFFE0F0F0)},
  ];

  final List<Map<String, dynamic>> _insights = [
    {
      'title': 'Peak Focus Time',
      'value': '10–11 AM',
      'icon': Icons.wb_sunny_outlined,
    },
    {
      'title': 'Avg Session',
      'value': '23 Min',
      'icon': Icons.timer_outlined,
    },
    {
      'title': 'Best Day',
      'value': 'Thursday',
      'icon': Icons.star_outline,
    },
    {
      'title': 'Focus Score',
      'value': '78%',
      'icon': Icons.trending_up,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF4F4),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildPeriodSelector(),
              const SizedBox(height: 20),
              _buildChartCard(),
              const SizedBox(height: 16),
              _buildInsightsGrid(),
              const SizedBox(height: 16),
              _buildProgressSummary(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Analyze',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A3A3A),
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Understand your focus patterns',
          style: TextStyle(fontSize: 13, color: Color(0xFF5A7A7A)),
        ),
      ],
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withOpacity(0.08),
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
                    color: isSelected ? Colors.white : const Color(0xFF5A7A7A),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildChartCard() {
    final maxMinutes =
    _weekData.map((e) => e['minutes'] as int).reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Focus Minutes',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A3A3A),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'This week',
            style: TextStyle(fontSize: 12, color: Color(0xFF5A7A7A)),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 140,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _weekData.map((data) {
                final heightFraction =
                    (data['minutes'] as int) / maxMinutes;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '${data['minutes']}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF5A7A7A),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOut,
                      width: 28,
                      height: 100 * heightFraction,
                      decoration: BoxDecoration(
                        color: data['color'] as Color,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      data['day'] as String,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF5A7A7A),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: _insights.map((insight) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.teal.withOpacity(0.07),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF4F4),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  insight['icon'] as IconData,
                  color: const Color(0xFF2A7C7C),
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      insight['title'] as String,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF5A7A7A),
                      ),
                    ),
                    Text(
                      insight['value'] as String,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A3A3A),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildProgressSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Weekly Goal Progress',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A3A3A),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('167 min', style: TextStyle(fontSize: 13, color: Color(0xFF5A7A7A))),
              Text('Goal: 210 min', style: TextStyle(fontSize: 13, color: Color(0xFF5A7A7A))),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: 167 / 210,
              minHeight: 10,
              backgroundColor: const Color(0xFFE0F0F0),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2A7C7C)),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '79% of weekly goal achieved 🎉',
            style: TextStyle(fontSize: 12, color: Color(0xFF2A7C7C), fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}