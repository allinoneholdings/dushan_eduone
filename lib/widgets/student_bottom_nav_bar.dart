// lib/widgets/admin_bottom_nav_bar.dart

import 'package:flutter/material.dart';

class StudentBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const StudentBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      selectedItemColor: colorScheme.primary,
      unselectedItemColor: colorScheme.onSurfaceVariant,
      backgroundColor: colorScheme.surfaceContainer,
      showSelectedLabels: false,
      iconSize: 28.0,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_outlined),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.school_outlined),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.assignment_outlined),
          label: '',
        ),
      ],
    );
  }
}
