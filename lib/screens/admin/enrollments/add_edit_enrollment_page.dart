import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edu_one/models/user_model.dart';
import 'package:edu_one/widgets/custom_text_form_field.dart';

// Assuming AdminItemCard is in a separate file, so we'll re-import it here
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

class AddEditEnrollmentPage extends StatefulWidget {
  final String courseId;

  const AddEditEnrollmentPage({super.key, required this.courseId});

  @override
  State<AddEditEnrollmentPage> createState() => _AddEditEnrollmentPageState();
}

class _AddEditEnrollmentPageState extends State<AddEditEnrollmentPage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Handles the enrollment of a student into a course.
  /// It first checks if the enrollment already exists to prevent duplicates.
  Future<void> _enrollStudent(String studentId) async {
    try {
      // Add a new document to the 'enrollments' collection
      await FirebaseFirestore.instance.collection('enrollments').add({
        'courseId': widget.courseId,
        'studentId': studentId,
        'enrollmentDate': FieldValue.serverTimestamp(), // Optional: Store the enrollment date
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Student enrolled successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to enroll student: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Student to Course',
          style: textTheme.headlineMedium!.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Search Field
              CustomTextFormField(
                textController: _searchController,
                hint: 'Search users by name or email',
                validator: (value) => null,
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 24.0),

              // StreamBuilder to fetch all users from Firestore
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('users').snapshots(),
                  builder: (context, userSnapshot) {
                    if (userSnapshot.hasError) {
                      return Center(child: Text('Error: ${userSnapshot.error}'));
                    }

                    if (userSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!userSnapshot.hasData || userSnapshot.data!.docs.isEmpty) {
                      return const Center(child: Text('No users found.'));
                    }

                    final users = userSnapshot.data!.docs.map((doc) => UserModel.fromDocument(doc)).toList();

                    // Nested StreamBuilder to fetch existing enrollments for this course
                    return StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('enrollments')
                          .where('courseId', isEqualTo: widget.courseId)
                          .snapshots(),
                      builder: (context, enrollmentSnapshot) {
                        if (enrollmentSnapshot.hasError) {
                          return Center(child: Text('Error: ${enrollmentSnapshot.error}'));
                        }

                        if (enrollmentSnapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        final enrolledStudentIds = enrollmentSnapshot.data!.docs.map((doc) => doc['studentId'] as String).toSet();

                        return ListView.builder(
                          itemCount: users.length,
                          itemBuilder: (context, index) {
                            final user = users[index];
                            final isEnrolled = enrolledStudentIds.contains(user.id);

                            return AdminItemCard(
                              title: user.name,
                              subtitle: user.email,
                              trailing: IconButton(
                                // Use a ternary operator to change the icon and color based on enrollment status
                                icon: Icon(
                                  isEnrolled ? Icons.check_circle_outlined : Icons.person_add_outlined,
                                  color: isEnrolled ? Colors.green : colorScheme.primary,
                                ),
                                // Disable the button if the student is already enrolled
                                onPressed: isEnrolled ? null : () => _enrollStudent(user.id),
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
