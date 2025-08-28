import 'package:edu_one/models/course_model.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import '../assignments/manage_assignments_page.dart';
import '../enrollments/manage_enrollments_page.dart';
import 'package:edu_one/models/user_model.dart'; // Import UserModel

class CourseDetailsPage extends StatefulWidget {
  final CourseModel course;

  const CourseDetailsPage({super.key, required this.course});

  @override
  State<CourseDetailsPage> createState() => _CourseDetailsPageState();
}

class _CourseDetailsPageState extends State<CourseDetailsPage> {
  // A future to hold the instructor's name, which will be fetched from Firestore
  late Future<String> _instructorNameFuture;

  @override
  void initState() {
    super.initState();
    // Initialize the future when the widget is created
    _instructorNameFuture = _fetchInstructorName();
  }

  /// Fetches the instructor's name from Firestore using their ID.
  Future<String> _fetchInstructorName() async {
    try {
      // Get the document snapshot for the instructor using their ID
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.course.instructor)
          .get();

      // Check if the document exists and has a name
      if (userDoc.exists && userDoc.data() != null) {
        // Create a UserModel from the document and return the name
        final user = UserModel.fromDocument(userDoc);
        return user.name;
      } else {
        return 'Unknown Instructor';
      }
    } catch (e) {
      // Handle any errors during the fetch
      print('Error fetching instructor name: $e');
      return 'Error fetching name';
    }
  }

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
                widget.course.name,
                style: textTheme.headlineLarge!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8.0),

              // Use a FutureBuilder to display the instructor's name
              FutureBuilder<String>(
                future: _instructorNameFuture,
                builder: (context, snapshot) {
                  String instructorName = '';
                  // Check the state of the future
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    instructorName = 'Loading...';
                  } else if (snapshot.hasError) {
                    instructorName = 'Error';
                  } else if (snapshot.hasData) {
                    instructorName = snapshot.data!;
                  } else {
                    instructorName = 'Unknown Instructor';
                  }

                  // Use RichText to highlight the instructor's name
                  return RichText(
                    text: TextSpan(
                      style: textTheme.labelSmall!.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      children: [
                        const TextSpan(text: 'This course is taught by '),
                        TextSpan(
                          text: instructorName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary, // or any color you prefer
                          ),
                        ),
                        TextSpan(text: ' and covers topics in ${widget.course.name}.'),
                      ],
                    ),
                  );
                },
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
                          (context) => ManageEnrollmentsPage(course: widget.course),
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
                          (context) => ManageAssignmentsPage(course: widget.course),
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
