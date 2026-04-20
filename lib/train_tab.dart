import 'package:flutter/material.dart';

class TrainTab extends StatefulWidget {
  const TrainTab({super.key});

  @override
  State<TrainTab> createState() => _TrainTabState();
}

class _TrainTabState extends State<TrainTab> {
  int _selectedDifficulty = 1;
  final List<String> _difficulties = ['Beginner', 'Intermediate', 'Advanced'];

  final List<Map<String, dynamic>> _exercises = [
    {
      'title': 'Single-Task Sprint',
      'duration': '10 min',
      'description': 'Focus on one task with zero distractions.',
      'icon': Icons.bolt,
      'color': Color(0xFF2A7C7C),
    },
    {
      'title': 'Deep Work Block',
      'duration': '25 min',
      'description': 'Classic Pomodoro-style deep work session.',
      'icon': Icons.hourglass_bottom,
      'color': Color(0xFF3A9C8C),
    },
    {
      'title': 'Mindful Attention',
      'duration': '15 min',
      'description': 'Train your attention with mindful breathing.',
      'icon': Icons.self_improvement,
      'color': Color(0xFF1A6A6A),
    },
    {
      'title': 'Cognitive Load',
      'duration': '20 min',
      'description': 'Challenge working memory and concentration.',
      'icon': Icons.psychology,
      'color': Color(0xFF4AACAC),
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
              _buildDifficultySelector(),
              const SizedBox(height: 20),
              _buildSectionTitle('Today\'s Training'),
              const SizedBox(height: 12),
              ..._exercises.map((e) => _buildExerciseCard(e)).toList(),
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
          'Train',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A3A3A),
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Build your focus muscles daily',
          style: TextStyle(fontSize: 13, color: Color(0xFF5A7A7A)),
        ),
      ],
    );
  }

  Widget _buildDifficultySelector() {
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
        children: List.generate(_difficulties.length, (index) {
          final isSelected = _selectedDifficulty == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedDifficulty = index),
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
                  _difficulties[index],
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1A3A3A),
      ),
    );
  }

  Widget _buildExerciseCard(Map<String, dynamic> exercise) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
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
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (exercise['color'] as Color).withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              exercise['icon'] as IconData,
              color: exercise['color'] as Color,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise['title'] as String,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A3A3A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  exercise['description'] as String,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF5A7A7A)),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                exercise['duration'] as String,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2A7C7C),
                ),
              ),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                      Text('Starting ${exercise['title']}! 🎯'),
                      backgroundColor: const Color(0xFF2A7C7C),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A7C7C),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Start',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}