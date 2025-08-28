import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../models/course_model.dart';
import '../../../services/firestore_service.dart';
import '../../../widgets/custom_text_form_field.dart';
import '../../../widgets/custom_popup_box.dart'; // Import your reusable widget
import 'add_edit_course_page.dart';
import 'course_details_page.dart';
import '../../../models/user_model.dart'; // Import UserModel

class PageCourses extends StatelessWidget {
  const PageCourses({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final User? currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Courses',
          style: textTheme.headlineLarge!.copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          // Use a StreamBuilder to conditionally show the add button
          StreamBuilder<bool>(
            stream: FirestoreService().isUserAdmin(currentUser?.uid),
            builder: (context, snapshot) {
              final bool isAdmin = snapshot.data ?? false;

              if (isAdmin) {
                return IconButton(
                  icon: Icon(Icons.add, color: colorScheme.onSurface),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddEditCoursePage(),
                      ),
                    );
                  },
                );
              } else {
                // Return an empty widget if the user is not an admin
                return const SizedBox(width: 16.0);
              }
            },
          ),
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
                    // Use a FutureBuilder to get the instructor's name
                    FutureBuilder<UserModel?>(
                      future: FirestoreService().getUser(course.instructor),
                      builder: (context, snapshot) {
                        String instructorName = 'Unknown Instructor';
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          instructorName = 'Loading...';
                        } else if (snapshot.hasData && snapshot.data != null) {
                          instructorName = snapshot.data!.name;
                        } else if (snapshot.hasError) {
                          instructorName = 'Error';
                        }

                        return Text(
                          'Instructor: $instructorName',
                          style: textTheme.labelSmall!.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        );
                      },
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
                          builder: (context) => AddEditCoursePage(course: course),
                        ),
                      );
                    },
                    icon: Icon(Icons.edit_outlined, color: colorScheme.primary),
                  ),
                  IconButton(
                    onPressed: () async {
                      // Use the CustomPopupBox for confirmation
                      final bool confirmDelete = await showDialog(
                        context: context,
                        builder: (context) => CustomPopupBox(
                          title: 'Confirm Deletion',
                          content: Text(
                              'Are you sure you want to delete "${course.name}"? This action cannot be undone.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('Cancel'),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              style: FilledButton.styleFrom(
                                backgroundColor: colorScheme.error,
                              ),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      ) ?? false; // Default to false if the dialog is dismissed

                      if (confirmDelete) {
                        await FirestoreService().deleteCourse(course.id);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Deleted ${course.name}')),
                          );
                        }
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
