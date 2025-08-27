import 'package:edu_one/screens/admin/course_details_page.dart';
import 'package:flutter/material.dart';

import '../../widgets/custom_text_form_field.dart';

class PageCourses extends StatelessWidget {
  PageCourses({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Courses',
          style: textTheme.headlineLarge!.copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: colorScheme.onSurface),
            onPressed: () {
              // Navigate to a new page to add a course
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Add Course functionality coming soon'),
                ),
              );
            },
          ),
          const SizedBox(width: 16.0),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Search Field
              CustomTextFormField(
                textController: TextEditingController(),
                hint: 'Search courses by title or staff',
                validator: (value) => null, // No validation needed for search
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 24.0),

              // Course List (using a mock list for demonstration)
              Expanded(
                child: ListView.builder(
                  itemCount: _mockCourses.length,
                  itemBuilder: (context, index) {
                    final course = _mockCourses[index];
                    return _buildCourseCard(context, course);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCourseCard(BuildContext context, Map<String, dynamic> course) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: () {
        // Navigate to the CourseDetailsPage
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CourseDetailsPage(course: course,),
          ),
        );
      },
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
          side: BorderSide(
            color: colorScheme.outlineVariant,
            width: 1.0,
          ),
        ),
        margin: const EdgeInsets.only(bottom: 16.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course['title']!,
                      style: textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      'Assigned Staff: ${course['staff']!}',
                      style: textTheme.labelSmall!.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      // Edit functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Editing ${course['title']}')),
                      );
                    },
                    icon: Icon(Icons.edit_outlined, color: colorScheme.primary),
                  ),
                  IconButton(
                    onPressed: () {
                      // Delete functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Deleting ${course['title']}')),
                      );
                    },
                    icon: Icon(Icons.delete_outline, color: colorScheme.error),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Mock data for demonstration purposes
  final List<Map<String, dynamic>> _mockCourses = [
    {'title': 'Introduction to Flutter', 'staff': 'Jane Smith'},
    {'title': 'Database Management Systems', 'staff': 'John Doe'},
    {'title': 'Advanced Python Programming', 'staff': 'Mark Johnson'},
    {'title': 'Mobile UI/UX Design', 'staff': 'Sarah Lee'},
  ];
}
