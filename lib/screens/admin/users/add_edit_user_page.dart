import 'package:edu_one/utils/snackbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../widgets/custom_text_form_field.dart';
import '../../../services/firestore_service.dart';
import '../../../models/user_model.dart';
import 'package:edu_one/widgets/custom_filled_button.dart';
import '../../../services/auth_service.dart';

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
  final AuthService _authService = AuthService(); // Instantiate your AuthService

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

      try {
        if (isEditing) {
          // Update the user's profile information in Firestore
          final userId = widget.user!['id']!;
          final userModel = UserModel(
            id: userId,
            name: _nameController.text,
            email: _emailController.text,
            role: _selectedRole,
          );
          await _firestoreService.updateUser(userModel);
          if (context.mounted) {
            SnackBarHelper.show(context, 'User updated successfully!');
          }
        } else {
          // Use the AuthService to sign up a new user with email and password
          final userCredential = await _authService.signUpWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
            name: _nameController.text.trim(),
            role: _selectedRole,
          );

          if (userCredential != null) {
            if (context.mounted) {
              SnackBarHelper.show(context, 'New user added successfully!');
            }
          }
        }
        if (context.mounted) {
          Navigator.pop(context);
        }
      } on FirebaseAuthException catch (e) {
        String message;
        if (e.code == 'weak-password') {
          message = 'The password provided is too weak.';
        } else if (e.code == 'email-already-in-use') {
          message = 'An account already exists for that email.';
        } else {
          message = 'Authentication failed: ${e.message}';
        }
        if (context.mounted) {
          SnackBarHelper.show(context, message);
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
                  enabled: !_isEditing, // Prevent editing email for existing users
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
                  items: <String>[
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
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters long';
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
