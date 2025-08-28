import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../widgets/custom_text_form_field.dart';
import '../../../widgets/custom_popup_box.dart'; // Import your reusable widget
import 'add_edit_assignment_page.dart';
import '../../../services/firestore_service.dart';
import '../../../models/assignment_model.dart';
import 'assignment_details_page.dart'; // Ensure you have this model

// Convert to a StatefulWidget to manage the Firebase stream
class PageAssignments extends StatefulWidget {
  const PageAssignments({super.key});

  @override
  State<PageAssignments> createState() => _PageAssignmentsState();
}

class _PageAssignmentsState extends State<PageAssignments> {
  // Controller for the search text field
  final TextEditingController _searchController = TextEditingController();

  // Firestore and Auth services
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Reference to the Firestore collection
  final CollectionReference _assignmentsCollection = FirebaseFirestore.instance
      .collection('assignments');

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
        // Use a StreamBuilder to conditionally show the Add button
        actions: [
          StreamBuilder<bool>(
            stream: _firestoreService.isUserAdmin(_auth.currentUser?.uid),
            builder: (context, snapshot) {
              // Check if the user is an admin
              if (snapshot.connectionState == ConnectionState.active &&
                  snapshot.hasData &&
                  snapshot.data == true) {
                // Show the button if the user is an admin
                return IconButton(
                  icon: Icon(Icons.add, color: colorScheme.onSurface),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddEditAssignmentPage(),
                      ),
                    );
                  },
                );
              }
              // Hide the button for non-admins or while loading
              return const SizedBox.shrink();
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
                textController: _searchController,
                hint: 'Search assignments by title or course',
                validator: (value) => null, // No validation needed for search
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 24.0),

              // Use StreamBuilder to listen for real-time updates from Firebase
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _assignmentsCollection.snapshots(),
                  builder: (context, snapshot) {
                    // Check for errors
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    // Show loading indicator while fetching data
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    // Check if data exists
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text('No assignments found.'));
                    }

                    // Build the list of assignments from the snapshot data
                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        // Extract data from the document snapshot
                        DocumentSnapshot doc = snapshot.data!.docs[index];
                        final assignment = AssignmentModel.fromDocument(doc);
                        return _buildAssignmentCard(context, assignment);
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

  // A separate function to build the assignment card
  Widget _buildAssignmentCard(
    BuildContext context,
    AssignmentModel assignment,
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
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => AssignmentDetailsPage(assignment: assignment),
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
                      assignment.title,
                      style: textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      'Course: ${assignment.courseId ?? 'N/A'}',
                      style: textTheme.labelSmall!.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      'Due Date: ${assignment.dueDate ?? 'N/A'}',
                      style: textTheme.labelSmall!.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              // Use a StreamBuilder to conditionally show the edit/delete buttons
              StreamBuilder<bool>(
                stream: _firestoreService.isUserAdmin(_auth.currentUser?.uid),
                builder: (context, snapshot) {
                  // Check if the user is an admin
                  if (snapshot.connectionState == ConnectionState.active &&
                      snapshot.hasData &&
                      snapshot.data == true) {
                    // Show buttons for admins
                    return Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            // Corrected: Pass the full assignment model to the edit page
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => AddEditAssignmentPage(
                                      assignment: assignment.toMap(),
                                      docId: assignment.id,
                                    ),
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
                            final bool confirmDelete =
                                await showDialog(
                                  context: context,
                                  builder:
                                      (context) => CustomPopupBox(
                                        title: 'Confirm Deletion',
                                        content: Text(
                                          'Are you sure you want to delete "${assignment.title}"? This action cannot be undone.',
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
                                                () => Navigator.of(
                                                  context,
                                                ).pop(true),
                                            style: FilledButton.styleFrom(
                                              backgroundColor:
                                                  colorScheme.error,
                                            ),
                                            child: const Text('Delete'),
                                          ),
                                        ],
                                      ),
                                ) ??
                                false;

                            if (confirmDelete) {
                              try {
                                await _assignmentsCollection
                                    .doc(assignment.id)
                                    .delete();
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Assignment deleted successfully.',
                                      ),
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Failed to delete assignment: $e',
                                      ),
                                    ),
                                  );
                                }
                              }
                            }
                          },
                          icon: Icon(
                            Icons.delete_outline,
                            color: colorScheme.error,
                          ),
                        ),
                      ],
                    );
                  }
                  // Hide buttons for non-admins or while loading
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
