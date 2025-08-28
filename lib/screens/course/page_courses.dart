import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../models/course_model.dart';
import '../../../services/firestore_service.dart';
import '../../../widgets/custom_text_form_field.dart';
import '../../../widgets/custom_popup_box.dart';
import 'add_edit_course_page.dart';
import 'course_details_page.dart';
import '../../../models/user_model.dart';

class PageCourses extends StatelessWidget {
  const PageCourses({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      // If no user is logged in, show a message.
      return const Scaffold(
        body: Center(child: Text('Please log in to view courses.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Courses',
          style: textTheme.headlineLarge!.copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          // Use a StreamBuilder to conditionally show the add button
          StreamBuilder<UserModel?>(
            stream: FirestoreService().getUser(currentUser.uid),
            builder: (context, snapshot) {
              final bool isAdmin = snapshot.data?.role == 'Admin';

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

              // StreamBuilder to check user role and fetch appropriate courses
              Expanded(
                child: StreamBuilder<UserModel?>(
                  stream: FirestoreService().getUser(currentUser.uid),
                  builder: (context, userSnapshot) {
                    if (userSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (userSnapshot.hasError) {
                      return Center(
                        child: Text('Error: ${userSnapshot.error}'),
                      );
                    }

                    final UserModel? user = userSnapshot.data;
                    final bool isAdmin = user?.role == 'Admin';
                    final bool isStudent = user?.role == 'Student';
                    final bool isStaff = user?.role == 'Staff';

                    if (user == null) {
                      return const Center(child: Text('User data not found.'));
                    }

                    // Use a nested StreamBuilder to fetch courses based on the user's role
                    return StreamBuilder<List<CourseModel>>(
                      stream:
                          isAdmin
                              ? FirestoreService().getCourses()
                              : isStudent
                              ? FirestoreService().getEnrolledCourses(
                                currentUser.uid,
                              )
                              : Stream.value(
                                [],
                              ), // Return an empty stream if not admin or student
                      builder: (context, coursesSnapshot) {
                        if (coursesSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (coursesSnapshot.hasError) {
                          return Center(
                            child: Text('Error: ${coursesSnapshot.error}'),
                          );
                        }

                        final courses = coursesSnapshot.data ?? [];

                        if (courses.isEmpty) {
                          return Center(
                            child: Text(
                              isStudent
                                  ? 'You are not enrolled in any courses.'
                                  : 'No courses found.',
                            ),
                          );
                        }

                        // Display the list of courses from Firestore
                        return ListView.builder(
                          itemCount: courses.length,
                          itemBuilder: (context, index) {
                            final course = courses[index];
                            return _buildCourseCard(
                              context,
                              course,
                              isAdmin,
                              isStaff,
                              isStudent,
                            );
                          },
                        );
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

  Widget _buildCourseCard(
    BuildContext context,
    CourseModel course,
    bool isAdmin,
    bool isStaff,
    bool isStudent,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    bool isTappable = !isStaff; // Only disable for Staff
    isTappable = !isStudent;

    return GestureDetector(
      onTap:
          isTappable
              ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CourseDetailsPage(course: course),
                  ),
                );
              }
              : null, // Set onTap to null to disable clicks
      child: Card(
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
                      course.name,
                      style: textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    // Use a FutureBuilder to get the instructor's name
                    FutureBuilder<String?>(
                      // Use the new function that returns a single String
                      future: FirestoreService().getInstructorName(
                        course.instructor,
                      ),
                      builder: (context, snapshot) {
                        String instructorName = 'Unknown Instructor';
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          instructorName = 'Loading...';
                        } else if (snapshot.hasData && snapshot.data != null) {
                          // The snapshot data is now the name directly
                          instructorName = snapshot.data!;
                        } else if (snapshot.hasError) {
                          instructorName = 'Error';
                          // It's good practice to log the error for debugging
                          debugPrint(
                            'Error fetching instructor name: ${snapshot.error}',
                          );
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
              // Conditionally show edit and delete buttons for admins
              if (isAdmin)
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        // Navigate to the AddEditCoursePage to edit the course
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => AddEditCoursePage(course: course),
                          ),
                        );
                      },
                      icon: Icon(
                        Icons.edit_outlined,
                        color: colorScheme.primary,
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        // Use the CustomPopupBox for confirmation
                        final bool confirmDelete =
                            await showDialog(
                              context: context,
                              builder:
                                  (context) => CustomPopupBox(
                                    title: 'Confirm Deletion',
                                    content: Text(
                                      'Are you sure you want to delete "${course.name}"? This action cannot be undone.',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed:
                                            () => Navigator.of(
                                              context,
                                            ).pop(false),
                                        child: const Text('Cancel'),
                                      ),
                                      FilledButton(
                                        onPressed:
                                            () =>
                                                Navigator.of(context).pop(true),
                                        style: FilledButton.styleFrom(
                                          backgroundColor: colorScheme.error,
                                        ),
                                        child: const Text('Delete'),
                                      ),
                                    ],
                                  ),
                            ) ??
                            false;

                        if (confirmDelete) {
                          await FirestoreService().deleteCourse(course.id);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Deleted ${course.name}')),
                            );
                          }
                        }
                      },
                      icon: Icon(
                        Icons.delete_outline,
                        color: colorScheme.error,
                      ),
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
