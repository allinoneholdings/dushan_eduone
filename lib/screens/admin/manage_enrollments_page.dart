import 'package:edu_one/models/course_model.dart';
import 'package:flutter/material.dart';
import '../../widgets/custom_text_form_field.dart';

class ManageEnrollmentsPage extends StatelessWidget {
  final CourseModel course;

  ManageEnrollmentsPage({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Manage Enrollments',
          style: textTheme.headlineMedium!.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.person_add, color: colorScheme.onSurface),
            onPressed: () {
              // Navigate to a new page to add a student to the course
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Add student functionality coming soon'),
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
              // Course Title for context
              Text(
                'Course: ${course.name}',
                style: textTheme.bodyMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16.0),

              // Search Field
              CustomTextFormField(
                textController: TextEditingController(),
                hint: 'Search enrolled students',
                validator: (value) => null,
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 24.0),

              // Enrolled Students List (using a mock list for demonstration)
              Expanded(
                child: ListView.builder(
                  itemCount: _mockStudents.length,
                  itemBuilder: (context, index) {
                    final student = _mockStudents[index];
                    return _buildStudentCard(context, student);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStudentCard(BuildContext context, Map<String, dynamic> student) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(color: colorScheme.outlineVariant, width: 1.0),
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
                    student['name']!,
                    style: textTheme.bodyMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    student['email']!,
                    style: textTheme.labelSmall!.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                // Remove student functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Removing ${student['name']}')),
                );
              },
              icon: Icon(
                Icons.person_remove_outlined,
                color: colorScheme.error,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Mock data for demonstration purposes
  final List<Map<String, dynamic>> _mockStudents = [
    {'name': 'John Doe', 'email': 'john.doe@example.com'},
    {'name': 'Jane Smith', 'email': 'jane.smith@example.com'},
    {'name': 'Mark Johnson', 'email': 'mark.j@example.com'},
    {'name': 'Sarah Lee', 'email': 'sarah.lee@example.com'},
  ];
}
