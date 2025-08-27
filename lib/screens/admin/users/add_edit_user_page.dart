import 'package:edu_one/utils/snackbar_helper.dart';
import 'package:flutter/material.dart';
import '../../../widgets/custom_text_form_field.dart';
import '../../../services/firestore_service.dart';
import '../../../models/user_model.dart';
import 'package:edu_one/widgets/custom_filled_button.dart';

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
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _isEditing = widget.user != null;
    _nameController = TextEditingController(
      text: _isEditing ? widget.user!['name'] : '',
    );
    _emailController = TextEditingController(
      text: _isEditing ? widget.user!['email'] : '',
    );
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

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final isEditing = widget.user != null;
      final String userId = isEditing ? widget.user!['id']! : '';

      final userModel = UserModel(
        id: userId,
        name: _nameController.text,
        email: _emailController.text,
        role: _selectedRole,
      );

      try {
        if (isEditing) {
          await _firestoreService.updateUser(userModel);

          SnackBarHelper.show(context, 'User updated successfully!');
        } else {
          // This example adds a new user to Firestore.
          // Note: In a real-world app, user creation would likely be handled by Firebase Authentication
          // and a Cloud Function to create the Firestore document.
          await _firestoreService.addUser(userModel);
          if (context.mounted) {
            SnackBarHelper.show(context, 'New user added successfully!');
          }
        }
        if (context.mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        if (context.mounted) {
          SnackBarHelper.show(context, 'Failed to save user: $e');
        }
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
                  items:
                      <String>[
                        'Student',
                        'Staff',
                      ].map<DropdownMenuItem<String>>((String value) {
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
