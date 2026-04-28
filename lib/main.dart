import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'home/data_manager.dart';

// Import all 6 tab files
import 'home/home_tab.dart';
import 'training/train_tab.dart';
import 'analyze_tab.dart';
import 'co_focus_tab.dart';
import 'recovery/recover_tab.dart';
import 'profile_tab.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize DataManager to load saved sessions
  await DataManager.init();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const FocusFlowApp());
}

class FocusFlowApp extends StatelessWidget {
  const FocusFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: DataManager.isDarkMode,
      builder: (context, isDark, child) {
        return MaterialApp(
          title: 'FocusFlow',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: const Color(0xFF2A7C7C),
            brightness: Brightness.light,
            scaffoldBackgroundColor: const Color(0xFFEAF4F4),
            fontFamily: 'SF Pro Display',
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: const Color(0xFF2A7C7C),
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF121212),
            fontFamily: 'SF Pro Display',
          ),
          themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
          home: const MainShell(),
        );
      }
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  // All 6 tab pages — instantiated once and kept alive
  static const List<Widget> _pages = [
    HomeTab(),
    TrainTab(),
    AnalyzeTab(),
    CoFocusTab(),
    RecoverTab(),
    ProfileTab(),
  ];

  final List<_NavItem> _navItems = const [
    _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Home'),
    _NavItem(icon: Icons.track_changes_outlined, activeIcon: Icons.track_changes, label: 'Train'),
    _NavItem(icon: Icons.show_chart_outlined, activeIcon: Icons.show_chart, label: 'Analyze'),
    _NavItem(icon: Icons.people_outline, activeIcon: Icons.people, label: 'Co-Focus'),
    _NavItem(icon: Icons.refresh_outlined, activeIcon: Icons.refresh, label: 'Recover'),
    _NavItem(icon: Icons.person_outline, activeIcon: Icons.person, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_navItems.length, (index) {
              final item = _navItems[index];
              final isSelected = _currentIndex == index;
              return GestureDetector(
                onTap: () => setState(() => _currentIndex = index),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        transitionBuilder: (child, animation) =>
                            ScaleTransition(scale: animation, child: child),
                        child: Icon(
                          isSelected ? item.activeIcon : item.icon,
                          key: ValueKey(isSelected),
                          color: isSelected
                              ? const Color(0xFF2A7C7C)
                              : const Color(0xFFAABBBB),
                          size: 22,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.normal,
                          color: isSelected
                              ? const Color(0xFF2A7C7C)
                              : const Color(0xFFAABBBB),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
