import 'package:flutter/material.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  bool _notificationsEnabled = true;
  bool _dailyRemindersEnabled = true;
  bool _darkModeEnabled = false;

  final List<Map<String, dynamic>> _achievements = [
    {'icon': Icons.bolt, 'label': '7-Day Streak', 'unlocked': true},
    {'icon': Icons.star, 'label': 'First Hour', 'unlocked': true},
    {'icon': Icons.group, 'label': 'Co-Focus Pro', 'unlocked': true},
    {'icon': Icons.lock_outline, 'label': '30-Day Goal', 'unlocked': false},
    {'icon': Icons.lock_outline, 'label': 'Focus Master', 'unlocked': false},
    {'icon': Icons.lock_outline, 'label': 'Night Owl', 'unlocked': false},
  ];

  final List<Map<String, dynamic>> _settingsItems = [
    {'icon': Icons.notifications_outlined, 'label': 'Notifications'},
    {'icon': Icons.privacy_tip_outlined, 'label': 'Privacy'},
    {'icon': Icons.help_outline, 'label': 'Help & Support'},
    {'icon': Icons.info_outline, 'label': 'About'},
    {'icon': Icons.logout, 'label': 'Log Out'},
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
              _buildProfileHeader(),
              const SizedBox(height: 20),
              _buildStatsRow(),
              const SizedBox(height: 20),
              _buildAchievements(),
              const SizedBox(height: 20),
              _buildPreferences(),
              const SizedBox(height: 20),
              _buildSettingsList(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
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
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2A7C7C), Color(0xFF3A9C8C)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    'A',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Edit profile photo'),
                        backgroundColor: const Color(0xFF2A7C7C),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A7C7C),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.edit, color: Colors.white, size: 12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Alex Johnson',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A3A3A),
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'alex@focusflow.app',
                  style: TextStyle(fontSize: 13, color: Color(0xFF5A7A7A)),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF4F4),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '⚡ Pro Member',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2A7C7C),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    final stats = [
      {'label': 'Total Hours', 'value': '24h'},
      {'label': 'Streak', 'value': '5 days'},
      {'label': 'Sessions', 'value': '47'},
      {'label': 'Score', 'value': '78%'},
    ];

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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: stats.map((s) {
          return Column(
            children: [
              Text(
                s['value']!,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2A7C7C),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                s['label']!,
                style: const TextStyle(fontSize: 10, color: Color(0xFF5A7A7A)),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAchievements() {
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
            'Achievements',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A3A3A),
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1,
            children: _achievements.map((a) {
              final unlocked = a['unlocked'] as bool;
              return Container(
                decoration: BoxDecoration(
                  color: unlocked
                      ? const Color(0xFFEAF4F4)
                      : const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      a['icon'] as IconData,
                      color: unlocked
                          ? const Color(0xFF2A7C7C)
                          : const Color(0xFFCCCCCC),
                      size: 24,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      a['label'] as String,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: unlocked
                            ? const Color(0xFF2A7C7C)
                            : const Color(0xFFCCCCCC),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferences() {
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
            'Preferences',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A3A3A),
            ),
          ),
          const SizedBox(height: 14),
          _buildToggleRow(
            'Push Notifications',
            _notificationsEnabled,
                (val) => setState(() => _notificationsEnabled = val),
          ),
          _buildToggleRow(
            'Daily Reminders',
            _dailyRemindersEnabled,
                (val) => setState(() => _dailyRemindersEnabled = val),
          ),
          _buildToggleRow(
            'Dark Mode',
            _darkModeEnabled,
                (val) => setState(() => _darkModeEnabled = val),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleRow(
      String label,
      bool value,
      ValueChanged<bool> onChanged,
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: Color(0xFF1A3A3A)),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF2A7C7C),
            activeTrackColor: const Color(0xFF2A7C7C).withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsList() {
    return Container(
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
        children: List.generate(_settingsItems.length, (index) {
          final item = _settingsItems[index];
          final isLast = index == _settingsItems.length - 1;
          final isLogout = item['label'] == 'Log Out';
          return GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${item['label']} tapped'),
                  backgroundColor: const Color(0xFF2A7C7C),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                border: !isLast
                    ? const Border(
                  bottom: BorderSide(
                    color: Color(0xFFF0F8F8),
                    width: 1,
                  ),
                )
                    : null,
              ),
              child: Row(
                children: [
                  Icon(
                    item['icon'] as IconData,
                    color: isLogout
                        ? const Color(0xFFDD4444)
                        : const Color(0xFF2A7C7C),
                    size: 20,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      item['label'] as String,
                      style: TextStyle(
                        fontSize: 14,
                        color: isLogout
                            ? const Color(0xFFDD4444)
                            : const Color(0xFF1A3A3A),
                      ),
                    ),
                  ),
                  if (!isLogout)
                    const Icon(
                      Icons.chevron_right,
                      color: Color(0xFF5A7A7A),
                      size: 18,
                    ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}