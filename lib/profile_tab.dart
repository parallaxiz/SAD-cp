import 'package:flutter/material.dart';
import 'data_manager.dart';
import 'local_data_service.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  bool _isEditing = false;
  Map<String, double> _personalBests = {};
  int _unlockedTier = 0;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: DataManager.userName.value);
    _emailController = TextEditingController(text: 'ved@123.com');
    _loadTrainingData();
    DataManager.userName.addListener(_onDataChanged);
    DataManager.sessionsChangedCounter.addListener(_onDataChanged);
  }

  Future<void> _loadTrainingData() async {
    final pbs = await LocalDataService.getPersonalBests();
    final tier = await LocalDataService.getUnlockedTier();
    if (mounted) {
      setState(() {
        _personalBests = pbs;
        _unlockedTier = tier;
      });
    }
  }

  void _onDataChanged() {
    if (mounted) {
      if (!_isEditing) _nameController.text = DataManager.userName.value;
      setState(() {});
    }
  }

  @override
  void dispose() {
    DataManager.userName.removeListener(_onDataChanged);
    DataManager.sessionsChangedCounter.removeListener(_onDataChanged);
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _getAchievements() {
    int sessions = DataManager.sessions.length;
    int streak = DataManager.getStreak();
    bool hasHighScore = _personalBests.values.any((v) => v >= 50);
    double totalHours = DataManager.getTotalSecondsAllTime() / 3600;

    return [
      {
        'id': 'beginner',
        'title': 'Focus Novice',
        'subtitle': 'Complete 5 sessions',
        'icon': Icons.bolt,
        'unlocked': sessions >= 5,
        'color': Colors.orange,
      },
      {
        'id': 'pro',
        'title': 'Focus Master',
        'subtitle': 'Complete 25 sessions',
        'icon': Icons.workspace_premium,
        'unlocked': sessions >= 25,
        'color': Colors.amber,
      },
      {
        'id': 'streak_3',
        'title': '3-Day Streak',
        'subtitle': 'Focus 3 days in a row',
        'icon': Icons.whatshot,
        'unlocked': streak >= 3,
        'color': Colors.deepOrange,
      },
      {
        'id': 'streak_7',
        'title': 'Week Warrior',
        'subtitle': 'Focus 7 days in a row',
        'icon': Icons.calendar_month,
        'unlocked': streak >= 7,
        'color': Colors.purple,
      },
      {
        'id': 'high_score',
        'title': 'High Achiever',
        'subtitle': 'Score 50+ in any game',
        'icon': Icons.star,
        'unlocked': hasHighScore,
        'color': Colors.blue,
      },
      {
        'id': 'tier_up',
        'title': 'Tier Climber',
        'subtitle': 'Unlock Tier 2',
        'icon': Icons.trending_up,
        'unlocked': _unlockedTier >= 1,
        'color': Colors.teal,
      },
      {
        'id': 'marathon',
        'title': 'Deep Diver',
        'subtitle': '10+ total focus hours',
        'icon': Icons.timer,
        'unlocked': totalHours >= 10,
        'color': Colors.indigo,
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileHeader(cardColor, textColor),
              const SizedBox(height: 24),
              Text("Performance Stats", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: textColor)),
              const SizedBox(height: 12),
              _buildStatsGrid(cardColor),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Achievements", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: textColor)),
                  Text("${_getAchievements().where((a) => a['unlocked'] == true).length}/${_getAchievements().length}", 
                    style: const TextStyle(color: Color(0xFF2A7C7C), fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 12),
              _buildAchievementsList(cardColor, textColor),
              const SizedBox(height: 24),
              Text("Preferences", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: textColor)),
              const SizedBox(height: 12),
              _buildPreferences(cardColor, textColor),
              const SizedBox(height: 24),
              _buildDangerZone(cardColor, textColor),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(Color cardColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
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
          CircleAvatar(
            radius: 40,
            backgroundColor: const Color(0xFF2A7C7C),
            child: Text(
              DataManager.userName.value.isNotEmpty ? DataManager.userName.value[0].toUpperCase() : '?',
              style: const TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _isEditing
                    ? TextField(
                        controller: _nameController,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: textColor),
                        decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.symmetric(vertical: 8)),
                      )
                    : Text(
                        DataManager.userName.value,
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
                      ),
                const SizedBox(height: 4),
                _isEditing
                    ? TextField(
                        controller: _emailController,
                        style: TextStyle(fontSize: 14, color: textColor.withOpacity(0.7)),
                        decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.symmetric(vertical: 4)),
                      )
                    : Text(
                        _emailController.text,
                        style: TextStyle(fontSize: 14, color: textColor.withOpacity(0.6)),
                      ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(_isEditing ? Icons.check_circle : Icons.edit, color: const Color(0xFF2A7C7C), size: 28),
            onPressed: () {
              if (_isEditing) {
                DataManager.updateName(_nameController.text);
              }
              setState(() => _isEditing = !_isEditing);
            },
          )
        ],
      ),
    );
  }

  Widget _buildStatsGrid(Color cardColor) {
    int totalSessions = DataManager.sessions.length;
    double totalHours = DataManager.getTotalSecondsAllTime() / 3600;
    int streak = DataManager.getStreak();
    int todayMins = DataManager.getTotalSecondsToday() ~/ 60;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: [
        _statItem(cardColor, "Total Focus", "${totalHours.toStringAsFixed(1)}h", Icons.timer),
        _statItem(cardColor, "Current Streak", "$streak Days", Icons.whatshot),
        _statItem(cardColor, "Sessions", "$totalSessions", Icons.history),
        _statItem(cardColor, "Today", "${todayMins}m", Icons.today),
      ],
    );
  }

  Widget _statItem(Color cardColor, String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: const Color(0xFF2A7C7C)),
              const SizedBox(width: 6),
              Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildAchievementsList(Color cardColor, Color textColor) {
    final achievements = _getAchievements();
    
    return Column(
      children: achievements.map((a) {
        bool unlocked = a['unlocked'] as bool;
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            border: unlocked ? Border.all(color: (a['color'] as Color).withOpacity(0.3), width: 1) : null,
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: unlocked ? (a['color'] as Color).withOpacity(0.15) : Colors.grey.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  a['icon'] as IconData, 
                  color: unlocked ? a['color'] as Color : Colors.grey.withOpacity(0.5),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      a['title'] as String,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: unlocked ? textColor : textColor.withOpacity(0.4),
                      ),
                    ),
                    Text(
                      a['subtitle'] as String,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              if (unlocked)
                const Icon(Icons.verified, color: Color(0xFF2A7C7C), size: 20)
              else
                Icon(Icons.lock_outline, color: Colors.grey.withOpacity(0.3), size: 18),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPreferences(Color cardColor, Color textColor) {
    return Container(
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          ValueListenableBuilder<bool>(
            valueListenable: DataManager.isDarkMode,
            builder: (context, isDark, child) {
              return SwitchListTile(
                title: const Text("Dark Mode", style: TextStyle(fontWeight: FontWeight.w500)),
                subtitle: const Text("Switch to a darker theme"),
                value: isDark,
                activeColor: const Color(0xFF2A7C7C),
                onChanged: (val) => DataManager.toggleDarkMode(val),
              );
            }
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          SwitchListTile(
            title: const Text("Push Notifications", style: TextStyle(fontWeight: FontWeight.w500)),
            subtitle: const Text("Reminders for your focus sessions"),
            value: true,
            activeColor: const Color(0xFF2A7C7C),
            onChanged: (val) {},
          ),
        ],
      ),
    );
  }

  Widget _buildDangerZone(Color cardColor, Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Text("Danger Zone", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        ),
        Container(
          decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(20)),
          child: ListTile(
            leading: const Icon(Icons.refresh, color: Colors.red),
            title: const Text("Reset Training Data", style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500)),
            onTap: _showResetConfirmation,
          ),
        ),
      ],
    );
  }

  void _showResetConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Reset Training Data?"),
        content: const Text("This will permanently delete all your high scores and reset your tier progress."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              await LocalDataService.resetPersonalBests();
              await LocalDataService.resetTierProgress();
              _loadTrainingData();
              if (mounted) Navigator.pop(context);
              if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Training data reset successfully")));
            },
            child: const Text("Reset", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
