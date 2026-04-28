import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:async';
import '../home/data_manager.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with TickerProviderStateMixin {
  // SESSION STATE
  bool _sessionStarted = false;
  int _sessionSeconds = 0;
  int _offOrbSeconds = 0;
  Timer? _focusTimer;
  bool _isUserTouchingOrb = false;

  // ANIMATION FOR ORB
  late AnimationController _orbController;
  Offset _orbPosition = Offset.zero;
  final double _pathRadius = 60.0;
  final double _containerSize = 250.0;

  @override
  void initState() {
    super.initState();
    _orbController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..addListener(() {
      _updateOrbPosition();
    });
    
    // Initial position
    _updateOrbPosition();
    
    // Listen to changes in DataManager to refresh total focus time
    DataManager.sessionsChangedCounter.addListener(_refresh);
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  void _updateOrbPosition() {
    final double angle = _orbController.value * 2 * math.pi;
    final double center = _containerSize / 2;
    setState(() {
      _orbPosition = Offset(
        center + _pathRadius * math.cos(angle),
        center + _pathRadius * math.sin(angle),
      );
    });
  }

  void _toggleTimer() {
    setState(() {
      _sessionStarted = !_sessionStarted;
      if (_sessionStarted) {
        _sessionSeconds = 0;
        _offOrbSeconds = 0;
        _orbController.repeat();
        _focusTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (_isUserTouchingOrb) {
            _offOrbSeconds = 0;
            setState(() {
              _sessionSeconds++;
            });
          } else {
            _offOrbSeconds++;
            if (_offOrbSeconds >= 5) {
              _stopSession();
            }
          }
        });
      } else {
        _stopSession();
      }
    });
  }

  void _stopSession() {
    _focusTimer?.cancel();
    _orbController.stop();
    
    // Save to global logs if session had any progress
    if (_sessionSeconds > 0) {
      DataManager.addSession(_sessionSeconds);
    }

    setState(() {
      _sessionStarted = false;
      _isUserTouchingOrb = false;
    });
    
    debugPrint('Focus Session Logged: $_sessionSeconds seconds.');
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
    _orbController.dispose();
    DataManager.sessionsChangedCounter.removeListener(_refresh);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int totalSecondsToday = DataManager.getTotalSecondsToday();
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
              _buildHeader(totalSecondsToday, textColor, subTextColor),
              const SizedBox(height: 20),
              _buildFocusCard(totalSecondsToday, cardColor, textColor, subTextColor, scaffoldBg),
              const SizedBox(height: 16),
              _buildQuickStats(totalSecondsToday, cardColor, textColor, subTextColor),
              const SizedBox(height: 16),
              _buildSessionLogs(cardColor, textColor, subTextColor, scaffoldBg), 
              const SizedBox(height: 16),
              _buildUpcomingChallenge(subTextColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(int totalSeconds, Color textColor, Color subTextColor) {
    return Row(
      children: [
        const Icon(Icons.self_improvement, color: Color(0xFF2A7C7C), size: 28),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ValueListenableBuilder<String>(
              valueListenable: DataManager.userName,
              builder: (context, name, child) {
                return Text(
                  totalSeconds > 0 ? 'Good Progress, $name' : 'Welcome, $name',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: textColor
                  ),
                );
              }
            ),
            Text(
              'Your attention data is shown below.',
              style: TextStyle(fontSize: 13, color: subTextColor),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFocusCard(int totalSeconds, Color cardColor, Color textColor, Color subTextColor, Color scaffoldBg) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4)
          )
        ],
      ),
      child: Column(
        children: [
          Text(
            '${(totalSeconds / 60).floor()}',
            style: TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.bold,
                color: textColor
            ),
          ),
          Text(
              'Minutes Focused Today',
              style: TextStyle(fontSize: 13, color: subTextColor)
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onPanStart: (details) => _checkTouch(details.localPosition),
            onPanUpdate: (details) => _checkTouch(details.localPosition),
            onPanEnd: (_) => setState(() => _isUserTouchingOrb = false),
            behavior: HitTestBehavior.opaque,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: _containerSize,
                  height: _containerSize,
                  decoration: BoxDecoration(
                    color: _sessionStarted && !_isUserTouchingOrb 
                        ? Colors.black.withOpacity(0.05) 
                        : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                ),
                CustomPaint(
                  size: Size(_containerSize, _containerSize),
                  painter: AttentionAnchorPainter(
                    orbPosition: _orbPosition,
                    isTouching: _isUserTouchingOrb,
                    pathRadius: _pathRadius,
                    sessionStarted: _sessionStarted,
                    pathColor: scaffoldBg,
                  ),
                ),
                if (_sessionStarted && !_isUserTouchingOrb)
                  Positioned(
                    top: 20,
                    child: Text(
                      'Returning in ${5 - _offOrbSeconds}s...',
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
              'Daily Goal: 7 Minutes',
              style: TextStyle(fontSize: 13, color: subTextColor)
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

  void _checkTouch(Offset localPosition) {
    if (!_sessionStarted) return;
    final double distance = (localPosition - _orbPosition).distance;
    setState(() {
      // Significantly increased detection radius for massive margin of error
      _isUserTouchingOrb = distance < 120.0;
    });
  }

  Widget _buildSessionLogs(Color cardColor, Color textColor, Color subTextColor, Color scaffoldBg) {
    if (DataManager.sessions.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            'Recent Focus Sessions (Top 10)',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textColor),
          ),
        ),
        ...DataManager.sessions.take(10).map((session) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: scaffoldBg),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.timer_outlined, size: 16, color: Color(0xFF2A7C7C)),
                  const SizedBox(width: 8),
                  Text(_formatTime(session.durationSeconds), style: TextStyle(fontWeight: FontWeight.w600, color: textColor)),
                ],
              ),
              Text(
                '${session.timestamp.hour.toString().padLeft(2, '0')}:${session.timestamp.minute.toString().padLeft(2, '0')}',
                style: TextStyle(fontSize: 12, color: subTextColor),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildQuickStats(int totalSeconds, Color cardColor, Color textColor, Color subTextColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
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
              '${DataManager.getStreak()} Days',
              textColor,
              subTextColor
          ),
          const SizedBox(width: 20),
          _buildStatItem(
              Icons.access_time,
              "Today",
              totalSeconds == 0 ? '0 min' : _formatTime(totalSeconds),
              textColor,
              subTextColor
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value, Color textColor, Color subTextColor) {
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
                  style: TextStyle(fontSize: 11, color: subTextColor)
              ),
              Text(
                  value,
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: textColor
                  )
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingChallenge(Color subTextColor) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Text(
          "No community challenges active.",
          style: TextStyle(
              fontSize: 12,
              color: subTextColor,
              fontStyle: FontStyle.italic
          ),
        ),
      ),
    );
  }
}

