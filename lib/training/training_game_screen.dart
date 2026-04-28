import 'package:flutter/material.dart';
import 'training_widgets.dart';
import '../home/local_data_service.dart';
import '../home/data_manager.dart';

class TrainingGameScreen extends StatefulWidget {
  final String gameId;
  final String title;
  final int tier;

  const TrainingGameScreen({
    super.key,
    required this.gameId,
    required this.title,
    required this.tier,
  });

  @override
  State<TrainingGameScreen> createState() => _TrainingGameScreenState();
}

class _TrainingGameScreenState extends State<TrainingGameScreen> {
  double _currentScore = 0;
  DateTime _startTime = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF4F4),
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF1A3A3A),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                'Score: ${_currentScore.toInt()}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildGameWidget(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2A7C7C),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _finishSession,
              child: const Text('Finish Training', style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameWidget() {
    final onScore = (double score) => setState(() => _currentScore = score);

    switch (widget.gameId) {
      // Level 1
      case 'constant_trace': return ConstantTraceGame(onScoreUpdate: onScore);
      case 'color_match': return ColorMatchGame(onScoreUpdate: onScore);
      case 'missing_number': return MissingNumberGame(onScoreUpdate: onScore);
      case 'growing_bubble': return GrowingBubbleGame(onScoreUpdate: onScore);
      // Level 2
      case 'dual_orb': return DualOrbGame(onScoreUpdate: onScore);
      case 'stroop': return StroopGame(onScoreUpdate: onScore);
      case 'odd_one_out': return OddOneOutGame(onScoreUpdate: onScore);
      case 'rhythm': return RhythmGame(onScoreUpdate: onScore);
      // Level 3
      case 'mot': return MOTGame(onScoreUpdate: onScore);
      case 'pattern_recall': return PatternRecallGame(onScoreUpdate: onScore);
      case 'peripheral': return PeripheralGame(onScoreUpdate: onScore);
      case 'inverse_reaction': return InverseReactionGame(onScoreUpdate: onScore);
      default: return const Center(child: Text("Game Not Found"));
    }
  }

  void _finishSession() async {
    final durationSeconds = DateTime.now().difference(_startTime).inSeconds;
    
    // Save Personal Best
    await LocalDataService.savePersonalBest(widget.gameId, _currentScore);
    
    // Record for Tier Progress (Assume success if score > 0 for now)
    bool success = _currentScore > 0;
    await LocalDataService.recordSessionSuccess(widget.tier, success);
    
    // Add to Global Focus Logs
    await DataManager.addSession(durationSeconds);
    
    if (mounted) {
      Navigator.pop(context, true);
    }
  }
}
