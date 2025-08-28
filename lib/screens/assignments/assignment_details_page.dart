import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edu_one/models/assignment_model.dart';
import 'package:edu_one/models/course_model.dart'; // Ensure you have this file
import 'package:edu_one/models/user_model.dart'; // Ensure you have this file

class AssignmentDetailsPage extends StatefulWidget {
  final AssignmentModel assignment;

  const AssignmentDetailsPage({super.key, required this.assignment});

  @override
  State<AssignmentDetailsPage> createState() => _AssignmentDetailsPageState();
}

class _AssignmentDetailsPageState extends State<AssignmentDetailsPage> {
  // Future to hold the course name and instructor name
  late Future<String> _courseNameFuture;
  late Future<String> _instructorNameFuture;

  @override
  void initState() {
    super.initState();
    // Initialize the futures when the widget is created
    _courseNameFuture = _fetchCourseName();
    _instructorNameFuture = _fetchInstructorName();
  }

  /// Fetches the course name from Firestore using the course ID.
  Future<String> _fetchCourseName() async {
    if (widget.assignment.courseId == null) {
      return 'N/A';
    }
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('courses')
          .doc(widget.assignment.courseId)
          .get();

      if (doc.exists && doc.data() != null) {
        final course = CourseModel.fromDocument(doc);
        return course.name ?? 'Unknown Course';
      }
      return 'Unknown Course';
    } catch (e) {
      print('Error fetching course name: $e');
      return 'Error fetching name';
    }
  }

  /// Fetches the instructor's name from Firestore by first getting the
  /// instructorId from the course document.
  Future<String> _fetchInstructorName() async {
    if (widget.assignment.courseId == null) {
      return 'N/A';
    }
    try {
      // Step 1: Get the course document to find the instructorId
      DocumentSnapshot courseDoc = await FirebaseFirestore.instance
          .collection('courses')
          .doc(widget.assignment.courseId)
          .get();

      if (!courseDoc.exists || courseDoc.data() == null) {
        return 'Unknown Instructor';
      }

      final course = CourseModel.fromDocument(courseDoc);
      final String? instructorId = course.instructor;

      if (instructorId == null) {
        return 'N/A';
      }

      // Step 2: Use the instructorId to get the user document
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(instructorId)
          .get();

      if (userDoc.exists && userDoc.data() != null) {
        final user = UserModel.fromDocument(userDoc);
        return user.name ?? 'Unknown Instructor';
      }
      return 'Unknown Instructor';
    } catch (e) {
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
          'Assignment Details',
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
              // Title
              Text(
                widget.assignment.title ?? 'No Title',
                style: textTheme.headlineLarge!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16.0),

              // Description
              Text(
                widget.assignment.description ?? 'No Description',
                style: textTheme.bodyLarge!.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24.0),

              // Details section
              _buildDetailItem(
                context,
                title: 'Due Date',
                value: widget.assignment.dueDate.day.toString() ?? 'N/A',
                icon: Icons.calendar_today_outlined,
              ),
              const SizedBox(height: 12.0),

              // Course Name
              FutureBuilder<String>(
                future: _courseNameFuture,
                builder: (context, snapshot) {
                  return _buildDetailItem(
                    context,
                    title: 'Course',
                    value: snapshot.data ?? 'Loading...',
                    icon: Icons.school_outlined,
                  );
                },
              ),
              const SizedBox(height: 12.0),

              // Assigned To (Instructor Name)
              FutureBuilder<String>(
                future: _instructorNameFuture,
                builder: (context, snapshot) {
                  return _buildDetailItem(
                    context,
                    title: 'Assigned By',
                    value: snapshot.data ?? 'Loading...',
                    icon: Icons.person_outline,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // A helper method to build the detail rows
  Widget _buildDetailItem(
      BuildContext context, {
        required String title,
        required String value,
        required IconData icon,
      }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Icon(icon, color: colorScheme.primary, size: 24),
        const SizedBox(width: 16.0),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: textTheme.labelSmall!.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4.0),
            Text(
              value,
              style: textTheme.bodyMedium!.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
