import 'package:edu_one/models/course_model.dart';
import 'package:flutter/material.dart';

class ManageAssignmentsPage extends StatelessWidget {
  final CourseModel course;

  ManageAssignmentsPage({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Manage Assignments',
          style: textTheme.headlineMedium!.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: colorScheme.onSurface),
            onPressed: () {
              // Navigate to a new page to add a new assignment
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Add assignment functionality coming soon'),
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
              const SizedBox(height: 24.0),

              // Assignments List (using a mock list for demonstration)
              Expanded(
                child: ListView.builder(
                  itemCount: _mockAssignments.length,
                  itemBuilder: (context, index) {
                    final assignment = _mockAssignments[index];
                    return _buildAssignmentCard(context, assignment);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAssignmentCard(
    BuildContext context,
    Map<String, dynamic> assignment,
  ) {
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
                    assignment['title']!,
                    style: textTheme.bodyMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    'Due: ${assignment['dueDate']!}',
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
                      SnackBar(content: Text('Editing ${assignment['title']}')),
                    );
                  },
                  icon: Icon(Icons.edit_outlined, color: colorScheme.primary),
                ),
                IconButton(
                  onPressed: () {
                    // Delete functionality
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Deleting ${assignment['title']}'),
                      ),
                    );
                  },
                  icon: Icon(Icons.delete_outline, color: colorScheme.error),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Mock data for demonstration purposes
  final List<Map<String, dynamic>> _mockAssignments = [
    {'title': 'Homework 1: Flutter Basics', 'dueDate': 'October 25, 2025'},
    {'title': 'Midterm Project: App Design', 'dueDate': 'November 15, 2025'},
    {
      'title': 'Final Project: Final Presentation',
      'dueDate': 'December 10, 2025',
    },
  ];
}
