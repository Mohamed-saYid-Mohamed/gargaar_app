import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gargaar_app/core/localization/language_provider.dart';
import 'package:gargaar_app/features/notifications/presentation/notifications_screen.dart';

import '../home/presentation/home_screen.dart';
import '../records/presentation/records_shell_screen.dart';
import '../profile/presentation/profile_screen.dart';

class BottomNavShell extends ConsumerStatefulWidget {
  const BottomNavShell({super.key});

  @override
  ConsumerState<BottomNavShell> createState() => _BottomNavShellState();
}

class _BottomNavShellState extends ConsumerState<BottomNavShell> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = const [
      HomeScreen(),
      RecordsShellScreen(),
      ProfileScreen(),
      NotificationsScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(languageProvider.notifier).strings;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBody: true, // Content flows behind the glass bar
      body: _pages[_currentIndex],
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Container(
            height: 70,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(35),
              boxShadow: [
                BoxShadow(
                  color: (isDark ? Colors.black : Colors.blue.shade900).withValues(alpha: 0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(35),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: (isDark ? Colors.grey.shade900 : Colors.white).withValues(alpha: isDark ? 0.7 : 0.8),
                    borderRadius: BorderRadius.circular(35),
                    border: Border.all(
                      color: (isDark ? Colors.white : Colors.blue.shade100).withValues(alpha: 0.2),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNavItem(0, Icons.home_rounded, strings['home'] ?? 'Home'),
                      _buildNavItem(1, Icons.history_rounded, strings['records'] ?? 'Reports'),
                      _buildNavItem(2, Icons.person_rounded, strings['profile'] ?? 'Profile'),
                      _buildNavItem(3, Icons.notifications_rounded, strings['notifications'] ?? 'Alerts'),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    const activeColor = Color(0xFF4189DD);

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _currentIndex = index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? activeColor.withValues(alpha: 0.1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  icon,
                  color: isSelected ? activeColor : Colors.grey.shade500,
                  size: isSelected ? 28 : 24,
                ),
              ),
              if (isSelected)
                const SizedBox(height: 2),
              if (isSelected)
                Text(
                  label,
                  style: TextStyle(
                    color: activeColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
