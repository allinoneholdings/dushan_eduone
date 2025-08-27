import 'package:flutter/material.dart';

import '../../widgets/custom_text_form_field.dart';
class CustomFilledButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;

  const CustomFilledButton({
    super.key,
    required this.onPressed,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      child: Text(
        text,
        style: textTheme.bodyMedium!.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class AddEditUserPage extends StatefulWidget {
  // This nullable user parameter determines if we are adding or editing
  final Map<String, dynamic>? user;

  const AddEditUserPage({super.key, this.user});

  @override
  State<AddEditUserPage> createState() => _AddEditUserPageState();
}

class _AddEditUserPageState extends State<AddEditUserPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  String _selectedRole = 'Student';
  late final bool _isEditing;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.user != null;
    _nameController = TextEditingController(text: _isEditing ? widget.user!['name'] : '');
    _emailController = TextEditingController(text: _isEditing ? widget.user!['email'] : '');
    _passwordController = TextEditingController();
    if (_isEditing && widget.user!['role'] != null) {
      _selectedRole = widget.user!['role'];
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (_isEditing) {
        // Handle logic for editing an existing user
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User updated successfully!')),
        );
      } else {
        // Handle logic for adding a new user
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('New user added successfully!')),
        );
      }
      Navigator.pop(context); // Go back to the previous page
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit User' : 'Add New User',
          style: textTheme.headlineMedium!.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Full Name
                CustomTextFormField(
                  textController: _nameController,
                  hint: 'Full Name',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.name,
                ),
                const SizedBox(height: 24.0),

                // Email
                CustomTextFormField(
                  textController: _emailController,
                  hint: 'Email Address',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 24.0),

                // Role Selection
                DropdownButtonFormField<String>(
                  value: _selectedRole,
                  decoration: InputDecoration(
                    labelText: 'Role',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(color: colorScheme.outlineVariant),
                    ),
                  ),
                  items: <String>['Student', 'Staff']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedRole = newValue!;
                    });
                  },
                ),
                const SizedBox(height: 24.0),

                // Password (for adding only)
                if (!_isEditing)
                  CustomTextFormField(
                    textController: _passwordController,
                    hint: 'Password',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a password';
                      }
                      return null;
                    },
                    obscureText: true,
                    keyboardType: TextInputType.visiblePassword,
                  ),
                if (!_isEditing) const SizedBox(height: 24.0),

                // Submit Button using the CustomFilledButton
                CustomFilledButton(
                  onPressed: _submitForm,
                  text: _isEditing ? 'Save Changes' : 'Add User',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
