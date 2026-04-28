import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class RecoverySessionScreen extends StatefulWidget {
  final String title;
  final int durationSeconds;
  final String type;
  final Color color;
  final String? videoId;

  const RecoverySessionScreen({
    super.key,
    required this.title,
    required this.durationSeconds,
    required this.type,
    required this.color,
    this.videoId,
  });

  @override
  State<RecoverySessionScreen> createState() => _RecoverySessionScreenState();
}

class _RecoverySessionScreenState extends State<RecoverySessionScreen>
    with SingleTickerProviderStateMixin {
  late int _remainingSeconds;
  Timer? _timer;
  bool _isActive = false;
  String _currentInstruction = "Press Start to begin";
  
  late AnimationController _animationController;
  YoutubePlayerController? _ytController;
  
  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.durationSeconds;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    if (widget.videoId != null) {
      _ytController = YoutubePlayerController(
        initialVideoId: widget.videoId!,
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
          disableDragSeek: true,
          loop: true,
        ),
      )..addListener(_onYoutubeStateChange);
    }
  }

  void _onYoutubeStateChange() {
    if (_ytController != null && mounted) {
      if (_ytController!.value.isPlaying && !_isActive) {
        _startTimer();
      } else if (!_ytController!.value.isPlaying && _isActive) {
        _pauseTimer();
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    _ytController?.dispose();
    super.dispose();
  }

  void _startTimer() {
    if (_isActive) return;
    setState(() {
      _isActive = true;
      _startSessionLogic();
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
          _updateInstruction();
        });
      } else {
        _timer?.cancel();
        _showCompletion();
      }
    });
  }

  void _pauseTimer() {
    if (!_isActive) return;
    _timer?.cancel();
    _animationController.stop();
    setState(() {
      _isActive = false;
      _currentInstruction = "Paused";
    });
  }

  void _toggleTimer() {
    if (_isActive) {
      _ytController?.pause();
      _pauseTimer();
    } else {
      _ytController?.play();
      _startTimer();
    }
  }

  void _startSessionLogic() {
    if (widget.type == 'box') {
      _animationController.repeat(reverse: true);
    } else {
      _animationController.duration = const Duration(seconds: 3);
      _animationController.repeat(reverse: true);
    }
  }

  void _updateInstruction() {
    if (widget.type == 'box') {
      int cyclePos = (widget.durationSeconds - _remainingSeconds) % 16;
      if (cyclePos == 0) {
        _currentInstruction = "Inhale (4s)";
        HapticFeedback.mediumImpact();
        _animationController.duration = const Duration(seconds: 4);
        _animationController.forward(from: 0);
      } else if (cyclePos == 4) {
        _currentInstruction = "Hold (4s)";
        HapticFeedback.lightImpact();
        _animationController.stop();
      } else if (cyclePos == 8) {
        _currentInstruction = "Exhale (4s)";
        HapticFeedback.mediumImpact();
        _animationController.duration = const Duration(seconds: 4);
        _animationController.reverse(from: 1);
      } else if (cyclePos == 12) {
        _currentInstruction = "Hold (4s)";
        HapticFeedback.lightImpact();
        _animationController.stop();
      }
    } else if (widget.type == 'nature' || widget.type == 'meditation') {
      _currentInstruction = widget.type == 'meditation' 
          ? "Follow the guided meditation..." 
          : "Listen and breathe deeply...";
      if (_remainingSeconds % 60 == 0) HapticFeedback.selectionClick();
    } else if (widget.type == 'nap') {
      if (_remainingSeconds > widget.durationSeconds - 60) {
        _currentInstruction = "Find a comfortable position...";
      } else if (_remainingSeconds > 60) {
        _currentInstruction = "Deep restorative rest...";
      } else {
        _currentInstruction = "Gently waking up...";
        if (_remainingSeconds == 10) HapticFeedback.vibrate();
      }
    }
  }

  void _showCompletion() {
    HapticFeedback.heavyImpact();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Session Complete"),
        content: Text("You have completed your ${widget.title}. Take a moment to notice how you feel."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text("Finish"),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    int mins = seconds ~/ 60;
    int secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    double progress = 1 - (_remainingSeconds / widget.durationSeconds);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F7F7),
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF1A3A3A),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_ytController != null)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  height: 220,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: YoutubePlayer(
                      controller: _ytController!,
                      showVideoProgressIndicator: true,
                    ),
                  ),
                )
              else
                _buildAnimatedVisual(),
              const SizedBox(height: 40),
              Text(
                _formatTime(_remainingSeconds),
                style: const TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.w200,
                  color: Color(0xFF1A3A3A),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  _currentInstruction,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: widget.color,
                  ),
                ),
              ),
              const SizedBox(height: 60),
              _buildStartButton(),
              const SizedBox(height: 40),
              if (progress > 0)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 60),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: widget.color.withOpacity(0.1),
                    color: widget.color,
                    minHeight: 4,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedVisual() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        double scale = 1.0 + (_animationController.value * 0.4);
        return Transform.scale(
          scale: scale,
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.color.withOpacity(0.1),
            ),
            child: Center(
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color.withOpacity(0.2),
                ),
                child: Icon(_getIcon(), size: 50, color: widget.color),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStartButton() {
    return GestureDetector(
      onTap: _toggleTimer,
      child: Container(
        width: 200,
        height: 60,
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: widget.color.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: Text(
            _isActive ? 'PAUSE' : 'START SESSION',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIcon() {
    switch (widget.type) {
      case 'box': return Icons.crop_square;
      case 'nap': return Icons.bedtime;
      default: return Icons.self_improvement;
    }
  }
}
