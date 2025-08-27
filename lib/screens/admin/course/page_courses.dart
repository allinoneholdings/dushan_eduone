import 'package:flutter/material.dart';
import '../../../models/course_model.dart';
import '../../../services/firestore_service.dart';
import '../../../widgets/custom_text_form_field.dart';
import 'add_edit_course_page.dart';
import 'course_details_page.dart';

class PageCourses extends StatelessWidget {
  const PageCourses({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Manage Courses',
          style: textTheme.headlineLarge!.copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: colorScheme.onSurface),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddEditCoursePage(),
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
                hint: 'Search courses by name or instructor',
                validator: (value) => null,
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 24.0),

              // Use a StreamBuilder to listen for real-time data from Firestore
              Expanded(
                child: StreamBuilder<List<CourseModel>>(
                  stream: FirestoreService().getCourses(),
                  builder: (context, snapshot) {
                    // Show a loading indicator while data is being fetched
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    // Show an error message if something went wrong
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    // If there's no data, show a message
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No courses found.'));
                    }

                    // Display the list of courses from Firestore
                    final courses = snapshot.data!;
                    return ListView.builder(
                      itemCount: courses.length,
                      itemBuilder: (context, index) {
                        final course = courses[index];
                        return _buildCourseCard(context, course);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCourseCard(BuildContext context, CourseModel course) {
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
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CourseDetailsPage(course: course),
            ),
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
                      course.name,
                      style: textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      'Instructor: ${course.instructor}',
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
                      // Navigate to the AddEditCoursePage to edit the course
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  AddEditCoursePage(course: course.toMap()),
                        ),
                      );
                    },
                    icon: Icon(Icons.edit_outlined, color: colorScheme.primary),
                  ),
                  IconButton(
                    onPressed: () async {
                      // Delete functionality
                      await FirestoreService().deleteCourse(course.id);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Deleted ${course.name}')),
                        );
                      }
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
}
