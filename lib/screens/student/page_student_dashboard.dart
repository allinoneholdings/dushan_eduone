import 'package:edu_one/models/course_model.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:edu_one/screens/admin/user_account_page.dart';
import 'package:edu_one/widgets/custom_text_form_field.dart';
import 'package:edu_one/services/firestore_service.dart';

/// A mock version of the AssignmentModel to ensure the code is self-contained.
class AssignmentModel {
  final String? id;
  final String title;
  final String? courseId;
  final String? description;
  final Timestamp? dueDate;

  AssignmentModel({
    this.id,
    required this.title,
    this.courseId,
    this.description,
    this.dueDate,
  });
}

/// A mock version of the CustomStatusCard to ensure the code is self-contained.
class CustomStatusCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color containerColor;

  const CustomStatusCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.containerColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: containerColor,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 32, color: colorScheme.onBackground),
            const SizedBox(height: 12.0),
            Text(
              value,
              style: textTheme.headlineMedium!.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 4.0),
            Text(
              title,
              style: textTheme.bodySmall!.copyWith(
                color: colorScheme.onBackground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The main dashboard page for a student.
class PageStudentDashboard extends StatelessWidget {
  const PageStudentDashboard({super.key});

  /// Builds the row of status cards (enrolled courses, total assignments, completed assignments).
  Widget _buildStatusCards(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final firestoreService = FirestoreService();
    final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return Row(
      children: [
        // Total Enrolled Courses
        Expanded(
          child: StreamBuilder<int>(
            // StreamBuilder listens to the stream and rebuilds the widget whenever new data is emitted.
            stream: firestoreService.getEnrolledCoursesCount(currentUserId),
            builder: (context, snapshot) {
              final int count = snapshot.data ?? 0;
              return CustomStatusCard(
                title: 'Enrolled Courses',
                value: count.toString(),
                icon: Icons.school,
                containerColor: colorScheme.primaryContainer,
              );
            },
          ),
        ),
        const SizedBox(width: 16.0),

        // Total Assignments
        Expanded(
          child: StreamBuilder<int>(
            stream: firestoreService.getTotalAssignmentsCount(currentUserId),
            builder: (context, snapshot) {
              final int count = snapshot.data ?? 0;
              return CustomStatusCard(
                title: 'Total Assignments',
                value: count.toString(),
                icon: Icons.assignment,
                containerColor: colorScheme.secondaryContainer,
              );
            },
          ),
        ),
        const SizedBox(width: 16.0),

        // Completed Assignments
        Expanded(
          child: StreamBuilder<int>(
            stream: firestoreService.getCompletedAssignmentsCount(
              currentUserId,
            ),
            builder: (context, snapshot) {
              final int count = snapshot.data ?? 0;
              return CustomStatusCard(
                title: 'Completed',
                value: count.toString(),
                icon: Icons.check_circle_outline,
                containerColor: colorScheme.tertiaryContainer,
              );
            },
          ),
        ),
      ],
    );
  }

  /// Builds the list of top courses.
  Widget _buildTopCoursesList(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final firestoreService = FirestoreService();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Top Courses',
          style: textTheme.headlineLarge!.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16.0),
        StreamBuilder<List<CourseModel>>(
          stream: firestoreService.getTop5Courses(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (!snapshot.hasData) {
              return const Center(child: Text('No courses found.'));
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final course = snapshot.data![index];
                final courseName = course.name;
                final courseCode = course.description;
                return Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    side: BorderSide(
                      color: colorScheme.outlineVariant,
                      width: 1.0,
                    ),
                  ),
                  margin: const EdgeInsets.only(bottom: 12.0),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: colorScheme.primary,
                      child: Text(
                        courseName[0].toUpperCase(),
                        style: textTheme.bodyMedium!.copyWith(
                          color: colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      courseName,
                      style: textTheme.bodyLarge!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    subtitle: Text(
                      courseCode,
                      style: textTheme.labelSmall!.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.person, color: colorScheme.onSurface),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const UserAccountPage(),
                ),
              );
            },
          ),
          const SizedBox(width: 16.0),
        ],
        title: RichText(
          text: TextSpan(
            style: textTheme.headlineLarge,
            children: <TextSpan>[
              TextSpan(
                text: 'Edu',
                style: TextStyle(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: 'One',
                style: TextStyle(
                  color: colorScheme.secondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Use StreamBuilder to get the logged-in user's name
              StreamBuilder<User?>(
                stream: FirebaseAuth.instance.authStateChanges(),
                builder: (context, snapshot) {
                  String userName = 'Student';
                  if (snapshot.data != null &&
                      snapshot.data!.displayName != null) {
                    final fullName = snapshot.data!.displayName!;
                    if (fullName.contains(' ')) {
                      userName = fullName.split(' ')[0];
                    } else {
                      userName = fullName;
                    }
                  }
                  return Text(
                    'Welcome, $userName!',
                    style: textTheme.headlineLarge!.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
              const SizedBox(height: 8.0),
              Text(
                'Here is a quick overview of your progress.',
                style: textTheme.bodyMedium!.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32.0),

              // Student Status Section
              _buildStatusCards(context),
              const SizedBox(height: 32.0),

              // Top Courses List
              _buildTopCoursesList(context),
            ],
          ),
        ),
      ),
    );
  }
}
