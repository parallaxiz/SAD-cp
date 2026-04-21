import 'package:flutter/material.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  // EDITABLE INFORMATION
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  bool _isEditing = false;

  // APP PREFERENCES
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  // Note: _dailyRemindersEnabled removed because it was unused

  // REAL DATA PLACEHOLDERS
  final String _totalHours = "0.0h";
  final String _streak = "0 days";
  final String _sessions = "0";

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: 'Alex Johnson');
    _emailController = TextEditingController(text: 'alex@focusflow.app');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  final List<Map<String, dynamic>> _achievements = [
    {'icon': Icons.bolt, 'label': '7-Day Streak', 'unlocked': false},
    {'icon': Icons.star, 'label': 'First Hour', 'unlocked': false},
    {'icon': Icons.group, 'label': 'Co-Focus Pro', 'unlocked': false},
    {'icon': Icons.lock_outline, 'label': '30-Day Goal', 'unlocked': false},
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
              _buildLogoutButton(),
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
            color: Colors.teal.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: const Color(0xFF2A7C7C),
            child: Text(
              _nameController.text.isNotEmpty ? _nameController.text[0].toUpperCase() : '?',
              style: const TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _isEditing
                    ? TextField(
                  controller: _nameController,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  decoration: const InputDecoration(hintText: "Enter Name"),
                )
                    : Text(
                  _nameController.text,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                _isEditing
                    ? TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(hintText: "Enter Email"),
                )
                    : Text(
                  _emailController.text,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF5A7A7A)),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(_isEditing ? Icons.check : Icons.edit, color: const Color(0xFF2A7C7C)),
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
              });
            },
          )
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _statBox("Hours", _totalHours),
        _statBox("Streak", _streak),
        _statBox("Sessions", _sessions),
      ],
    );
  }

  Widget _statBox(String label, String value) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2A7C7C))),
          Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF5A7A7A))),
        ],
      ),
    );
  }

  Widget _buildAchievements() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Achievements", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 10),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _achievements.length,
            itemBuilder: (context, index) {
              final a = _achievements[index];
              return Container(
                width: 80,
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(a['icon'] as IconData, color: Colors.grey[300]),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPreferences() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          SwitchListTile(
            title: const Text("Push Notifications"),
            value: _notificationsEnabled,
            activeThumbColor: const Color(0xFF2A7C7C), // Fixed: used activeThumbColor
            onChanged: (val) => setState(() => _notificationsEnabled = val),
          ),
          SwitchListTile(
            title: const Text("Dark Mode"),
            value: _darkModeEnabled,
            activeThumbColor: const Color(0xFF2A7C7C), // Fixed: used activeThumbColor
            onChanged: (val) => setState(() => _darkModeEnabled = val),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: () {},
        child: const Text("Log Out", style: TextStyle(color: Colors.red)),
      ),
    );
  }
}