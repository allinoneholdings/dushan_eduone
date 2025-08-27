import 'package:edu_one/utils/snackbar_helper.dart';
import 'package:edu_one/widgets/custom_filled_button.dart';
import 'package:edu_one/widgets/custom_text.dart';
import 'package:edu_one/widgets/custom_text_form_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isSpinKitLoaded = false;
  String? _selectedRole;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _handleSignUp() async {
    if (_formKey.currentState?.validate() == true && _selectedRole != null) {
      setState(() {
        _isSpinKitLoaded = true;
      });

      try {
        final userCredential = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // Update the user's display name
        await userCredential.user?.updateDisplayName(
          _nameController.text.trim(),
        );

        // Save user data to Firestore
        await _firestore.collection('users').doc(userCredential.user?.uid).set({
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'role': _selectedRole,
          'createdAt': FieldValue.serverTimestamp(),
        });

        if (mounted) {
          SnackBarHelper.show(context, 'Account created as $_selectedRole!');
          Navigator.pop(context); // Go back to the sign-in page on success
        }
      } on FirebaseAuthException catch (e) {
        String message;
        if (e.code == 'weak-password') {
          message = 'The password provided is too weak.';
        } else if (e.code == 'email-already-in-use') {
          message = 'An account already exists for that email.';
        } else {
          message = 'An unexpected error occurred. Please try again.';
        }
        if (mounted) {
          SnackBarHelper.show(context, message, isError: true);
        }
      } catch (e) {
        if (mounted) {
          SnackBarHelper.show(
            context,
            'Failed to create account. Please try again.',
            isError: true,
          );
        }
      } finally {
        setState(() {
          _isSpinKitLoaded = false;
        });
      }
    } else {
      SnackBarHelper.show(
        context,
        'Please select an account type.',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: RichText(
          text: TextSpan(
            style:
                textTheme.headlineLarge, // Use the base style from your theme
            children: <TextSpan>[
              TextSpan(
                text: 'Edu',
                style: TextStyle(
                  color: colorScheme.primary, // First color for 'Edu'
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: 'One',
                style: TextStyle(
                  color: colorScheme.secondary, // Second color for 'One'
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 48.0,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Create Your Account',
                      style: textTheme.headlineLarge!.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      'Join our learning community today.',
                      style: textTheme.bodyMedium!.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48.0),
                    CustomText(text: 'Full Name'),
                    const SizedBox(height: 8.0),
                    CustomTextFormField(
                      hint: 'John Doe',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Full name is required.';
                        }
                        return null;
                      },
                      textController: _nameController,
                    ),
                    const SizedBox(height: 16.0),
                    CustomText(text: 'Email Address'),
                    const SizedBox(height: 8.0),
                    CustomTextFormField(
                      hint: 'eduonemail@email.com',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Email is required.';
                        }
                        final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                        if (!emailRegex.hasMatch(value)) {
                          return 'Invalid email format.';
                        }
                        return null;
                      },
                      textController: _emailController,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16.0),
                    CustomText(text: 'Password'),
                    const SizedBox(height: 8.0),
                    CustomTextFormField(
                      textController: _passwordController,
                      hint: '********',
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password is required.';
                        }
                        if (value.length < 8) {
                          return 'Password must be at least 8 characters long.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    CustomText(text: 'Confirm Password'),
                    const SizedBox(height: 8.0),
                    CustomTextFormField(
                      textController: _confirmPasswordController,
                      hint: '********',
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password.';
                        }
                        if (value != _passwordController.text) {
                          return 'Passwords do not match.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    CustomText(text: 'Account Type'),
                    const SizedBox(height: 8.0),
                    _buildRoleDropdown(
                      context,
                    ), // New widget for role selection
                    const SizedBox(height: 48.0),
                    CustomFilledButton(
                      onPressed: _handleSignUp,
                      text: 'Create Account',
                    ),
                    const SizedBox(height: 24.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Already have an account? ",
                          style: textTheme.labelSmall!.copyWith(
                            color: colorScheme.onSurface,
                          ),
                        ),
                        InkWell(
                          onTap:
                              () => Navigator.pop(
                                context,
                              ), // Go back to the sign-in page
                          child: Text(
                            "Sign In",
                            style: textTheme.labelSmall!.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (_isSpinKitLoaded)
              Container(
                color: colorScheme.surface.withAlpha(200),
                child: Center(
                  child: CircularProgressIndicator(color: colorScheme.primary),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleDropdown(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: colorScheme.outlineVariant, width: 2.0),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedRole,
          hint: Text(
            'Select Role',
            style: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
          isExpanded: true,
          style: TextStyle(color: colorScheme.onSurface),
          dropdownColor: colorScheme.surfaceContainer,
          items: const [
            DropdownMenuItem(value: 'Student', child: Text('Student')),
            DropdownMenuItem(value: 'Staff', child: Text('Staff')),
          ],
          onChanged: (String? newValue) {
            setState(() {
              _selectedRole = newValue;
            });
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
