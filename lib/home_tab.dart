import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:async';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  // REAL DATA STATE
  bool _sessionStarted = false;
  int _secondsFocusedToday = 0;
  final int _currentStreak = 0; // Final because it's currently static
  Timer? _focusTimer;

  void _toggleTimer() {
    setState(() {
      _sessionStarted = !_sessionStarted;
      if (_sessionStarted) {
        _focusTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          setState(() {
            _secondsFocusedToday++;
          });
        });
      } else {
        _focusTimer?.cancel();
      }
    });
  }

  String _formatTime(int totalSeconds) {
    int mins = totalSeconds ~/ 60;
    int secs = totalSeconds % 60;
    if (mins == 0) return '$secs sec';
    return '$mins min $secs sec';
  }

  @override
  void dispose() {
    _focusTimer?.cancel();
    super.dispose();
  }

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
              _buildFocusCard(),
              const SizedBox(height: 16),
              _buildQuickStats(),
              const SizedBox(height: 16),
              _buildUpcomingChallenge(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Icon(Icons.self_improvement, color: Color(0xFF2A7C7C), size: 28),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _secondsFocusedToday > 0 ? 'Good Progress, Alex' : 'Welcome, Alex',
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A3A3A)
              ),
            ),
            const Text(
              'Your attention data is shown below.',
              style: TextStyle(fontSize: 13, color: Color(0xFF5A7A7A)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFocusCard() {
    // Goal is 7 minutes (420 seconds)
    double realProgress = (_secondsFocusedToday / 420).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.teal.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4)
          )
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            height: 150,
            width: 150,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(150, 150),
                  painter: CircularProgressPainter(
                    progress: realProgress,
                    backgroundColor: const Color(0xFFE0F0F0),
                    progressColor: const Color(0xFF2A7C7C),
                    strokeWidth: 10,
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${(_secondsFocusedToday / 60).floor()}',
                      style: const TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A3A3A)
                      ),
                    ),
                    const Text(
                        'Minutes',
                        style: TextStyle(fontSize: 13, color: Color(0xFF5A7A7A))
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
              'Daily Goal: 7 Minutes',
              style: TextStyle(fontSize: 13, color: Color(0xFF5A7A7A))
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _toggleTimer,
              style: ElevatedButton.styleFrom(
                backgroundColor: _sessionStarted
                    ? Colors.orangeAccent
                    : const Color(0xFF2A7C7C),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)
                ),
                elevation: 0,
              ),
              child: Text(_sessionStarted ? 'Stop Session' : 'Start Focus Session'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.teal.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4)
          )
        ],
      ),
      child: Row(
        children: [
          _buildStatItem(
              Icons.local_fire_department,
              'Streak',
              _currentStreak == 0 ? '--' : '$_currentStreak Days'
          ),
          const SizedBox(width: 20),
          _buildStatItem(
              Icons.access_time,
              "Today",
              _secondsFocusedToday == 0 ? '0 min' : _formatTime(_secondsFocusedToday)
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF2A7C7C), size: 20),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  label,
                  style: const TextStyle(fontSize: 11, color: Color(0xFF5A7A7A))
              ),
              Text(
                  value,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A3A3A)
                  )
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingChallenge() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Text(
          "No community challenges active.",
          style: TextStyle(
              fontSize: 12,
              color: Color(0xFF5A7A7A),
              fontStyle: FontStyle.italic
          ),
        ),
      ),
    );
  }
}

// THE MISSING CLASS THAT WAS CAUSING THE RED ERROR
class CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color backgroundColor;
  final Color progressColor;
  final double strokeWidth;

  CircularProgressPainter({
    required this.progress,
    required this.backgroundColor,
    required this.progressColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(CircularProgressPainter oldDelegate) =>
      oldDelegate.progress != progress;
}