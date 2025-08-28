import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../widgets/custom_text_form_field.dart';
import 'add_edit_assignment_page.dart';

// Convert to a StatefulWidget to manage the Firebase stream
class PageAssignments extends StatefulWidget {
  const PageAssignments({super.key});

  @override
  State<PageAssignments> createState() => _PageAssignmentsState();
}

class _PageAssignmentsState extends State<PageAssignments> {
  // Controller for the search text field
  final TextEditingController _searchController = TextEditingController();

  // Reference to the Firestore collection
  final CollectionReference _assignmentsCollection =
  FirebaseFirestore.instance.collection('assignments');

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
                        Map<String, dynamic> assignment =
                        doc.data() as Map<String, dynamic>;

                        // Pass the document ID to handle updates/deletes
                        assignment['id'] = doc.id;

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
                      'Course: ${assignment['course'] ?? 'N/A'}',
                      style: textTheme.labelSmall!.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      'Due Date: ${assignment['dueDate'] ?? 'N/A'}',
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
                          builder: (context) => AddEditAssignmentPage(
                            assignment: assignment,
                            docId: assignment['id'],
                          ),
                        ),
                      );
                    },
                    icon: Icon(Icons.edit_outlined, color: colorScheme.primary),
                  ),
                  IconButton(
                    onPressed: () {
                      // Call a function to delete the assignment from Firebase
                      _deleteAssignment(assignment['id']);
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

  // Function to delete an assignment from Firestore
  Future<void> _deleteAssignment(String docId) async {
    try {
      await _assignmentsCollection.doc(docId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Assignment deleted successfully.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete assignment: $e')),
      );
    }
  }
}
