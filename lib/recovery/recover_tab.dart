import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../recovery/recovery_session_screen.dart';

class RecoverTab extends StatefulWidget {
  const RecoverTab({super.key});

  @override
  State<RecoverTab> createState() => _RecoverTabState();
}

class _RecoverTabState extends State<RecoverTab>
    with SingleTickerProviderStateMixin {
  late AnimationController _breathController;
  bool _isBreathing = false;
  String _breathPhase = 'Tap to begin';

  final List<Map<String, dynamic>> _recoveryTechniques = [
    {
      'title': 'Guided Meditation',
      'durationSeconds': 318, // 5 min 18 sec
      'durationText': '5:18 min',
      'description': 'Guided sessions for focus and calm.',
      'icon': Icons.self_improvement,
      'color': const Color(0xFF6A4AAC),
      'type': 'meditation',
      'videoId': 'inpok4MKVLM',
    },
    {
      'title': 'Box Breathing',
      'durationSeconds': 240,
      'durationText': '4 min',
      'description': 'Inhale → Hold → Exhale → Hold, 4s each.',
      'icon': Icons.crop_square_outlined,
      'color': const Color(0xFF2A7C7C),
      'type': 'box',
    },
    {
      'title': 'Micro-Nap Guide',
      'durationSeconds': 1200,
      'durationText': '20 min',
      'description': 'Power nap protocol for peak recovery.',
      'icon': Icons.bedtime_outlined,
      'color': const Color(0xFF4AACAC),
      'type': 'nap',
    },
  ];

  @override
  void initState() {
    super.initState();
    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
  }

  @override
  void dispose() {
    _breathController.dispose();
    super.dispose();
  }

  void _toggleBreathing() {
    setState(() {
      _isBreathing = !_isBreathing;
      if (_isBreathing) {
        _start478Cycle();
      } else {
        _breathController.stop();
        _breathPhase = 'Tap to begin';
      }
    });
  }

  void _start478Cycle() async {
    while (_isBreathing && mounted) {
      // Inhale (4s)
      if (!mounted || !_isBreathing) break;
      setState(() => _breathPhase = 'Inhale...');
      HapticFeedback.lightImpact();
      _breathController.duration = const Duration(seconds: 4);
      _breathController.forward(from: 0);
      await Future.delayed(const Duration(seconds: 4));

      // Hold (7s)
      if (!mounted || !_isBreathing) break;
      setState(() => _breathPhase = 'Hold...');
      HapticFeedback.mediumImpact();
      await Future.delayed(const Duration(seconds: 7));

      // Exhale (8s)
      if (!mounted || !_isBreathing) break;
      setState(() => _breathPhase = 'Exhale...');
      HapticFeedback.lightImpact();
      _breathController.duration = const Duration(seconds: 8);
      _breathController.reverse(from: 1);
      await Future.delayed(const Duration(seconds: 8));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1A3A3A);
    final subTextColor = isDark ? Colors.white70 : const Color(0xFF5A7A7A);
    final scaffoldBg = Theme.of(context).scaffoldBackgroundColor;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

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
              _buildBreathingCard(),
              const SizedBox(height: 20),
              _buildSectionTitle('Recovery Techniques', textColor),
              const SizedBox(height: 12),
              ..._recoveryTechniques
                  .map((t) => _buildTechniqueCard(t, cardColor, textColor, subTextColor))
                  .toList(),
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
          'Recover',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Rest is part of the process',
          style: TextStyle(fontSize: 13, color: subTextColor),
        ),
      ],
    );
  }

  Widget _buildBreathingCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2A7C7C), Color(0xFF1A5A5A)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2A7C7C).withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Breathing Exercise',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: _toggleBreathing,
            child: AnimatedBuilder(
              animation: _breathController,
              builder: (context, child) {
                double size = 100 + (_breathController.value * 50);
                return Container(
                  width: 160,
                  height: 160,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                  child: Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.2),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.5),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        _breathPhase,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _isBreathing ? 'Tap to stop' : '4-7-8 breathing technique',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color textColor) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
    );
  }

  Widget _buildTechniqueCard(Map<String, dynamic> technique, Color cardColor, Color textColor, Color subTextColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
              color: (technique['color'] as Color).withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              technique['icon'] as IconData,
              color: technique['color'] as Color,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  technique['title'] as String,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  technique['description'] as String,
                  style: TextStyle(
                    fontSize: 12,
                    color: subTextColor,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                technique['durationText'] as String,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2A7C7C),
                ),
              ),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RecoverySessionScreen(
                        title: technique['title'],
                        durationSeconds: technique['durationSeconds'],
                        type: technique['type'],
                        color: technique['color'],
                        videoId: technique['videoId'],
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
                    'Begin',
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
