import 'package:flutter/material.dart';

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
      'title': 'Box Breathing',
      'duration': '4 min',
      'description': 'Inhale → Hold → Exhale → Hold, 4s each.',
      'icon': Icons.crop_square_outlined,
      'color': Color(0xFF2A7C7C),
    },
    {
      'title': 'Body Scan',
      'duration': '8 min',
      'description': 'Progressive relaxation from head to toe.',
      'icon': Icons.accessibility_new,
      'color': Color(0xFF3A9C8C),
    },
    {
      'title': 'Nature Sounds',
      'duration': '10 min',
      'description': 'Ambient sounds to reset your nervous system.',
      'icon': Icons.nature,
      'color': Color(0xFF1A6A6A),
    },
    {
      'title': 'Micro-Nap Guide',
      'duration': '20 min',
      'description': 'Power nap protocol for peak recovery.',
      'icon': Icons.bedtime_outlined,
      'color': Color(0xFF4AACAC),
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
        _startBreathingCycle();
      } else {
        _breathController.stop();
        _breathPhase = 'Tap to begin';
      }
    });
  }

  void _startBreathingCycle() async {
    final phases = ['Inhale...', 'Hold...', 'Exhale...', 'Hold...'];
    int i = 0;
    while (_isBreathing) {
      if (!mounted) break;
      setState(() => _breathPhase = phases[i % 4]);
      await Future.delayed(const Duration(seconds: 4));
      i++;
    }
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
              _buildBreathingCard(),
              const SizedBox(height: 20),
              _buildSectionTitle('Recovery Techniques'),
              const SizedBox(height: 12),
              ..._recoveryTechniques
                  .map((t) => _buildTechniqueCard(t))
                  .toList(),
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
          'Recover',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A3A3A),
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Rest is part of the process',
          style: TextStyle(fontSize: 13, color: Color(0xFF5A7A7A)),
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
            child: AnimatedContainer(
              duration: const Duration(seconds: 4),
              curve: Curves.easeInOut,
              width: _isBreathing ? 130 : 100,
              height: _isBreathing ? 130 : 100,
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
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
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

  Widget _buildTechniqueCard(Map<String, dynamic> technique) {
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
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A3A3A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  technique['description'] as String,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF5A7A7A),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                technique['duration'] as String,
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
                      content: Text('Starting ${technique['title']}... 🧘'),
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