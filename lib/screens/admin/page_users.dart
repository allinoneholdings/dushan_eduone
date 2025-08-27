import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../widgets/custom_text_form_field.dart';
import 'add_edit_user_page.dart';

class PageUsers extends StatelessWidget {
  PageUsers({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Manage Users',
          style: textTheme.headlineLarge!.copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.person_add_alt_1, color: colorScheme.onSurface),
            onPressed: () {
              // Navigate to the AddEditUserPage without passing any data
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

              // User List (using a mock list for demonstration)
              Expanded(
                child: ListView.builder(
                  itemCount: _mockUsers.length,
                  itemBuilder: (context, index) {
                    final user = _mockUsers[index];
                    return _buildUserCard(context, user);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserCard(BuildContext context, Map<String, dynamic> user) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
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
                    user['name']!,
                    style: textTheme.bodyMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    'Role: ${user['role']!}',
                    style: textTheme.labelSmall!.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    user['email']!,
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
                        builder: (context) => AddEditUserPage(user: user),
                      ),
                    );
                  },
                  icon: Icon(Icons.edit_outlined, color: colorScheme.primary),
                ),
                IconButton(
                  onPressed: () {
                    // Delete functionality
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Deleting ${user['name']}')),
                    );
                  },
                  icon: Icon(Icons.delete_outline, color: colorScheme.error),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Mock data for demonstration purposes
  final List<Map<String, dynamic>> _mockUsers = [
    {'name': 'John Doe', 'email': 'john.doe@example.com', 'role': 'Student'},
    {'name': 'Jane Smith', 'email': 'jane.smith@example.com', 'role': 'Staff'},
    {'name': 'Mark Johnson', 'email': 'mark.j@example.com', 'role': 'Student'},
    {'name': 'Sarah Lee', 'email': 'sarah.lee@example.com', 'role': 'Staff'},
  ];
}
