import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../widgets/custom_text_form_field.dart';
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
                      return Center(
                        child: Text('Error: ${snapshot.error}'),
                      );
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
              Row(
                children: [
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
                    icon: Icon(Icons.edit_outlined, color: colorScheme.primary),
                  ),
                  IconButton(
                    onPressed: () async {
                      // Delete functionality
                      await FirestoreService().deleteUser(user.id);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Deleted ${user.name}')),
                        );
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
