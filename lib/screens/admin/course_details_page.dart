import 'package:flutter/material.dart';
import 'manage_assignments_page.dart';
import 'manage_enrollments_page.dart';

class CourseDetailsPage extends StatelessWidget {
  final Map<String, dynamic> course;

  const CourseDetailsPage({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Course Details',
          style: textTheme.headlineMedium!.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Course Information Section
              Text(
                course['title']!,
                style: textTheme.headlineLarge!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                'This course is taught by ${course['staff']} and covers topics in ${course['title']}.',
                style: textTheme.labelSmall!.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32.0),

              // Management Cards
              _buildManagementCard(
                context: context,
                title: 'Manage Enrollments',
                description:
                    'View and manage students enrolled in this course.',
                icon: Icons.people_alt_outlined,
                onTap: () {
                  // Navigate to the Manage Enrollments Page and pass the course data
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => ManageEnrollmentsPage(course: course),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16.0),
              _buildManagementCard(
                context: context,
                title: 'Manage Assignments',
                description: 'Add, edit, and view assignments for this course.',
                icon: Icons.assignment_outlined,
                onTap: () {
                  // Navigate to the Manage Assignments Page and pass the course data
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => ManageAssignmentsPage(course: course),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildManagementCard({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
          side: BorderSide(color: colorScheme.outlineVariant, width: 1.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, size: 36, color: colorScheme.primary),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      description,
                      style: textTheme.labelSmall!.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}
