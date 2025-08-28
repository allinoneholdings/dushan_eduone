import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edu_one/models/course_model.dart';
import 'package:edu_one/widgets/custom_text_form_field.dart';

import 'add_edit_enrollment_page.dart';

class AdminItemCard extends StatelessWidget {
  final VoidCallback? onTap;
  final String title;
  final String subtitle;
  final Widget? trailing;

  const AdminItemCard({
    super.key,
    this.onTap,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(
          color: colorScheme.outlineVariant,
          width: 1.0,
        ),
      ),
      margin: const EdgeInsets.only(bottom: 16.0),
      child: InkWell(
        onTap: onTap,
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
                      title,
                      style: textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      subtitle,
                      style: textTheme.labelSmall!.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ),
    );
  }
}

class ManageEnrollmentsPage extends StatefulWidget {
  final CourseModel course;

  const ManageEnrollmentsPage({super.key, required this.course});

  @override
  State<ManageEnrollmentsPage> createState() => _ManageEnrollmentsPageState();
}

class _ManageEnrollmentsPageState extends State<ManageEnrollmentsPage> {
  // We don't need a search controller for this example, but it's good practice to have one
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // A helper function to fetch user details from the 'users' collection
  Future<DocumentSnapshot> _fetchUser(String userId) {
    return FirebaseFirestore.instance.collection('users').doc(userId).get();
  }

  // A helper function to remove a student enrollment
  Future<void> _removeEnrollment(String enrollmentId) async {
    try {
      await FirebaseFirestore.instance
          .collection('enrollments')
          .doc(enrollmentId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enrollment removed successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to remove enrollment: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Enrollments',
          style: textTheme.headlineMedium!.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.person_add, color: colorScheme.onSurface),
            onPressed: () {
              // Navigate to the AddEditEnrollmentPage to add a new enrollment
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddEditEnrollmentPage(courseId: widget.course.id),
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
                'Course: ${widget.course.name}',
                style: textTheme.bodyMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16.0),

              // Search Field
              CustomTextFormField(
                textController: _searchController,
                hint: 'Search enrolled students',
                validator: (value) => null,
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 24.0),

              // Firebase integration: StreamBuilder to listen for real-time changes
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  // Query the 'enrollments' collection for the specific courseId
                  stream: FirebaseFirestore.instance
                      .collection('enrollments')
                      .where('courseId', isEqualTo: widget.course.id)
                      .snapshots(),
                  builder: (context, enrollmentSnapshot) {
                    if (enrollmentSnapshot.hasError) {
                      return Center(child: Text('Error: ${enrollmentSnapshot.error}'));
                    }

                    if (enrollmentSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!enrollmentSnapshot.hasData || enrollmentSnapshot.data!.docs.isEmpty) {
                      return const Center(child: Text('No students enrolled yet.'));
                    }

                    final enrollmentDocs = enrollmentSnapshot.data!.docs;

                    return ListView.builder(
                      itemCount: enrollmentDocs.length,
                      itemBuilder: (context, index) {
                        final enrollment = enrollmentDocs[index].data() as Map<String, dynamic>;
                        final studentId = enrollment['studentId'];

                        // Use a FutureBuilder to fetch the student's details using the studentId
                        return FutureBuilder<DocumentSnapshot>(
                          future: _fetchUser(studentId),
                          builder: (context, userSnapshot) {
                            if (userSnapshot.connectionState == ConnectionState.waiting) {
                              return const SizedBox(); // Return an empty box while loading to avoid jumping UI
                            }

                            if (userSnapshot.hasError || !userSnapshot.hasData || !userSnapshot.data!.exists) {
                              return AdminItemCard(
                                title: 'Student Not Found',
                                subtitle: 'ID: $studentId',
                                trailing: IconButton(
                                  onPressed: () => _removeEnrollment(enrollmentDocs[index].id),
                                  icon: Icon(Icons.person_remove_outlined, color: colorScheme.error),
                                ),
                              );
                            }

                            final studentData = userSnapshot.data!.data() as Map<String, dynamic>;

                            // Build the card with real student data
                            return AdminItemCard(
                              title: studentData['name'] ?? 'Unknown Student',
                              subtitle: studentData['email'] ?? 'No email available',
                              trailing: IconButton(
                                onPressed: () => _removeEnrollment(enrollmentDocs[index].id),
                                icon: Icon(Icons.person_remove_outlined, color: colorScheme.error),
                              ),
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
}
