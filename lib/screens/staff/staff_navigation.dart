import 'package:edu_one/screens/admin/page_admin_dashboard.dart';
import 'package:flutter/material.dart';

import '../../widgets/admin_bottom_nav_bar.dart';
import '../assignments/page_assignments.dart';
import '../course/page_courses.dart';
import '../users/page_users.dart';

class StaffNavigation extends StatefulWidget {
  const StaffNavigation({super.key});

  @override
  State<StaffNavigation> createState() => _StaffNavigationState();
}

class _StaffNavigationState extends State<StaffNavigation> {
  int _currentIndex = 0;

  //pages for bottom navigation bar
  final List<Widget> _pages = [
    const PageAdminDashboard(),
    PageUsers(),
    PageCourses(),
    PageAssignments(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The body of the Scaffold will show the page at the current index
      body: _pages[_currentIndex],
      bottomNavigationBar: AdminBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
