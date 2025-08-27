import 'package:flutter/material.dart';

import '../../widgets/custom_text_form_field.dart';
import 'add_edit_assignment_page.dart';

class PageAssignments extends StatelessWidget {
  PageAssignments({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Assignments',
          style: textTheme.headlineLarge!.copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: colorScheme.onSurface),
            onPressed: () {
              // Navigate to the AddEditAssignmentPage to add a new assignment
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddEditAssignmentPage(),
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
                hint: 'Search assignments by title or course',
                validator: (value) => null, // No validation needed for search
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 24.0),

              // Assignment List (using a mock list for demonstration)
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
      child: InkWell(
        onTap: () {
          // Navigate to a details page or show a dialog
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Tapped on ${assignment['title']}')),
          );
        },
        borderRadius: BorderRadius.circular(12.0),
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
                      'Course: ${assignment['course']!}',
                      style: textTheme.labelSmall!.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      'Due Date: ${assignment['dueDate']!}',
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
                      // Navigate to the AddEditAssignmentPage to edit the assignment
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  AddEditAssignmentPage(assignment: assignment),
                        ),
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
      ),
    );
  }

  // Mock data for demonstration purposes
  final List<Map<String, dynamic>> _mockAssignments = [
    {
      'title': 'Module 1 Quiz',
      'course': 'Introduction to Flutter',
      'dueDate': '2025-09-01',
    },
    {
      'title': 'Homework 2',
      'course': 'Dart Programming Basics',
      'dueDate': '2025-09-05',
    },
    {
      'title': 'Final Project Proposal',
      'course': 'Advanced UI/UX Design',
      'dueDate': '2025-09-10',
    },
  ];
}
