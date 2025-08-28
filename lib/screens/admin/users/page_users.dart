import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../widgets/custom_text_form_field.dart';
import '../../../widgets/custom_popup_box.dart';
import 'add_edit_user_page.dart';
import 'user_details_page.dart';
import '../../../services/firestore_service.dart';
import '../../../models/user_model.dart';

class PageUsers extends StatelessWidget {
  const PageUsers({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Users',
          style: textTheme.headlineLarge!.copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.person_add_alt_1, color: colorScheme.onSurface),
            onPressed: () {
              // Navigate to the AddEditUserPage to add a new user
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddEditUserPage(),
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
                hint: 'Search users by name or email',
                validator: (value) => null, // No validation needed for search
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 24.0),

              // Use a StreamBuilder to listen for real-time data from Firestore
              Expanded(
                child: StreamBuilder<List<UserModel>>(
                  stream: FirestoreService().getUsers(),
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
                      return const Center(child: Text('No users found.'));
                    }

                    // Display the list of users from Firestore
                    final users = snapshot.data!;
                    return ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final user = users[index];
                        return _buildUserCard(context, user);
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

  Widget _buildUserCard(BuildContext context, UserModel user) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(color: colorScheme.outlineVariant, width: 1.0),
      ),
      margin: const EdgeInsets.only(bottom: 16.0),
      child: InkWell(
        onTap: () {
          // Navigate to the UserDetailsPage and pass the user data
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserDetailsPage(user: user),
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
                      user.name,
                      style: textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      'Role: ${user.role}',
                      style: textTheme.labelSmall!.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      user.email,
                      style: textTheme.labelSmall!.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              // Use a StreamBuilder to get the current user's data and role
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseAuth.instance.authStateChanges().asyncMap((
                  user,
                ) {
                  if (user == null) {
                    return Future.value(null);
                  }
                  return FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .snapshots()
                      .first;
                }),
                builder: (context, snapshot) {
                  // Hide the buttons if the current user data is not available
                  if (!snapshot.hasData || snapshot.data?.data() == null) {
                    return const SizedBox.shrink();
                  }

                  final currentUserData =
                      snapshot.data!.data() as Map<String, dynamic>;
                  final currentUserRole =
                      currentUserData['role'] as String? ?? '';
                  final isCurrentUserAdmin = currentUserRole == 'Admin';

                  final isTargetUserAdmin = user.role == 'Admin';
                  final isCurrentUser = user.id == currentUserId;

                  // The condition to determine if the edit/delete buttons should be visible:
                  // 1. The currently logged-in user must be an admin.
                  // 2. The target user cannot be an admin.
                  // 3. The target user cannot be the currently logged-in user.
                  final bool canEdit =
                      isCurrentUserAdmin &&
                      !isTargetUserAdmin &&
                      !isCurrentUser;

                  return Row(
                    children: [
                      // Conditionally show the edit button
                      if (canEdit)
                        IconButton(
                          onPressed: () {
                            // Navigate to the AddEditUserPage and pass the user data for editing
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        AddEditUserPage(user: user.toMap()),
                              ),
                            );
                          },
                          icon: Icon(
                            Icons.edit_outlined,
                            color: colorScheme.primary,
                          ),
                        ),
                      // Conditionally show the remove button
                      if (canEdit)
                        IconButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return CustomPopupBox(
                                  title: 'Confirm Removal',
                                  content: Text(
                                    'Are you sure you want to remove ${user.name}? This action cannot be undone.',
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(
                                          context,
                                        ).pop(); // Close the dialog
                                      },
                                      style: TextButton.styleFrom(
                                        foregroundColor: colorScheme.onSurface,
                                      ),
                                      child: const Text('Cancel'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () async {
                                        await FirestoreService().deleteUser(
                                          user.id,
                                        );
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Removed ${user.name}',
                                              ),
                                            ),
                                          );
                                        }
                                        Navigator.of(
                                          context,
                                        ).pop(); // Close the dialog
                                      },
                                      style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8.0,
                                          ),
                                        ),
                                        backgroundColor: colorScheme.error,
                                        foregroundColor: colorScheme.onError,
                                      ),
                                      child: const Text('Remove'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          icon: Icon(
                            Icons.person_remove_outlined,
                            color: colorScheme.error,
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
