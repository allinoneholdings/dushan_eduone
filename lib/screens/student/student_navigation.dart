import 'package:edu_one/screens/admin/page_admin_dashboard.dart';
import 'package:edu_one/screens/admin/assignments/page_assignments.dart';
import 'package:edu_one/screens/admin/course/page_courses.dart';
import 'package:edu_one/screens/admin/users/page_users.dart';
import 'package:edu_one/screens/student/page_student_dashboard.dart';
import 'package:edu_one/widgets/student_bottom_nav_bar.dart';
import 'package:flutter/material.dart';

import '../../widgets/admin_bottom_nav_bar.dart';

class StudentNavigation extends StatefulWidget {
  const StudentNavigation({super.key});

  @override
  State<StudentNavigation> createState() => _StudentNavigationState();
}

class _StudentNavigationState extends State<StudentNavigation> {
  int _currentIndex = 0;

  //pages for bottom navigation bar
  final List<Widget> _pages = [
    const PageStudentDashboard(),
    PageCourses(),
    PageAssignments()
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
      bottomNavigationBar: StudentBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
