import 'package:flutter/material.dart';
import '../training/training_game_screen.dart';
import '../home/local_data_service.dart';

class TrainTab extends StatefulWidget {
  const TrainTab({super.key});

  @override
  State<TrainTab> createState() => _TrainTabState();
}

class _TrainTabState extends State<TrainTab> {
  int _selectedDifficulty = 0;
  final List<String> _difficulties = ['Beginner', 'Intermediate', 'Advanced'];
  int _unlockedTier = 2; // UNLOCKED ALL FOR PLAY TESTING

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final tier = await LocalDataService.getUnlockedTier();
    setState(() {
      _unlockedTier = 2; 
    });
  }

  List<Map<String, dynamic>> _getExercises() {
    switch (_selectedDifficulty) {
      case 0: // Beginner
        return [
          {'id': 'constant_trace', 'title': 'The Constant Trace', 'description': 'Maintain continuous touch on the moving orb.', 'icon': Icons.gesture, 'color': const Color(0xFF2A7C7C)},
          {'id': 'color_match', 'title': 'Sustained Color Match', 'description': 'Tap when colors match the target.', 'icon': Icons.palette, 'color': const Color(0xFF3A9C8C)},
          {'id': 'missing_number', 'title': 'Missing Number Flow', 'description': 'Detect gaps in numerical sequences.', 'icon': Icons.exposure_minus_1, 'color': const Color(0xFF1A6A6A)},
          {'id': 'growing_bubble', 'title': 'The Growing Bubble', 'description': 'Precision timing on expanding circles.', 'icon': Icons.adjust, 'color': const Color(0xFF4AACAC)},
        ];
      case 1: // Intermediate
        return [
          {'id': 'dual_orb', 'title': 'Dual-Orb Trace', 'description': 'Ignore the distractor, follow the teal.', 'icon': Icons.track_changes, 'color': const Color(0xFF2A7C7C)},
          {'id': 'stroop', 'title': 'Stroop Semantic Task', 'description': 'Inhibit automatic reading responses.', 'icon': Icons.spellcheck, 'color': const Color(0xFF3A9C8C)},
          {'id': 'odd_one_out', 'title': 'Odd-One-Out Grid', 'description': 'Find geometric anomalies rapidly.', 'icon': Icons.grid_view, 'color': const Color(0xFF1A6A6A)},
          {'id': 'rhythm', 'title': 'Rhythm Keeper', 'description': 'Maintain tempo without visual aid.', 'icon': Icons.music_note, 'color': const Color(0xFF4AACAC)},
        ];
      case 2: // Advanced
        return [
          {'id': 'mot', 'title': 'Multi-Object Tracking', 'description': 'Follow multiple moving targets.', 'icon': Icons.bubble_chart, 'color': const Color(0xFF2A7C7C)},
          {'id': 'pattern_recall', 'title': 'Pattern Recall Burst', 'description': 'Reconstruct flashed grid patterns.', 'icon': Icons.memory, 'color': const Color(0xFF3A9C8C)},
          {'id': 'peripheral', 'title': 'Peripheral Detection', 'description': 'Spot shapes while tracing central path.', 'icon': Icons.visibility, 'color': const Color(0xFF1A6A6A)},
          {'id': 'inverse_reaction', 'title': 'Inverse Reaction', 'description': 'Tap for circles, stay still for squares.', 'icon': Icons.swap_horiz, 'color': const Color(0xFF4AACAC)},
        ];
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1A3A3A);
    final subTextColor = isDark ? Colors.white70 : const Color(0xFF5A7A7A);
    final scaffoldBg = Theme.of(context).scaffoldBackgroundColor;

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
              _buildDifficultySelector(cardColor, subTextColor),
              const SizedBox(height: 20),
              _buildSectionTitle('Tier Exercises', textColor),
              const SizedBox(height: 12),
              ..._getExercises().map((e) => _buildExerciseCard(e, cardColor, textColor, subTextColor)).toList(),
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
          'Training Engine',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: textColor),
        ),
        const SizedBox(height: 4),
        Text(
          '12 scientifically grounded cognitive exercises',
          style: TextStyle(fontSize: 13, color: subTextColor),
        ),
      ],
    );
  }

  Widget _buildDifficultySelector(Color cardColor, Color subTextColor) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: List.generate(_difficulties.length, (index) {
          final isSelected = _selectedDifficulty == index;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() => _selectedDifficulty = index);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF2A7C7C) : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _difficulties[index],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : subTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color textColor) {
    return Text(title, style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: textColor));
  }

  Widget _buildExerciseCard(Map<String, dynamic> exercise, Color cardColor, Color textColor, Color subTextColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (exercise['color'] as Color).withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(exercise['icon'] as IconData, color: exercise['color'] as Color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(exercise['title'] as String, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: textColor)),
                const SizedBox(height: 2),
                Text(exercise['description'] as String, style: TextStyle(fontSize: 12, color: subTextColor)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () => _startExercise(exercise),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2A7C7C),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Start', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _startExercise(Map<String, dynamic> exercise) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TrainingGameScreen(
          gameId: exercise['id'],
          title: exercise['title'],
          tier: _selectedDifficulty,
        ),
      ),
    );

    if (result == true) {
      _checkTierUnlock();
    }
  }

  void _checkTierUnlock() async {
    bool shouldUnlock = await LocalDataService.shouldUnlockNextTier(_selectedDifficulty);
    if (shouldUnlock && _unlockedTier == _selectedDifficulty) {
      int nextTier = _selectedDifficulty + 1;
      await LocalDataService.setUnlockedTier(nextTier);
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Level Up! 🚀'),
            content: Text('You have unlocked the ${_difficulties[nextTier]} tier!'),
            actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Great!'))],
          ),
        );
        _loadProgress();
      }
    }
  }
}