class AttentionAnchorPainter extends CustomPainter {
  final Offset orbPosition;
  final bool isTouching;
  final double pathRadius;
  final bool sessionStarted;
  final Color pathColor;

  AttentionAnchorPainter({
    required this.orbPosition,
    required this.isTouching,
    required this.pathRadius,
    required this.sessionStarted,
    required this.pathColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    // 1. Draw Path
    final pathPaint = Paint()
      ..color = pathColor.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawCircle(center, pathRadius, pathPaint);

    // 2. Draw Orb
    if (sessionStarted) {
      final orbPaint = Paint()
        ..color = isTouching ? const Color(0xFF2A7C7C) : Colors.redAccent
        ..style = PaintingStyle.fill;
      
      double radius = 24.0; 
      canvas.drawCircle(orbPosition, radius, orbPaint);
      
      if (isTouching) {
        canvas.drawCircle(
          orbPosition, 
          radius + 12, // Increased glow
          Paint()..color = const Color(0xFF2A7C7C).withOpacity(0.2)..style = PaintingStyle.fill
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant AttentionAnchorPainter oldDelegate) {
    return oldDelegate.orbPosition != orbPosition || 
           oldDelegate.isTouching != isTouching ||
           oldDelegate.sessionStarted != sessionStarted;
  }
}
