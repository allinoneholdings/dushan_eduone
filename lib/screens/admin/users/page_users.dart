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
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    // Use a top-level StreamBuilder to check for admin status once.
    return StreamBuilder<bool>(
      stream: FirestoreService().isUserAdmin(currentUserId),
      builder: (context, snapshot) {
        final isCurrentUserAdmin = snapshot.data ?? false;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Users',
              style: textTheme.headlineLarge!.copyWith(fontWeight: FontWeight.bold),
            ),
            actions: [
              // Show the add button only if the user is an admin.
              if (isCurrentUserAdmin)
                IconButton(
                  icon: Icon(Icons.person_add_alt_1, color: colorScheme.onSurface),
                  onPressed: () {
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
                            return _buildUserCard(context, user, isCurrentUserAdmin, currentUserId);
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
      },
    );
  }

  Widget _buildUserCard(BuildContext context, UserModel user, bool isCurrentUserAdmin, String? currentUserId) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Helper function to get a color for a specific role
    Color getRoleColor(String role) {
      switch (role) {
        case 'Admin':
          return Colors.redAccent;
        case 'Staff':
          return colorScheme.secondary;
        case 'Student':
          return Colors.green;
        default:
          return colorScheme.outlineVariant;
      }
    }

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
                    Container(
                      width: 55,
                      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 0.5),
                      decoration: BoxDecoration(
                        color: getRoleColor(user.role),
                        borderRadius: BorderRadius.circular(2.0),
                      ),
                      child: Center(
                        child: Text(
                          user.role,
                          style: textTheme.labelSmall!.copyWith(
                            color: colorScheme.onPrimary,
                          ),
                        ),
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
              // Display the role in a colored card
              Row(
                children: [
                  // Check if the current user is an admin, the target user is not, and it's not the current user.
                  if (isCurrentUserAdmin && user.role != 'Admin' && user.id != currentUserId)
                    IconButton(
                      onPressed: () {
                        // Navigate to the AddEditUserPage and pass the user data for editing
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddEditUserPage(user: user.toMap()),
                          ),
                        );
                      },
                      icon: Icon(
                        Icons.edit_outlined,
                        color: colorScheme.primary,
                      ),
                    ),
                  // Conditionally show the remove button
                  if (isCurrentUserAdmin && user.role != 'Admin' && user.id != currentUserId)
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
                                    Navigator.of(context).pop(); // Close the dialog
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor: colorScheme.onSurface,
                                  ),
                                  child: const Text('Cancel'),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    await FirestoreService().deleteUser(user.id);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Removed ${user.name}'),
                                        ),
                                      );
                                    }
                                    Navigator.of(context).pop(); // Close the dialog
                                  },
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
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
              ),
            ],
          ),
        ),
      ),
    );
  }

}
