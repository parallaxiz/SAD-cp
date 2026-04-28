import 'package:flutter/material.dart';

class CoFocusTab extends StatefulWidget {
  const CoFocusTab({super.key});

  @override
  State<CoFocusTab> createState() => _CoFocusTabState();
}

class _CoFocusTabState extends State<CoFocusTab> {
  final List<Map<String, dynamic>> _activeSessions = [
    {
      'title': 'Deep Work Hour',
      'host': 'Sarah M.',
      'participants': 12,
      'startsIn': '30 min',
      'type': 'Group',
      'isLive': false,
    },
    {
      'title': 'Morning Clarity',
      'host': 'James T.',
      'participants': 7,
      'startsIn': 'Live now',
      'type': 'Open',
      'isLive': true,
    },
    {
      'title': 'Writing Sprint',
      'host': 'Priya K.',
      'participants': 3,
      'startsIn': '1 hr',
      'type': 'Private',
      'isLive': false,
    },
    {
      'title': 'Code & Focus',
      'host': 'Leo B.',
      'participants': 18,
      'startsIn': 'Live now',
      'type': 'Group',
      'isLive': true,
    },
  ];

  final List<Map<String, dynamic>> _friends = [
    {'name': 'Sarah M.', 'status': 'Focusing', 'streak': 8},
    {'name': 'James T.', 'status': 'Online', 'streak': 3},
    {'name': 'Priya K.', 'status': 'Focusing', 'streak': 15},
    {'name': 'Leo B.', 'status': 'Offline', 'streak': 1},
  ];

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
              _buildCreateSessionButton(),
              const SizedBox(height: 20),
              _buildSectionTitle('Active Sessions', textColor),
              const SizedBox(height: 12),
              ..._activeSessions.map((s) => _buildSessionCard(s, cardColor, textColor, subTextColor, scaffoldBg)).toList(),
              const SizedBox(height: 20),
              _buildSectionTitle('Friends', textColor),
              const SizedBox(height: 12),
              _buildFriendsList(cardColor, textColor, subTextColor, scaffoldBg),
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
          'Co-Focus',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Focus better together',
          style: TextStyle(fontSize: 13, color: subTextColor),
        ),
      ],
    );
  }

  Widget _buildCreateSessionButton() {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Creating new session...'),
            backgroundColor: const Color(0xFF2A7C7C),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2A7C7C), Color(0xFF3A9C8C)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2A7C7C).withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text(
              'Create New Session',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
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

  Widget _buildSessionCard(Map<String, dynamic> session, Color cardColor, Color textColor, Color subTextColor, Color scaffoldBg) {
    final isLive = session['isLive'] as bool;
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  session['title'] as String,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isLive
                      ? const Color(0xFFFF4444).withOpacity(0.12)
                      : scaffoldBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isLive)
                      Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.only(right: 4),
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF4444),
                          shape: BoxShape.circle,
                        ),
                      ),
                    Text(
                      session['startsIn'] as String,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isLive
                            ? const Color(0xFFFF4444)
                            : const Color(0xFF2A7C7C),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.person_outline, size: 14, color: subTextColor),
              const SizedBox(width: 4),
              Text(
                'Host: ${session['host']}',
                style: TextStyle(fontSize: 12, color: subTextColor),
              ),
              const SizedBox(width: 14),
              Icon(Icons.group_outlined, size: 14, color: subTextColor),
              const SizedBox(width: 4),
              Text(
                '${session['participants']} joined',
                style: TextStyle(fontSize: 12, color: subTextColor),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Joining "${session['title']}"! 🚀'),
                      backgroundColor: const Color(0xFF2A7C7C),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A7C7C),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'Join',
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

  Widget _buildFriendsList(Color cardColor, Color textColor, Color subTextColor, Color scaffoldBg) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: List.generate(_friends.length, (index) {
          final friend = _friends[index];
          final isFocusing = friend['status'] == 'Focusing';
          final isOnline = friend['status'] == 'Online';
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              border: index < _friends.length - 1
                  ? Border(
                bottom: BorderSide(color: scaffoldBg, width: 1),
              )
                  : null,
            ),
            child: Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: scaffoldBg,
                      child: Text(
                        friend['name'].toString().substring(0, 1),
                        style: const TextStyle(
                          color: Color(0xFF2A7C7C),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: isFocusing
                              ? const Color(0xFF2A7C7C)
                              : isOnline
                              ? const Color(0xFF44BB44)
                              : const Color(0xFFCCCCCC),
                          shape: BoxShape.circle,
                          border: Border.all(color: cardColor, width: 1.5),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        friend['name'] as String,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      Text(
                        friend['status'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          color: isFocusing
                              ? const Color(0xFF2A7C7C)
                              : subTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.local_fire_department, size: 14, color: Color(0xFFFF8844)),
                    const SizedBox(width: 2),
                    Text(
                      '${friend['streak']}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
